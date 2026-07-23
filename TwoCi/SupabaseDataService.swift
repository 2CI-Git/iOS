import Foundation

struct SupabaseAppData {
    let currentMember: Member
    let members: [Member]
    let posts: [FeedPost]
    let cohort: Cohort
    let preferences: [NotificationPreference]
}

struct SupabaseDataService {
    private let accessToken: String
    private let userID: UUID

    init(accessToken: String, userID: UUID) {
        self.accessToken = accessToken
        self.userID = userID
    }

    func loadAppData() async throws -> SupabaseAppData {
        async let profileRows = request([SupabaseMemberProfileRow].self, path: "member_profiles", queryItems: [
            URLQueryItem(name: "select", value: "id,user_id,role,name,title,company,city,function,challenge,email,cohorts(name,city),member_affinity_labels(affinity_labels(id,name))"),
            URLQueryItem(name: "is_active", value: "eq.true")
        ])
        async let postRows = request([SupabaseFeedPostRow].self, path: "feed_posts", queryItems: [
            URLQueryItem(name: "select", value: "id,author_profile_id,type,title,body,created_at"),
            URLQueryItem(name: "order", value: "created_at.desc")
        ])
        async let replyRows = request([SupabaseFeedReplyRow].self, path: "feed_replies", queryItems: [
            URLQueryItem(name: "select", value: "id,post_id,author_profile_id,body,created_at"),
            URLQueryItem(name: "order", value: "created_at.asc")
        ])
        async let preferenceRows = request([SupabaseNotificationPreferenceRow].self, path: "notification_preferences", queryItems: [
            URLQueryItem(name: "select", value: "id,member_profile_id,type,push_enabled,in_app_enabled,email_enabled,sms_enabled")
        ])

        let profiles = try await profileRows
        let members = profiles.map(Member.init(row:))

        guard let currentMember = members.first(where: { member in
            profiles.first(where: { $0.id == member.id })?.userID == userID
        }) else {
            throw SupabaseDataError.currentMemberMissing
        }

        let memberByID = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0) })
        let repliesByPostID = Dictionary(grouping: try await replyRows, by: \.postID)
        let posts = try await postRows.compactMap { row -> FeedPost? in
            guard let author = memberByID[row.authorProfileID] else {
                return nil
            }

            let replies = repliesByPostID[row.id, default: []].compactMap { replyRow -> FeedReply? in
                guard let replyAuthor = memberByID[replyRow.authorProfileID] else {
                    return nil
                }

                return FeedReply(
                    id: replyRow.id,
                    author: replyAuthor,
                    body: replyRow.body,
                    timestamp: RelativeDateFormatter.label(for: replyRow.createdAt)
                )
            }

            return FeedPost(
                id: row.id,
                author: author,
                kind: FeedPostKind(rawValue: row.type.capitalized) ?? .update,
                title: row.title,
                body: row.body,
                timestamp: RelativeDateFormatter.label(for: row.createdAt),
                replies: replies
            )
        }

        let currentProfileRow = profiles.first { $0.userID == userID }
        let cohortName = currentProfileRow?.cohort?.name ?? currentMember.cohort
        let cohortCity = currentProfileRow?.cohort?.city ?? currentMember.city
        let cohortMembers = members.filter { $0.cohort == cohortName || $0.role == .admin }
        let cohort = Cohort(
            id: UUID(),
            name: cohortName,
            city: cohortCity,
            dates: "2026",
            scenario: "Member cohort",
            status: "Active",
            members: cohortMembers,
            photos: 0
        )

        let preferences = try await preferenceRows
            .filter { $0.memberProfileID == currentMember.id }
            .map(NotificationPreference.init(row:))

        return SupabaseAppData(
            currentMember: currentMember,
            members: members,
            posts: posts,
            cohort: cohort,
            preferences: preferences.isEmpty ? MockDataStore().notificationPreferences() : preferences
        )
    }

    private func request<T: Decodable>(_ type: T.Type, path: String, queryItems: [URLQueryItem]) async throws -> T {
        var components = URLComponents(url: SupabaseConfig.projectURL.appending(path: "rest/v1/\(path)"), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw SupabaseDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = SupabaseConfig.authenticatedHeaders(accessToken: accessToken)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseDataError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SupabaseDataError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return try decoder.decode(T.self, from: data)
    }
}

