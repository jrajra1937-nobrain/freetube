import Foundation

/// Removes only the legacy cookie item created by the upstream embedded sign-in flow.
/// Personal Edition does not read, create, or send persisted Google/YouTube session cookies.
final class CookieStore {
    static let shared = CookieStore()
    static let keychainKey = "com.leshko.freetube.cookies"

    private init() {}

    func clear() throws {
        try KeychainHelper.delete(Self.keychainKey)
    }
}
