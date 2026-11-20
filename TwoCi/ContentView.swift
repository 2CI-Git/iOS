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
    @State private var dataSource: DataSourceStatus = .demo

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
            DataSourceBanner(status: dataSource)
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
            dataSource = .demo
            print("[2CI] No Supabase session. Showing demo data.")
            return
        }

        dataSource = .loading

        do {
            let data = try await SupabaseDataService(accessToken: accessToken, userID: userID).loadAppData()
            currentMember = data.currentMember
            members = data.members
            preferences = data.preferences
            feedPosts = data.posts
            cohort = data.cohort
            hasCompletedOnboarding = true
            dataSource = .live
            print("""
            [2CI] Loaded live Supabase data. \
            members=\(data.members.count) posts=\(data.posts.count) \
            preferences=\(data.preferences.count)
            """)
        } catch {
            // Deliberately does NOT present as demo data. The app keeps showing
            // whatever it already had, but the banner says the live load failed
            // and the reason goes to the console. Silently degrading here is
            // what hid a completely empty database for three months.
            dataSource = .failed(error.localizedDescription)
            print("[2CI] Supabase load FAILED: \(error.localizedDescription)")
            print("[2CI] Underlying error: \(error)")
        }
    }
}

/// Which data the app is actually showing.
///
/// This exists because the app previously fell back to `MockDataStore` silently
/// whenever a Supabase load failed, which made a working backend and a broken
/// one look identical. Every state here is rendered on screen by
/// `DataSourceBanner`, so the answer to "am I looking at real data?" is always
/// visible rather than inferred.
enum DataSourceStatus: Equatable {
    /// No session yet, or signed out. Showing `MockDataStore` content.
    case demo
    /// A Supabase load is in flight.
    case loading
    /// Showing rows from Postgres.
    case live
    /// A Supabase load was attempted and failed. Still showing whatever was
    /// already on screen, but the reason is carried here and logged.
    case failed(String)

    var label: String {
        switch self {
        case .demo: "Demo data"
        case .loading: "Loading…"
        case .live: "Live"
        case .failed: "Live data failed"
        }
    }

    var detail: String? {
        if case .failed(let reason) = self { return reason }
        return nil
    }
}

/// A small persistent pill showing the current data source.
///
/// Deliberately always on screen. `live` is understated; anything else is
/// prominent, because the misleading state is the one that matters.
struct DataSourceBanner: View {
    let status: DataSourceStatus

    var body: some View {
        HStack(spacing: 6) {
            indicator
            Text(status.label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(foreground)

            if let detail = status.detail {
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(foreground.opacity(0.75))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(background, in: Capsule())
        .overlay(Capsule().stroke(foreground.opacity(0.22), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var indicator: some View {
        switch status {
        case .loading:
            ProgressView()
                .controlSize(.mini)
        default:
            Circle()
                .fill(foreground)
                .frame(width: 6, height: 6)
        }
    }

    private var foreground: Color {
        switch status {
        case .live: Color(red: 0.090, green: 0.420, blue: 0.231)
        case .demo, .loading: AppTheme.muted
        case .failed: AppTheme.oxblood
        }
    }

    private var background: Color {
        switch status {
        case .live: Color(red: 0.090, green: 0.420, blue: 0.231).opacity(0.10)
        case .demo, .loading: AppTheme.navy.opacity(0.06)
        case .failed: AppTheme.oxblood.opacity(0.10)
        }
    }

    private var accessibilityText: String {
        if let detail = status.detail {
            return "\(status.label). \(detail)"
        }
        return status.label
    }
}

#Preview {
    ContentView()
}

#Preview("Data source banner") {
    VStack(spacing: 12) {
        DataSourceBanner(status: .demo)
        DataSourceBanner(status: .loading)
        DataSourceBanner(status: .live)
        DataSourceBanner(status: .failed("member_profiles failed (401)."))
    }
    .padding()
    .background(AppTheme.pageBackground)
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
