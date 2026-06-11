import SwiftUI

struct ContentView: View {
    private let store: MockDataStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentMember: Member
    @State private var members: [Member]
    @State private var preferences: [NotificationPreference]
    @State private var feedPosts: [FeedPost]

    init() {
        let store = MockDataStore()
        let members = store.members()
        let currentMember = members[1]

        self.store = store
        _currentMember = State(initialValue: currentMember)
        _members = State(initialValue: members)
        _preferences = State(initialValue: store.notificationPreferences())
        _feedPosts = State(initialValue: store.posts().map { post in
            post.author.id == currentMember.id ? post.withAuthor(currentMember) : post
        })
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainApp
            } else {
                OnboardingView(
                    member: $currentMember,
                    preferences: $preferences,
                    availableLabels: store.labels
                ) {
                    applyCurrentMember()
                    hasCompletedOnboarding = true
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var mainApp: some View {
        TabView {
            FeedView(posts: $feedPosts, currentMember: currentMember)
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            DirectoryView(members: members)
                .tabItem {
                    Label("Directory", systemImage: "person.2.fill")
                }

            CohortView(cohort: store.currentCohort())
                .tabItem {
                    Label("Cohort", systemImage: "circle.hexagongrid.fill")
                }

            ProfileView(member: currentMember, preferences: $preferences)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(AppTheme.navy)
    }

    private func applyCurrentMember() {
        members = members.map { member in
            member.id == currentMember.id ? currentMember : member
        }

        feedPosts = feedPosts.map { post in
            post.author.id == currentMember.id ? post.withAuthor(currentMember) : post
        }
    }
}

#Preview {
    ContentView()
}

private extension FeedPost {
    func withAuthor(_ author: Member) -> FeedPost {
        FeedPost(
            id: id,
            author: author,
            kind: kind,
            title: title,
            body: body,
            timestamp: timestamp,
            replies: replies
        )
    }
}
