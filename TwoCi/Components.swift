import SwiftUI

struct BrandHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title.bold())
                .foregroundStyle(AppTheme.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LabelChip: View {
    let text: String
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(isSelected ? Color.white : AppTheme.navy)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? AppTheme.navy : AppTheme.powderBlue.opacity(0.42))
            .clipShape(Capsule())
    }
}

struct RoleBadge: View {
    let role: MemberRole

    var body: some View {
        Text(role.rawValue)
            .font(.caption2.weight(.bold))
            .foregroundStyle(role == .council ? AppTheme.oxblood : AppTheme.navy)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background((role == .council ? AppTheme.oxblood : AppTheme.powderBlue).opacity(0.14))
            .clipShape(Capsule())
    }
}

struct AvatarView: View {
    let member: Member
    var size: CGFloat = 48

    var initials: String {
        member.name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }

    private var imageName: String? {
        switch member.email.lowercased() {
        case "ryanblakewilson@gmail.com":
            return "RyanProfile"
        case "mark@2ci.com":
            return "MarkProfile"
        default:
            return nil
        }
    }

    var body: some View {
        ZStack {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(member.role == .council ? AppTheme.oxblood : AppTheme.navy)

                Text(initials)
                    .font(.system(size: size * 0.34, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.88), lineWidth: max(1, size * 0.035))
        )
    }
}

func displayPlace(_ value: String) -> String {
    value.localizedCaseInsensitiveContains("scottsdale") ? "🌵 \(value)" : value
}
