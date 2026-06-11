import SwiftUI

struct DirectoryView: View {
    let members: [Member]
    @State private var selectedFilter = DirectoryFilter.function
    @State private var selectedValue = "All"

    var filterOptions: [String] {
        let values: [String]

        switch selectedFilter {
        case .function:
            values = members.map(\.function)
        case .city:
            values = members.map(\.city)
        case .cohort:
            values = members.map(\.cohort)
        case .affinity:
            values = members.flatMap { $0.labels.map(\.name) }
        }

        return ["All"] + Array(Set(values)).sorted()
    }

    var filteredMembers: [Member] {
        if selectedValue == "All" {
            return members
        }

        switch selectedFilter {
        case .function:
            return members.filter { $0.function == selectedValue }
        case .city:
            return members.filter { $0.city == selectedValue }
        case .cohort:
            return members.filter { $0.cohort == selectedValue }
        case .affinity:
            return members.filter { member in
                member.labels.contains { $0.name == selectedValue }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BrandHeader(
                        title: "Directory",
                        subtitle: "Find the member who has seen the version of the problem you are in."
                    )

                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(DirectoryFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedFilter) {
                        selectedValue = "All"
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filterOptions, id: \.self) { value in
                                Button {
                                    selectedValue = value
                                } label: {
                                    LabelChip(text: value, isSelected: selectedValue == value)
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

private enum DirectoryFilter: String, CaseIterable, Identifiable {
    case function = "Function"
    case city = "City"
    case cohort = "Cohort"
    case affinity = "Affinity"

    var id: String { rawValue }
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
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        AvatarView(member: member, size: 76)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(member.name)
                                .font(.title.bold())
                                .foregroundStyle(AppTheme.ink)

                            Text("\(member.title), \(member.company)")
                                .font(.headline)
                                .foregroundStyle(AppTheme.ink.opacity(0.82))

                            RoleBadge(role: member.role)
                        }
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Role & Context")
                        .font(.headline)

                    ProfileFactRow(label: "Company", value: member.company)
                    ProfileFactRow(label: "City", value: member.city)
                    ProfileFactRow(label: "Cohort", value: member.cohort)
                    ProfileFactRow(label: "Function", value: member.function)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 8) {
                    Text("2CI layer")
                        .font(.headline)

                    Text(member.challenge)
                        .foregroundStyle(AppTheme.ink.opacity(0.82))

                    FlowLayout(items: member.labels.map(\.name))
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Contact")
                        .font(.headline)

                    Text("Members control what contact paths are visible. Direct messages and SMS will route through member preferences when those integrations are live.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)

                    Link(destination: URL(string: "mailto:\(member.email)")!) {
                        ContactActionRow(title: "Email", detail: member.email, systemImage: "envelope.fill")
                    }
                    .buttonStyle(.plain)

                    ContactActionRow(title: "Message", detail: "Coming in the messaging slice", systemImage: "bubble.left.and.bubble.right.fill", isEnabled: false)

                    ContactActionRow(title: "SMS", detail: "Hidden until member enables phone visibility", systemImage: "message.fill", isEnabled: false)
                }
                .cardStyle()
            }
            .padding(20)
        }
        .background(AppTheme.pageBackground)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfileFactRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
                .frame(width: 72, alignment: .leading)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
        }
    }
}

private struct ContactActionRow: View {
    let title: String
    let detail: String
    let systemImage: String
    var isEnabled = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(isEnabled ? AppTheme.navy : AppTheme.muted)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isEnabled ? AppTheme.ink : AppTheme.muted)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            if isEnabled {
                Image(systemName: "arrow.up.forward")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.navy)
            }
        }
        .padding(12)
        .background((isEnabled ? AppTheme.powderBlue : AppTheme.muted).opacity(isEnabled ? 0.18 : 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
