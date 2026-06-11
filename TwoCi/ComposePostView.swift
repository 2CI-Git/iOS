import SwiftUI

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    let author: Member
    let onPost: (FeedPost) -> Void

    @State private var kind: FeedPostKind = .update
    @State private var title = ""
    @State private var bodyText = ""

    private let memberPostKinds: [FeedPostKind] = [.update, .resource, .milestone]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $kind) {
                        ForEach(memberPostKinds, id: \.rawValue) { kind in
                            Text(kind.rawValue).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Title", text: $title)

                    TextField("What do you want to share?", text: $bodyText, axis: .vertical)
                        .lineLimit(5...10)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(!canPost)
                }
            }
        }
    }

    private var canPost: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func createPost() {
        let post = FeedPost(
            id: UUID(),
            author: author,
            kind: kind,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: "Just now",
            replies: []
        )

        onPost(post)
        dismiss()
    }
}
