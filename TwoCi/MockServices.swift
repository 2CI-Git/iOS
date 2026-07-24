import Foundation

protocol MemberService {
    func currentMember() -> Member
    func members() -> [Member]
}

protocol FeedService {
    func posts() -> [FeedPost]
}

protocol CohortService {
    func currentCohort() -> Cohort
}

struct MockDataStore: MemberService, FeedService, CohortService {
    let labels: [AffinityLabel] = [
        AffinityLabel(id: UUID(), name: "Design"),
        AffinityLabel(id: UUID(), name: "AI"),
        AffinityLabel(id: UUID(), name: "Seattle"),
        AffinityLabel(id: UUID(), name: "Product"),
        AffinityLabel(id: UUID(), name: "People Leadership"),
        AffinityLabel(id: UUID(), name: "Sales"),
        AffinityLabel(id: UUID(), name: "Operations")
    ]

    func currentMember() -> Member {
        members()[1]
    }

    func members() -> [Member] {
        [
            Member(
                id: UUID(),
                name: "Mark Schindler",
                role: .admin,
                title: "Founder",
                company: "Second Circle Institute",
                city: "Denver",
                cohort: "Council",
                function: "Leadership",
                challenge: "Creating the connective tissue between cohorts",
                labels: [labels[0], labels[2], labels[4]],
                email: "mark@2ci.com"
            ),
            Member(
                id: UUID(),
                name: "Ryan Wilson",
                role: .member,
                title: "Designer",
                company: "Noda AI",
                city: "Seattle, WA",
                cohort: "Scottsdale 2026",
                function: "Design",
                challenge: "Shaping useful AI experiences that preserve trust, judgment, and human context.",
                labels: [labels[0], labels[1], labels[2], labels[3]],
                email: "ryanblakewilson@gmail.com"
            ),
            Member(
                id: UUID(),
                name: "Amber Chen",
                role: .member,
                title: "VP Operations",
                company: "Northstar Labs",
                city: "Chicago",
                cohort: "Denver 2026",
                function: "Operations",
                challenge: "Getting cross-functional teams aligned during a reorg",
                labels: [labels[3], labels[6]],
                email: "amber@example.com"
            ),
            Member(
                id: UUID(),
                name: "Jamie Patel",
                role: .member,
                title: "Director of Sales",
                company: "Fieldkit",
                city: "Denver",
                cohort: "Denver 2026",
                function: "Sales",
                challenge: "Moving from founder-led sales into a repeatable motion",
                labels: [labels[5], labels[2], labels[3]],
                email: "jamie@example.com"
            ),
            Member(
                id: UUID(),
                name: "Nora Ellis",
                role: .council,
                title: "Former COO",
                company: "Hearth Systems",
                city: "Charlotte",
                cohort: "Council",
                function: "Operations",
                challenge: "Helping leaders see the pattern underneath the noise",
                labels: [labels[4], labels[6]],
                email: "nora@example.com"
            )
        ]
    }

    func posts() -> [FeedPost] {
        let roster = members()
        let promptReplies = [
            FeedReply(
                id: UUID(),
                author: roster[2],
                body: "I have been postponing a compensation conversation because the facts are easy and the meaning is not. Writing the opening sentence helped.",
                timestamp: "2h ago"
            ),
            FeedReply(
                id: UUID(),
                author: roster[3],
                body: "Mine is with a founder-led account that needs to hear no. I am realizing I keep trying to make the no sound like a maybe.",
                timestamp: "1h ago"
            ),
            FeedReply(
                id: UUID(),
                author: roster[4],
                body: "The cleaner move might be naming the risk directly before offering the path forward. Most people can handle clear faster than careful.",
                timestamp: "45m ago"
            )
        ]
        let travelReplies = [
            FeedReply(
                id: UUID(),
                author: roster[3],
                body: "I am near River North Wednesday morning. Coffee before 9 works.",
                timestamp: "Yesterday"
            ),
            FeedReply(
                id: UUID(),
                author: roster[0],
                body: "This is exactly the kind of ambient connection this place should make easier.",
                timestamp: "Yesterday"
            )
        ]
        let resourceReplies = [
            FeedReply(
                id: UUID(),
                author: roster[1],
                body: "Would love to see the template. Decision hygiene is showing up in almost every product conversation I am having.",
                timestamp: "Mon"
            )
        ]

        return [
            FeedPost(
                id: UUID(),
                author: roster[1],
                kind: .update,
                title: "Kicking off Scottsdale 2026",
                body: "Excited to start shaping the 2CI app around the real Scottsdale 2026 member experience.",
                timestamp: "Today",
                replies: [
                    FeedReply(
                        id: UUID(),
                        author: roster[1],
                        body: "First real Supabase-backed reply is alive.",
                        timestamp: "Today"
                    )
                ]
            ),
            FeedPost(
                id: UUID(),
                author: roster[0],
                kind: .prompt,
                title: "What conversation are you avoiding?",
                body: "One prompt for the week: what is the hard conversation sitting on your calendar, and what would make it cleaner by Friday?",
                timestamp: "Today",
                replies: promptReplies
            ),
            FeedPost(
                id: UUID(),
                author: roster[2],
                kind: .update,
                title: "Chicago next week",
                body: "I will be downtown Tuesday through Thursday. If anyone wants coffee before 9, I would love to compare notes on ops planning.",
                timestamp: "Yesterday",
                replies: travelReplies
            ),
            FeedPost(
                id: UUID(),
                author: roster[4],
                kind: .resource,
                title: "A decision memo format that travels well",
                body: "Sharing the one-page format I used with exec teams when the room had strong opinions and weak alignment.",
                timestamp: "Mon",
                replies: resourceReplies
            ),
            FeedPost(
                id: UUID(),
                author: roster[3],
                kind: .milestone,
                title: "First enterprise close",
                body: "The new sales motion landed its first enterprise customer. It took longer than planned and taught us more than the win itself.",
                timestamp: "Fri",
                replies: []
            )
        ]
    }

    func currentCohort() -> Cohort {
        Cohort(
            id: UUID(),
            name: "Scottsdale 2026",
            city: "Scottsdale",
            dates: "March 11-12, 2026",
            scenario: "Sunrise Scenario",
            status: "Complete",
            members: members().filter { $0.cohort == "Scottsdale 2026" || $0.role == .admin },
            photos: 18
        )
    }

    func notificationPreferences() -> [NotificationPreference] {
        [
            NotificationPreference(id: UUID(), title: "Feed activity", channels: "Push, In-app", isEnabled: true),
            NotificationPreference(id: UUID(), title: "Direct messages", channels: "Push, Email", isEnabled: true),
            NotificationPreference(id: UUID(), title: "Travel flags", channels: "Push, SMS", isEnabled: true),
            NotificationPreference(id: UUID(), title: "Coaching nudges", channels: "Email", isEnabled: false)
        ]
    }
}
