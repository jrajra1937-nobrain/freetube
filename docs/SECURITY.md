# Security review (initial source audit)

## Authentication finding: high risk; sign-in disabled

At the pinned upstream baseline, login used an embedded `WKWebView` pointed at Google's sign-in page, then captured Google/YouTube cookies and replayed them as request headers. This was not OAuth. Possession of those cookies can grant account access until expiration/revocation.

Source findings:

- The upstream `LoginWebView.swift` created an ephemeral WKWebView and `LoginCoordinator.swift` captured cookies. Both files and the login screen were removed from the Personal Edition.
- The active `CookieStore` can only delete the legacy Keychain item; there is no code path to read or write account cookies.
- `SessionManager` does not restore cookies at launch. Bootstrap attempts to delete the legacy Keychain item and resets client cookies and visitor data; sign-out also clears local subscription state.
- Legacy diagnostics previously logged cookie metadata. Cookie capture and raw log export have been removed.

The Google sign-in flow and cookie-capture sources have been removed. The app remains usable for public content without an account. Do not reintroduce cookie sign-in. Use no credentials in CI. Keep passwords, authorization headers, visitor tokens, and signed stream URLs out of logs, crash reports, analytics, and remote services.

## Official OAuth feasibility

Official Google OAuth is technically feasible for a native iOS app using a supported system-browser/native sign-in flow and the YouTube Data API for the endpoints that API actually exposes. Google explicitly says OAuth authorization must not be opened in an embedded user-agent such as `WKWebView`; its recommended route is a native OAuth library/system browser. The current WKWebView credential-and-cookie capture is therefore not an acceptable design for an official Google OAuth flow, even though this app currently captures cookies rather than OAuth tokens.

OAuth plus YouTube Data API is not a drop-in replacement for YouTubeKit: it needs a registered Google Cloud project, OAuth client configuration, user consent, scopes, and API quota. Google's published default quota is finite and search has its own 100-call/day allocation; a personal app can stay within free quota, but that is still a usage limit. Official endpoints can cover some account resources and writes, but do not provide arbitrary AVPlayer stream URLs, personalized home parity, or full watch-history parity. Avoid claiming that OAuth alone makes all current features work.

Practical direction after the baseline build: keep anonymous browsing/playback separate; evaluate native OAuth specifically for API-supported account operations; disable account features unavailable through official endpoints. Do not collect Google passwords or replay browser cookies. This needs an implementation decision and tests before account sign-in is enabled.

References:

- [Google OAuth 2.0 policies](https://developers.google.com/identity/protocols/oauth2/policies)
- [Google OAuth best practices](https://developers.google.com/identity/protocols/oauth2/resources/best-practices)
- [YouTube Data API authentication](https://developers.google.com/youtube/data/guides/authentication)
- [YouTube Data API quota](https://developers.google.com/youtube/data/getting-started#quota)

## Controls implemented in the current working tree

- Cookie ingestion and login UI were removed. The minimal Keychain helper only deletes the legacy session item; cleanup failures surface as a generic status error.
- Account sign-in is unavailable pending a supported official OAuth/API design. Anonymous/public browsing remains available.
- Signed media URLs and Python/yt-dlp stderr are no longer intentionally emitted to the app logger or stored in a raw diagnostic file. The legacy log-file exporter and sharing UI are disabled; existing files in `Documents/Logs` are cleared on writer initialization.
- Disabled yt-dlp's TLS certificate-verification bypass in both downloads and metadata probes. Python may now fail closed if the embedded runtime has no trusted CA bundle; verify this on the first device/CI run and add a properly sourced CA bundle if needed.
- Removed alternate TVHTML5/embed player profiles, `formats=missing_pot`, and direct URL fallback code that the upstream comments explicitly described as exempt from Proof-of-Origin checks. Playback now fails when the standard extraction/player paths do not provide media.
- Sign-out clears in-memory authentication even when Keychain deletion fails and reports a generic error to the user.

These are source changes and have not yet been compiled or runtime-tested.

## Risks and required work

1. Embedded Google password entry/cookie extraction may conflict with Google-supported sign-in expectations and puts high-value session tokens inside an unofficial client. Official OAuth should be evaluated; YouTube Data API OAuth requires a registered client and user consent and does not by itself replace YouTubeKit's private web endpoints or guarantee feature parity.
2. Complete review of Keychain accessibility class, device-only protection, access group, and sign-out failure recovery. If Keychain deletion fails, the in-memory app is signed out; the next launch does not apply any legacy cookie, but the stale Keychain item may remain.
3. Inspect JavaScriptCore bridge inputs and bundled yt-dlp scripts for untrusted-source execution boundaries; do not execute user-provided JavaScript.
4. Audit HTTP clients for cookie/header scope, redirects, TLS handling, URL redaction and cross-host leakage.
5. Continue reviewing `os.Logger` interpolation throughout the repository; some existing call sites still include video IDs, titles, local paths, or error descriptions and need privacy minimization.
6. Verify legacy Keychain cleanup and account-state clearing on a physical iPhone.
7. Review downloads and embedded third-party packages, licensing, update cadence, and supply-chain risk.

No penetration test or runtime security test has been performed. This remains a partial source-level review, not a security certification.
