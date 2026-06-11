import SwiftUI

enum AppTheme {
    static let navy = Color(red: 0.094, green: 0.137, blue: 0.247)
    static let cream = Color(red: 0.973, green: 0.953, blue: 0.918)
    static let powderBlue = Color(red: 0.729, green: 0.839, blue: 0.922)
    static let oxblood = Color(red: 0.439, green: 0.098, blue: 0.239)
    static let ink = Color(red: 0.092, green: 0.107, blue: 0.145)
    static let muted = Color(red: 0.400, green: 0.430, blue: 0.490)

    static let pageBackground = cream
    static let cardBackground = Color.white.opacity(0.88)
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.navy.opacity(0.08), lineWidth: 1)
            )
    }
}

