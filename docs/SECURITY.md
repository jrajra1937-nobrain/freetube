# Security review (initial source audit)

## Authentication finding: high risk, not approved for a primary account

The current login uses an embedded `WKWebView` pointed at Google's sign-in page, then captures Google/YouTube cookies and replays them as request headers. This is not OAuth. The app receives the session credentials represented by those cookies. While source code stores the serialized cookie header in Keychain and does not intentionally send it to a third-party server, possession of these cookies can grant account access until expiration/revocation.

Source findings:

- `LoginWebView.swift` creates an ephemeral, non-persistent WKWebView store for the login form.
- `LoginCoordinator.swift` reads cookies after navigation to YouTube and serializes required cookies.
- `CookieStore.swift` stores the resulting header via `KeychainHelper`; cookie values are not logged in the inspected capture paths.
- `SessionManager.signOut()` clears the Keychain cookie, resets client cookies, clears the visitor token and local subscription cache. Web data clearing targets the default store, whereas login uses a non-persistent store; confirm actual web-view cleanup behavior.
- Diagnostics currently log cookie names, domains, lengths, counts, and the cookie-header length. This avoids literal values but reveals account/session metadata and should be minimized.

Until deeper review and device validation, do not sign in with a main/personal Google account. Use no credentials in CI. Keep cookies, passwords, headers, visitor tokens, and signed stream URLs out of logs, crash reports, analytics, and remote services.

## Official OAuth feasibility

Official Google OAuth is technically feasible for a native iOS app using a supported system-browser/native sign-in flow and the YouTube Data API for the endpoints that API actually exposes. Google explicitly says OAuth authorization must not be opened in an embedded user-agent such as `WKWebView`; its recommended route is a native OAuth library/system browser. The current WKWebView credential-and-cookie capture is therefore not an acceptable design for an official Google OAuth flow, even though this app currently captures cookies rather than OAuth tokens.

OAuth plus YouTube Data API is not a drop-in replacement for YouTubeKit: it needs a registered Google Cloud project, OAuth client configuration, user consent, scopes, and API quota. Google's published default quota is finite and search has its own 100-call/day allocation; a personal app can stay within free quota, but that is still a usage limit. Official endpoints can cover some account resources and writes, but do not provide arbitrary AVPlayer stream URLs, personalized home parity, or full watch-history parity. Avoid claiming that OAuth alone makes all current features work.

Practical direction after the baseline build: keep anonymous browsing/playback separate; evaluate native OAuth specifically for API-supported account operations; disable account features unavailable through official endpoints. Do not collect Google passwords or replay browser cookies. This needs an implementation decision and tests before account sign-in is enabled.

References:

- [Google OAuth 2.0 policies](https://developers.google.com/identity/protocols/oauth2/policies)
- [Google OAuth best practices](https://developers.google.com/identity/protocols/oauth2/resources/best-practices)
- [YouTube Data API authentication](https://developers.google.com/youtube/data/guides/authentication)
- [YouTube Data API quota](https://developers.google.com/youtube/data/getting-started#quota)

## Risks and required work

1. Embedded Google password entry/cookie extraction may conflict with Google-supported sign-in expectations and puts high-value session tokens inside an unofficial client. Official OAuth should be evaluated; YouTube Data API OAuth requires a registered client and user consent and does not by itself replace YouTubeKit's private web endpoints or guarantee feature parity.
2. Confirm Keychain accessibility class, device-only protection, access group, error handling, and deletion semantics. `CookieStore.storeHeader` currently logs write failure but does not propagate it, while `SessionManager.signIn` marks the user logged in afterward; this can create a false authenticated state.
3. Inspect JavaScriptCore bridge inputs and bundled yt-dlp scripts for untrusted-source execution boundaries; do not execute user-provided JavaScript.
4. Audit HTTP clients for cookie/header scope, redirects, TLS handling, URL redaction and cross-host leakage.
5. Review `os.Logger` interpolation throughout the repository; search for URLs, request bodies, cookie-like values, and user-entered text.
6. Confirm sign-out removes cookies from the actual ephemeral WebKit data store and all local account-specific state.
7. Review downloads and embedded third-party packages, licensing, update cadence, and supply-chain risk.

No penetration test or runtime security test has been performed. This is a source-level initial review, not a security certification.
