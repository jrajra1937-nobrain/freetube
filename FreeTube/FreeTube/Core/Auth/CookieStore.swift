import Foundation

/// Persists the YouTube cookie header string in the Keychain. Per CLAUDE.md §2 cookies must
/// never touch disk, `UserDefaults`, plist, or logs — only Keychain in-memory access at runtime.
final class CookieStore {
    static let shared = CookieStore()

    static let keychainKey = "com.leshko.freetube.cookies"

    /// CLAUDE.md §9 list. Login is only considered successful when *all* of these are present.
    static let requiredCookieNames: Set<String> = [
        "SAPISID",
        "__Secure-3PAPISID",
        "LOGIN_INFO",
        "SID",
        "HSID",
        "SSID",
        "APISID"
    ]

    private init() {}

    func storeHeader(_ header: String) throws {
        try KeychainHelper.set(header, for: Self.keychainKey)
    }

    func loadHeader() -> String? {
        KeychainHelper.string(for: Self.keychainKey)
    }

    func clear() throws {
        try KeychainHelper.delete(Self.keychainKey)
    }

    /// Builds a `Cookie:` header string from secure YouTube-scoped `HTTPCookie` values.
    /// cookies and **deduplicates by name**, preferring the entry with the most general domain
    /// scope.
    ///
    /// Why the dedupe matters: when the WKWebView's redirect chain visits
    /// `accounts.google.com → m.youtube.com → www.youtube.com`, YouTube sets multiple cookies
    /// with the same name but different domain attributes — e.g. one `SID` scoped to
    /// `m.youtube.com` and another scoped to `.youtube.com`. Concatenating both into a single
    /// `Cookie:` header sends `SID=mobile; SID=cross-domain;`, and YouTube's server picks one
    /// (often the first) which can be the mobile-only value that fails to validate at
    /// `www.youtube.com/youtubei/v1/...`. Picking the broadest-domain variant per name fixes
    /// the resulting "logged out despite valid cookies" symptom.
    func makeHeader(from cookies: [HTTPCookie]) -> String? {
        let scoped = cookies.filter {
            $0.isSecure && CookieDomainPolicy.isYouTubeCookieDomain($0.domain)
        }

        // **Preference rules** (in order of priority — first wins):
        // Prefer a cookie scoped to `.youtube.com`, then the broadest YouTube subdomain.
        func rank(_ cookie: HTTPCookie) -> (Int, Int) {
            let dotFlag = cookie.domain.hasPrefix(".") ? 0 : 1
            return (dotFlag, cookie.domain.count)
        }
        let grouped = Dictionary(grouping: scoped, by: \.name)
        var chosen: [HTTPCookie] = []
        for (_, duplicates) in grouped {
            guard let best = duplicates.min(by: { rank($0) < rank($1) }) else { continue }
            chosen.append(best)
        }

        let chosenNames = Set(chosen.map(\.name))
        let missing = Self.requiredCookieNames.subtracting(chosenNames).sorted()
        guard missing.isEmpty else {
            return nil
        }
        let header = chosen.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")

        return header
    }
}
