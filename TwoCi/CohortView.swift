import SwiftUI

struct CohortView: View {
    let cohort: Cohort

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BrandHeader(
                        title: cohort.name,
                        subtitle: "Your crew, shared history, and the thread back to the room."
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label(displayPlace(cohort.city), systemImage: "mappin.and.ellipse")
                            Spacer()
                            Text(cohort.status)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.oxblood)
                                .clipShape(Capsule())
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.navy)

                        Text(cohort.scenario)
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.ink)

                        Text(cohort.dates)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .cardStyle()

                    HStack(spacing: 12) {
                        StatTile(value: "\(cohort.members.count)", label: "Members")
                        StatTile(value: "\(cohort.photos)", label: "Photos")
                        StatTile(value: "1", label: "Channel")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cohort channel")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        Text("A private channel for memory, follow-ups, and the stuff that only makes sense to the people who were in the room.")
                            .foregroundStyle(AppTheme.ink.opacity(0.82))

                        Button {
                        } label: {
                            Label("Open channel", systemImage: "bubble.left.and.text.bubble.right.fill")
                                .font(.headline)
                                .foregroundStyle(AppTheme.navy)
                        }
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Members")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        ForEach(cohort.members) { member in
                            MemberCard(member: member)
                        }
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

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(AppTheme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
