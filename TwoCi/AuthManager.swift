import Foundation

struct SupabaseAuthSession: Codable, Equatable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date?
}

enum AuthState: Equatable {
    case checking
    case signedOut
    case signedIn
}

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var state: AuthState = .checking
    @Published var statusMessage: String?
    @Published var errorMessage: String?
    @Published var isWorking = false

    private let sessionStorageKey = "supabaseAuthSession"
    private let callbackURL = "twoci://auth-callback"
    private var session: SupabaseAuthSession?

    init() {
        restoreSession()
    }

    func sendMagicLink(to email: String) async {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard normalizedEmail.contains("@"), normalizedEmail.contains(".") else {
            errorMessage = "Enter a valid email address."
            return
        }

        isWorking = true
        errorMessage = nil
        statusMessage = nil

        do {
            try await SupabaseAuthClient().sendMagicLink(email: normalizedEmail, redirectTo: callbackURL)
            statusMessage = "Check \(normalizedEmail) for your 2CI sign-in link."
        } catch {
            errorMessage = error.localizedDescription
        }

        isWorking = false
    }

    func handleAuthCallback(_ url: URL) {
        guard url.scheme == "twoci" else {
            return
        }

        let values = authValues(from: url)

        guard let accessToken = values["access_token"] else {
            errorMessage = values["error_description"] ?? values["error"] ?? "The sign-in link did not include a session."
            state = .signedOut
            return
        }

        let expiresAt: Date?
        if let expiresInValue = values["expires_in"], let expiresIn = TimeInterval(expiresInValue) {
            expiresAt = Date().addingTimeInterval(expiresIn)
        } else {
            expiresAt = nil
        }

        let newSession = SupabaseAuthSession(
            accessToken: accessToken,
            refreshToken: values["refresh_token"],
            expiresAt: expiresAt
        )

        saveSession(newSession)
        statusMessage = nil
        errorMessage = nil
        state = .signedIn
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: sessionStorageKey)
        session = nil
        statusMessage = nil
        errorMessage = nil
        state = .signedOut
    }

    #if DEBUG
    func continueInDemoMode() {
        statusMessage = nil
        errorMessage = nil
        state = .signedIn
    }
    #endif

    private func restoreSession() {
        guard
            let data = UserDefaults.standard.data(forKey: sessionStorageKey),
            let restoredSession = try? JSONDecoder().decode(SupabaseAuthSession.self, from: data)
        else {
            state = .signedOut
            return
        }

        if let expiresAt = restoredSession.expiresAt, expiresAt <= Date() {
            signOut()
            return
        }

        session = restoredSession
        state = .signedIn
    }

    private func saveSession(_ newSession: SupabaseAuthSession) {
        session = newSession

        if let data = try? JSONEncoder().encode(newSession) {
            UserDefaults.standard.set(data, forKey: sessionStorageKey)
        }
    }

    private func authValues(from url: URL) -> [String: String] {
        var values: [String: String] = [:]

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { item in
                values[item.name] = item.value
            }
        }

        if let fragment = url.fragment {
            URLComponents(string: "twoci://auth-callback?\(fragment)")?.queryItems?.forEach { item in
                values[item.name] = item.value
            }
        }

        return values
    }
}

private struct SupabaseAuthClient {
    func sendMagicLink(email: String, redirectTo: String) async throws {
        let endpoint = SupabaseConfig.projectURL.appending(path: "auth/v1/otp")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = SupabaseConfig.defaultHeaders
        request.httpBody = try JSONEncoder().encode(
            MagicLinkRequest(
                email: email,
                createUser: false,
                options: MagicLinkOptions(emailRedirectTo: redirectTo)
            )
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw AuthClientError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
}

private struct MagicLinkRequest: Encodable {
    let email: String
    let createUser: Bool
    let options: MagicLinkOptions

    enum CodingKeys: String, CodingKey {
        case email
        case createUser = "create_user"
        case options
    }
}

private struct MagicLinkOptions: Encodable {
    let emailRedirectTo: String

    enum CodingKeys: String, CodingKey {
        case emailRedirectTo = "email_redirect_to"
    }
}

private enum AuthClientError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Supabase returned an invalid response."
        case .requestFailed(let statusCode):
            "Supabase could not send the sign-in link. Status code: \(statusCode)."
        }
    }
}
