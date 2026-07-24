import SwiftUI

struct ProfileView: View {
    let member: Member
    @Binding var preferences: [NotificationPreference]
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BrandHeader(
                        title: "Your 2CI",
                        subtitle: "The profile layer LinkedIn does not know how to ask for."
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 16) {
                            AvatarView(member: member, size: 72)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(member.name)
                                    .font(.title3.bold())
                                Text("\(member.title), \(member.company)")
                                    .font(.callout)
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }

                        Text(member.challenge)
                            .font(.callout)
                            .foregroundStyle(AppTheme.ink.opacity(0.82))

                        FlowLayout(items: member.labels.map(\.name))
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Coaching")
                            .font(.headline)
                        Text("Monthly 1:1 with Mark is part of the program. This will deep-link to Calendly when the integration is live.")
                            .foregroundStyle(AppTheme.ink.opacity(0.82))

                        Button {
                        } label: {
                            Label("Schedule with Mark", systemImage: "calendar.badge.plus")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.oxblood)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notifications")
                            .font(.headline)

                        ForEach(preferences) { preference in
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: preference.isEnabled ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(preference.isEnabled ? AppTheme.navy : AppTheme.muted)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preference.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(preference.channels)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.muted)
                                }
                                Spacer()
                            }
                        }
                    }
                    .cardStyle()
                }
                .padding(20)
            }
            .background(AppTheme.pageBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Profile settings")
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                ProfileSettingsView(preferences: $preferences)
            }
        }
        .background(AppTheme.navy.ignoresSafeArea())
    }
}

private struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @Binding var preferences: [NotificationPreference]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($preferences) { $preference in
                        Toggle(isOn: $preference.isEnabled) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(preference.title)
                                    .font(.subheadline.weight(.semibold))

                                Text(preference.channels)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.muted)
                            }
                        }
                        .tint(AppTheme.navy)
                    }
                } header: {
                    Text("Notifications")
                }

                Section {
                    Button(role: .destructive) {
                        authManager.signOut()
                        dismiss()
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
