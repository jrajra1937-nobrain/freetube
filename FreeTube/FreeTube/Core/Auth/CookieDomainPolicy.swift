import Foundation

/// Allow-list for hosts and cookie domains used by the legacy YouTube session flow.
/// Matching requires a DNS label boundary, so `evil-youtube.com` and
/// `youtube.com.attacker.example` are rejected.
enum CookieDomainPolicy {
    static func isYouTubeHost(_ host: String) -> Bool {
        matches(host, baseDomain: "youtube.com")
    }

    static func isYouTubeCookieDomain(_ domain: String) -> Bool {
        matches(domain, baseDomain: "youtube.com")
    }

    private static func matches(_ value: String, baseDomain: String) -> Bool {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return normalized == baseDomain || normalized.hasSuffix("." + baseDomain)
    }
}
