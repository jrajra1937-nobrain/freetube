import Foundation
import OSLog
import YouTubeKit

/// Holds the single `YouTubeModel` instance the rest of the app talks to. Services depend on this
/// type for the model handle and for cookie application.
///
/// Per CLAUDE.md §6: `YouTubeKit` must not be imported anywhere outside `Core/Networking/`. Domain
/// types (Video, Channel, …) are mapped from YouTubeKit response types inside the services that
/// own each response.
nonisolated final class YouTubeKitClient: @unchecked Sendable {
    static let shared = YouTubeKitClient()

    /// Default iOS-client model. Stream URLs are used only when the service returns playable media.
    let model = YouTubeModel()

    private let log = AppLog(subsystem: "com.leshko.freetube", category: "YouTubeKitClient")

    /// Current cookie header string as YouTubeKit holds it. Read-only mirror of
    /// `model.cookies` so callers outside this file don't have to touch YouTubeKit types
    /// directly (services without a YouTubeKit import — e.g. our raw-HTTP fallbacks — can
    /// still inject the auth header).
    var cookies: String { model.cookies }

    /// Drops the cached visitor token so the next request fetches a fresh one. Called by
    /// `SessionManager` after clearing cookies — the visitor token YouTube issued may have been
    /// tied to the now-expired auth.
    func clearVisitorData() { model.visitorData = "" }

    /// Pushes the latest cookie header string into `YouTubeModel`. Called by `SessionManager`.
    func applyCookies(_ cookies: String) {
        model.cookies = cookies
        model.alwaysUseCookies = !cookies.isEmpty

        log.info("[client] authentication state updated")
    }

    /// `VideoInfosResponse` requires a `visitorData` token. YouTubeKit doesn't fetch one for you;
    /// the canonical way to obtain it (per `YouTubeModel.visitorData` docs) is to run a `SearchResponse`
    /// first and pull `visitorData` out of the response. We do that once at app bootstrap and stash
    /// the token on the shared model so subsequent video requests auto-inject it.
    func ensureVisitorData() async {
        guard model.visitorData.isEmpty else { return }
        do {
            let response = try await SearchResponse.sendThrowingRequest(
                youtubeModel: model,
                data: [.query: "music"]
            )
            if let visitorData = response.visitorData, !visitorData.isEmpty {
                model.visitorData = visitorData
                log.info("Visitor data bootstrapped")
            } else {
                log.error("SearchResponse returned no visitorData")
            }
        } catch {
            log.error("Visitor-data bootstrap failed: \(String(describing: error), privacy: .public)")
        }
    }
}
