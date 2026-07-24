import SwiftUI

struct FeedDetailView: View {
    @Binding var post: FeedPost
    let currentMember: Member
    @State private var replyText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 12) {
                        AvatarView(member: post.author, size: 56)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(post.author.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)

                                RoleBadge(role: post.author.role)
                            }

                            Text("\(post.author.title), \(post.author.company) · \(post.timestamp)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.muted)
                        }
                    }

                    LabelChip(text: post.kind.rawValue, isSelected: post.kind == .prompt)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(post.title)
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.ink)

                        Text(post.body)
                            .font(.callout)
                            .lineSpacing(3)
                            .foregroundStyle(AppTheme.ink.opacity(0.84))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Replies")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    if post.replies.isEmpty {
                        Text("No replies yet.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(post.replies) { reply in
                            ReplyRow(reply: reply)
                        }
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Reply")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    TextField("Share a real response", text: $replyText, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        addReply()
                    } label: {
                        Label("Post Reply", systemImage: "arrow.up.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.navy)
                    .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .cardStyle()
            }
            .padding(20)
        }
        .background(AppTheme.pageBackground)
        .navigationTitle(post.kind.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addReply() {
        let trimmedReply = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReply.isEmpty else { return }

        post.replies.append(
            FeedReply(
                id: UUID(),
                author: currentMember,
                body: trimmedReply,
                timestamp: "Just now"
            )
        )
        replyText = ""
    }
}

private struct ReplyRow: View {
    let reply: FeedReply

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(member: reply.author, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(reply.author.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)

                    Text(reply.timestamp)
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                }

                Text(reply.body)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.ink.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
    }
}
