import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var email = ""

    var body: some View {
        ZStack {
            AppTheme.navy
                .ignoresSafeArea()

            VStack(spacing: 34) {
                Spacer(minLength: 32)

                Image("SplashWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 64)
                    .accessibilityLabel("2CI")

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to 2CI")
                            .font(.title.bold())
                            .foregroundStyle(.white)

                        Text("Sign in with the email tied to your invite.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.74))

                        TextField("you@company.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(Color.white)
                            .foregroundStyle(AppTheme.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    Button {
                        Task {
                            await authManager.sendMagicLink(to: email)
                        }
                    } label: {
                        HStack {
                            if authManager.isWorking {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "envelope.fill")
                            }

                            Text(authManager.isWorking ? "Sending" : "Send sign-in link")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(AppTheme.oxblood)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .disabled(authManager.isWorking)

                    if let statusMessage = authManager.statusMessage {
                        MessageBanner(text: statusMessage, systemImage: "checkmark.circle.fill", tint: AppTheme.powderBlue)
                    }

                    if let errorMessage = authManager.errorMessage {
                        MessageBanner(text: errorMessage, systemImage: "exclamationmark.triangle.fill", tint: Color(red: 1.0, green: 0.77, blue: 0.42))
                    }

                    #if DEBUG
                    Button {
                        authManager.continueInDemoMode()
                    } label: {
                        Label("Continue in demo", systemImage: "iphone")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.82))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    #endif
                }
                .frame(maxWidth: 430)

                Spacer(minLength: 48)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
    }
}

private struct MessageBanner: View {
    let text: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)

            Text(text)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
