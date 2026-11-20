import Foundation
import OSLog

/// Loads the persisted cookie header on launch and pushes it to YouTubeKit. Reacts to expiration by
/// clearing cookies and flipping `AuthState.shared.status = .loggedOut`.
@available(iOS 17.0, *)
@MainActor
final class SessionManager {
    static let shared = SessionManager()

    private let store = CookieStore.shared
    private let client = YouTubeKitClient.shared
    private let log = AppLog(subsystem: "com.leshko.freetube", category: "SessionManager")

    private init() {}

    /// Call exactly once during `FreeTubeApp.init` or `RootView.onAppear`.
    func bootstrap() async {
        // Do not silently reuse legacy cookie-capture sessions. Account sign-in stays
        // disabled until a supported OAuth/API path replaces this mechanism.
        try? store.clear()
        client.applyCookies("")
        AuthState.shared.status = .loggedOut
        log.info("[session] anonymous bootstrap")
        // Visitor data is needed even for anonymous video requests. See YouTubeKitClient.ensureVisitorData().
        await client.ensureVisitorData()
        log.info("[session] bootstrap: visitor data ensured")
    }

    func signOut() async throws {
        log.info("[session] signOut called")
        var keychainClearFailed = false
        do {
            try store.clear()
        } catch {
            keychainClearFailed = true
        }
        client.applyCookies("")
        // Drop the visitor token too — if cookies were stale, the token they were paired with may
        // also be invalid. `ensureVisitorData` below seeds a fresh one for the anonymous session.
        client.clearVisitorData()
        await client.ensureVisitorData()
        // Wipe the local subscriptions cache so the next signed-in user doesn't see the previous
        // account's channels marked as "subscribed".
        SubscriptionRegistry.shared.clear()
        AuthState.shared.status = .loggedOut
        log.info("[session] in-memory sign-out completed")
        if keychainClearFailed {
            throw SessionManagerError.couldNotRemoveSavedSession
        }
    }

    /// Called by error-handling layer when 401-equivalent or `cookieExpired` is observed.
    func handleExpiredSession() async {
        log.error("[session] expired — clearing cookies and routing to login")
        do {
            try await signOut()
        } catch {
            // The in-memory session is already cleared; keep the failure generic and
            // avoid exposing Keychain details in logs.
            log.error("[session] saved session cleanup failed")
        }
    }
}

enum SessionManagerError: LocalizedError {
    case couldNotRemoveSavedSession

    var errorDescription: String? {
        "FreeTube signed out, but iOS could not remove the saved session. Restart the app and reset the session before using it again."
    }
}
