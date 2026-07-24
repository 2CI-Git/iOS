import SwiftUI

struct OnboardingView: View {
    @Binding var member: Member
    @Binding var preferences: [NotificationPreference]
    let availableLabels: [AffinityLabel]
    let onComplete: () -> Void

    @State private var step = 0

    private let stepTitles = ["Profile", "2CI Layer", "Affinity", "Notifications"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: Double(stepTitles.count))
                    .tint(AppTheme.navy)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(stepTitles[step])
                            .font(.title.bold())
                            .foregroundStyle(AppTheme.ink)

                        currentStep
                    }
                    .padding(20)
                }

                HStack(spacing: 12) {
                    if step > 0 {
                        Button {
                            step -= 1
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.navy)
                    }

                    Button {
                        if step == stepTitles.count - 1 {
                            onComplete()
                        } else {
                            step += 1
                        }
                    } label: {
                        Label(step == stepTitles.count - 1 ? "Enter 2CI" : "Continue", systemImage: step == stepTitles.count - 1 ? "checkmark.circle.fill" : "chevron.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.navy)
                    .disabled(!canContinue)
                }
                .padding(20)
                .background(AppTheme.cardBackground)
            }
            .background(AppTheme.pageBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 0:
            profileStep
        case 1:
            layerStep
        case 2:
            affinityStep
        default:
            notificationStep
        }
    }

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingIntro(text: "Confirm the basics members will see in the directory.")

            TextField("Name", text: $member.name)
                .textFieldStyle(.roundedBorder)

            TextField("Title", text: $member.title)
                .textFieldStyle(.roundedBorder)

            TextField("Company", text: $member.company)
                .textFieldStyle(.roundedBorder)

            TextField("City", text: $member.city)
                .textFieldStyle(.roundedBorder)

            TextField("Function", text: $member.function)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $member.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
        }
        .cardStyle()
    }

    private var layerStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingIntro(text: "Add the human context that makes the directory useful.")

            Text("Current challenge")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            TextField("What are you working through right now?", text: $member.challenge, axis: .vertical)
                .lineLimit(5...9)
                .textFieldStyle(.roundedBorder)
        }
        .cardStyle()
    }

    private var affinityStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingIntro(text: "Choose the labels that should help other members find you.")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                ForEach(availableLabels) { label in
                    Button {
                        toggleLabel(label)
                    } label: {
                        LabelChip(text: label.name, isSelected: member.labels.contains(label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .cardStyle()
    }

    private var notificationStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingIntro(text: "Set defaults now. Members can tune these later from Profile.")

            ForEach($preferences) { $preference in
                Toggle(isOn: $preference.isEnabled) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(preference.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)

                        Text(preference.channels)
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                    }
                }
                .tint(AppTheme.navy)
            }
        }
        .cardStyle()
    }

    private var canContinue: Bool {
        switch step {
        case 0:
            return !member.name.trimmed.isEmpty &&
                !member.title.trimmed.isEmpty &&
                !member.company.trimmed.isEmpty &&
                !member.city.trimmed.isEmpty &&
                !member.function.trimmed.isEmpty &&
                !member.email.trimmed.isEmpty
        case 1:
            return !member.challenge.trimmed.isEmpty
        case 2:
            return !member.labels.isEmpty
        default:
            return true
        }
    }

    private func toggleLabel(_ label: AffinityLabel) {
        if member.labels.contains(label) {
            member.labels.removeAll { $0 == label }
        } else {
            member.labels.append(label)
        }
    }
}

private struct OnboardingIntro: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(AppTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
