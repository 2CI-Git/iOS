import Foundation

enum SupabaseConfig {
    static let projectURL = URL(string: "https://rpdnwkpenataotqiejxq.supabase.co")!
    static let publishableKey = "sb_publishable_SI_23uv-Zy7ZqN1VWr73NA_dJ30jQeV"

    static var defaultHeaders: [String: String] {
        [
            "apikey": publishableKey,
            "Authorization": "Bearer \(publishableKey)",
            "Content-Type": "application/json"
        ]
    }
}
