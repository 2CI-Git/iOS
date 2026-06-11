import Foundation

enum MemberRole: String, CaseIterable, Identifiable {
    case member = "Member"
    case council = "Council"
    case admin = "Admin"

    var id: String { rawValue }
}

struct AffinityLabel: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct Member: Identifiable, Hashable {
    let id: UUID
    var name: String
    let role: MemberRole
    var title: String
    var company: String
    var city: String
    let cohort: String
    var function: String
    var challenge: String
    var labels: [AffinityLabel]
    var email: String
}

enum FeedPostKind: String {
    case prompt = "Prompt"
    case update = "Update"
    case resource = "Resource"
    case milestone = "Milestone"
}

struct FeedReply: Identifiable {
    let id: UUID
    let author: Member
    let body: String
    let timestamp: String
}

struct FeedPost: Identifiable {
    let id: UUID
    let author: Member
    let kind: FeedPostKind
    let title: String
    let body: String
    let timestamp: String
    var replies: [FeedReply]
}

struct Cohort: Identifiable {
    let id: UUID
    let name: String
    let city: String
    let dates: String
    let scenario: String
    let status: String
    let members: [Member]
    let photos: Int
}

struct NotificationPreference: Identifiable {
    let id: UUID
    let title: String
    let channels: String
    var isEnabled: Bool
}
