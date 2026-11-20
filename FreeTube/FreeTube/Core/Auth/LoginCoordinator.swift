import Foundation
import Combine
import WebKit
import OSLog

/// Legacy cookie-login coordinator. The account screen no longer exposes this flow because
/// embedded Google credential collection is not an approved OAuth mechanism.
/// - Loads `accounts.google.com`.
/// - Watches for redirects to `youtube.com` after sign-in.
/// - Reads cookies from `WKWebsiteDataStore.default().httpCookieStore`.
/// - Verifies all required cookies (`SAPISID`, `__Secure-3PAPISID`, `LOGIN_INFO`, `SID`, `HSID`,
///   `SSID`, `APISID`) are present before storing the cookie header in Keychain.
@available(iOS 17.0, *)
@MainActor
final class LoginCoordinator: NSObject, ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case awaitingCredentials
        case verifying
        case succeeded
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    func resetState() {
        state = .idle
    }

    private let log = AppLog(subsystem: "com.leshko.freetube", category: "LoginCoordinator")
    private let session = SessionManager.shared

    /// Start URL that tells Google "this is a YouTube sign-in" via the `service=youtube` and
    /// `continue=youtube.com/signin?...` parameters. Without these, accounts.google.com just
    /// returns to `myaccount.google.com` after successful login and never visits YouTube — so
    /// no YouTube cookies (SAPISID, LOGIN_INFO, etc.) are ever set in the WKWebView's data
    /// store, and the login flow silently captures nothing. Forcing the post-login bounce to
    /// `youtube.com` is the same trick yt-dlp / NewPipe / Invidious use for browser-based auth.
    static let startURL: URL = {
        var components = URLComponents(string: "https://accounts.google.com/ServiceLogin")!
        components.queryItems = [
            URLQueryItem(name: "service", value: "youtube"),
            URLQueryItem(name: "uilel", value: "3"),
            URLQueryItem(name: "passive", value: "true"),
            URLQueryItem(name: "continue", value: "https://www.youtube.com/signin?action_handle_signin=true&next=%2F")
        ]
        return components.url!
    }()
    /// Fallback URL to load if we detect Google sign-in completed but the redirect to YouTube
    /// didn't happen automatically (some accounts land on `myaccount.google.com` after sign-in).
    /// Loading youtube.com directly causes YouTube's edge to set its session cookies (SAPISID,
    /// LOGIN_INFO, …) for the now-authenticated Google session.
    static let youTubeLandingURL = URL(string: "https://www.youtube.com/")!

    func handleNavigation(to url: URL?, in webView: WKWebView) {
        guard let url else {
            log.debug("[login] handleNavigation called with nil url")
            return
        }
        guard let host = url.host else { return }
        if CookieDomainPolicy.isYouTubeHost(host) {
            state = .verifying
            Task { await captureCookies(from: webView) }
            return
        }
        if isPostSignInGoogleURL(url) {
            webView.load(URLRequest(url: Self.youTubeLandingURL))
        }
    }

    /// Heuristic for "Google login completed, now on an account-management page". When we see
    /// one of these, we know the credentials were accepted but the OAuth-style continue redirect
    /// to youtube.com didn't happen for some reason — so we bounce manually.
    private func isPostSignInGoogleURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        if host == "myaccount.google.com" { return true }
        if host == "accounts.google.com" {
            // accounts.google.com/b/0/ManageAccount, /InteractiveLogin/CheckCookie, etc. show up
            // after a successful interactive sign-in.
            let path = url.path.lowercased()
            return path.contains("manageaccount") || path.contains("checkcookie") || path.contains("/b/")
        }
        return false
    }

    private func captureCookies(from webView: WKWebView) async {
        // Cookies are written to the shared store asynchronously after navigation commits.
        // Reading immediately on `didCommit` sometimes misses the freshest YT cookies, so we
        // also re-check on `didFinish` — the coordinator gets both callbacks. To keep this
        // method idempotent, only do the keychain write when we have the full required set.
        let cookies = await webView.configuration.websiteDataStore.httpCookieStore.allCookies()
        guard let header = CookieStore.shared.makeHeader(from: cookies) else {
            // Stay in `.verifying` so the next navigation callback gets another shot — don't
            // flip to `.failed` here. The user can still tap Cancel to abort.
            return
        }
        do {
            try await session.signIn(with: header)
            state = .succeeded
        } catch {
            log.error("[login] secure session persistence failed")
            state = .failed("The session could not be stored securely. Sign-in was cancelled.")
        }
    }
}