private struct SupabaseMemberProfileRow: Decodable {
    let id: UUID
    let userID: UUID
    let role: String
    let name: String
    let title: String
    let company: String
    let city: String
    let function: String
    let challenge: String
    let email: String
    let cohort: SupabaseCohortRow?
    let memberAffinityLabels: [SupabaseMemberAffinityLabelRow]

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case role
        case name
        case title
        case company
        case city
        case function
        case challenge
        case email
        case cohort = "cohorts"
        case memberAffinityLabels
    }
}

private struct SupabaseCohortRow: Decodable {
    let name: String
    let city: String?
}

private struct SupabaseMemberAffinityLabelRow: Decodable {
    let affinityLabels: SupabaseAffinityLabelRow
}

private struct SupabaseAffinityLabelRow: Decodable {
    let id: UUID
    let name: String
}

private struct SupabaseFeedPostRow: Decodable {
    let id: UUID
    let authorProfileID: UUID
    let type: String
    let title: String
    let body: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case authorProfileID = "authorProfileId"
        case type
        case title
        case body
        case createdAt
    }
}

private struct SupabaseFeedReplyRow: Decodable {
    let id: UUID
    let postID: UUID
    let authorProfileID: UUID
    let body: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case postID = "postId"
        case authorProfileID = "authorProfileId"
        case body
        case createdAt
    }
}

private struct SupabaseNotificationPreferenceRow: Decodable {
    let id: UUID
    let memberProfileID: UUID
    let type: String
    let pushEnabled: Bool
    let inAppEnabled: Bool
    let emailEnabled: Bool
    let smsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case memberProfileID = "memberProfileId"
        case type
        case pushEnabled
        case inAppEnabled
        case emailEnabled
        case smsEnabled
    }
}

private extension Member {
    init(row: SupabaseMemberProfileRow) {
        self.init(
            id: row.id,
            name: row.name,
            role: MemberRole(databaseValue: row.role),
            title: row.title,
            company: row.company,
            city: row.city,
            cohort: row.cohort?.name ?? "",
            function: row.function,
            challenge: row.challenge,
            labels: row.memberAffinityLabels.map {
                AffinityLabel(id: $0.affinityLabels.id, name: $0.affinityLabels.name)
            },
            email: row.email
        )
    }
}

private extension NotificationPreference {
    init(row: SupabaseNotificationPreferenceRow) {
        self.init(
            id: row.id,
            title: row.type
                .split(separator: "_")
                .map { $0.capitalized }
                .joined(separator: " "),
            channels: [
                row.pushEnabled ? "Push" : nil,
                row.inAppEnabled ? "In-app" : nil,
                row.emailEnabled ? "Email" : nil,
                row.smsEnabled ? "SMS" : nil
            ]
            .compactMap { $0 }
            .joined(separator: ", "),
            isEnabled: row.pushEnabled || row.inAppEnabled || row.emailEnabled || row.smsEnabled
        )
    }
}

private extension MemberRole {
    init(databaseValue: String) {
        switch databaseValue {
        case "admin":
            self = .admin
        case "council":
            self = .council
        default:
            self = .member
        }
    }
}

private enum SupabaseDataError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case currentMemberMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Could not build a Supabase URL."
        case .invalidResponse:
            "Supabase returned an invalid response."
        case .requestFailed(let statusCode):
            "Supabase data request failed with status code \(statusCode)."
        case .currentMemberMissing:
            "Could not find the signed-in member profile."
        }
    }
}

private enum RelativeDateFormatter {
    static func label(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

private extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithFractionalSeconds = custom { decoder in
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractionalFormatter.date(from: value) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: value) {
            return date
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(value)")
    }
}
