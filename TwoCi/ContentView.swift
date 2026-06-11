import SwiftUI

struct ContentView: View {
    private let store: MockDataStore
    @State private var feedPosts: [FeedPost]

    init() {
        let store = MockDataStore()
        self.store = store
        _feedPosts = State(initialValue: store.posts())
    }

    var body: some View {
        TabView {
            FeedView(posts: $feedPosts, currentMember: store.currentMember())
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            DirectoryView(members: store.members())
                .tabItem {
                    Label("Directory", systemImage: "person.2.fill")
                }

            CohortView(cohort: store.currentCohort())
                .tabItem {
                    Label("Cohort", systemImage: "circle.hexagongrid.fill")
                }

            ProfileView(
                member: store.currentMember(),
                preferences: store.notificationPreferences()
            )
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
        .tint(AppTheme.navy)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
