import SwiftUI

struct FeedView: View {
    @Binding var posts: [FeedPost]
    let currentMember: Member
    @State private var isShowingComposer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BrandHeader(
                        title: "Community",
                        subtitle: "The front door for what your people are thinking through."
                    )

                    ForEach($posts) { $post in
                        NavigationLink {
                            FeedDetailView(post: $post, currentMember: currentMember)
                        } label: {
                            FeedPostCard(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.pageBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingComposer = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("Create post")
                }
            }
            .sheet(isPresented: $isShowingComposer) {
                ComposePostView(author: currentMember) { post in
                    posts.insert(post, at: 0)
                }
            }
        }
        .background(AppTheme.navy.ignoresSafeArea())
    }
}

private struct FeedPostCard: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                AvatarView(member: post.author)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(post.author.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        RoleBadge(role: post.author.role)
                    }

                    Text("\(post.author.title), \(post.author.company) · \(post.timestamp)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                }
            }

            LabelChip(text: post.kind.rawValue, isSelected: post.kind == .prompt)

            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.ink)

                Text(post.body)
                    .font(.body)
                    .foregroundStyle(AppTheme.ink.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right")
                Text("\(post.replies.count) replies")
                Spacer()
                Image(systemName: "arrow.up.forward")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.navy)
            .padding(.top, 4)
        }
        .cardStyle()
    }
}
