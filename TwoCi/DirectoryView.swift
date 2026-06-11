import SwiftUI

struct DirectoryView: View {
    let members: [Member]
    @State private var selectedFunction = "All"

    var functions: [String] {
        ["All"] + Array(Set(members.map(\.function))).sorted()
    }

    var filteredMembers: [Member] {
        if selectedFunction == "All" {
            return members
        }
        return members.filter { $0.function == selectedFunction }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BrandHeader(
                        title: "Directory",
                        subtitle: "Find the member who has seen the version of the problem you are in."
                    )

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(functions, id: \.self) { function in
                                Button {
                                    selectedFunction = function
                                } label: {
                                    LabelChip(text: function, isSelected: selectedFunction == function)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    ForEach(filteredMembers) { member in
                        NavigationLink {
                            MemberDetailView(member: member)
                        } label: {
                            MemberCard(member: member)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.pageBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(AppTheme.navy.ignoresSafeArea())
    }
}

struct MemberCard: View {
    let member: Member

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AvatarView(member: member, size: 56)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    RoleBadge(role: member.role)
                }

                Text("\(member.title), \(member.company)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)

                Text("\(member.city) · \(member.cohort)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.navy)

                FlowLayout(items: member.labels.map(\.name))
            }
        }
        .cardStyle()
    }
}

struct MemberDetailView: View {
    let member: Member

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 16) {
                    AvatarView(member: member, size: 76)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(member.name)
                            .font(.title.bold())
                            .foregroundStyle(AppTheme.ink)
                        RoleBadge(role: member.role)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(member.title)
                        .font(.headline)
                    Text(member.company)
                    Text(member.city)
                }
                .foregroundStyle(AppTheme.ink)
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    Text("2CI layer")
                        .font(.headline)
                    Text(member.challenge)
                        .foregroundStyle(AppTheme.ink.opacity(0.82))
                    FlowLayout(items: member.labels.map(\.name))
                }
                .cardStyle()

                Button {
                } label: {
                    Label("Reach out", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(AppTheme.navy)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(20)
        }
        .background(AppTheme.pageBackground)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FlowLayout: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                LabelChip(text: item)
            }
        }
    }
}
