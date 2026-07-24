import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    private let store: MockDataStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentMember: Member
    @State private var members: [Member]
    @State private var preferences: [NotificationPreference]
    @State private var feedPosts: [FeedPost]
    @State private var cohort: Cohort
    @State private var isLoadingSupabaseData = false
    @State private var dataSourceMessage: String?

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
        _cohort = State(initialValue: store.currentCohort())
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
        .task(id: authManager.accessToken) {
            await loadSupabaseDataIfAvailable()
        }
        .preferredColorScheme(.light)
    }

    private var mainApp: some View {
        TabView {
            FeedView(posts: $feedPosts, currentMember: currentMember)
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .accessibilityLabel("Feed")

            DirectoryView(members: members)
                .tabItem {
                    Image(systemName: "person.2.fill")
                }
                .accessibilityLabel("Directory")

            CohortView(cohort: cohort)
                .tabItem {
                    Image(systemName: "circle.hexagongrid.fill")
                }
                .accessibilityLabel("Cohort")

            ProfileView(member: currentMember, preferences: $preferences)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                }
                .accessibilityLabel("Profile")
        }
        .tint(AppTheme.navy)
        .overlay(alignment: .top) {
            if isLoadingSupabaseData {
                ProgressView()
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
        }
    }

    private func applyCurrentMember() {
        members = members.map { member in
            member.id == currentMember.id ? currentMember : member
        }

        feedPosts = feedPosts.map { post in
            post.author.id == currentMember.id ? post.withAuthor(currentMember) : post
        }
    }

    private func loadSupabaseDataIfAvailable() async {
        guard let accessToken = authManager.accessToken, let userID = authManager.userID else {
            dataSourceMessage = "Using demo data"
            return
        }

        isLoadingSupabaseData = true

        do {
            let data = try await SupabaseDataService(accessToken: accessToken, userID: userID).loadAppData()
            currentMember = data.currentMember
            members = data.members
            preferences = data.preferences
            feedPosts = data.posts
            cohort = data.cohort
            hasCompletedOnboarding = true
            dataSourceMessage = "Using Supabase data"
        } catch {
            dataSourceMessage = "Using demo data"
        }

        isLoadingSupabaseData = false
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
