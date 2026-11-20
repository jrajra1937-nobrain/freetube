import Foundation
import Security

/// Minimal cleanup helper for the legacy upstream cookie item. The Personal Edition does not
/// write or read account credentials or session cookies.
enum KeychainHelper {
    static let service = "com.leshko.freetube"

    static func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.osStatus(status)
        }
    }
}

enum KeychainError: Error {
    case osStatus(OSStatus)
}
