import Foundation
import Security

/// Tiny `Security`-framework Keychain wrapper. Used until/unless the project adopts `KeychainAccess`
/// as listed in the locked stack. Once `KeychainAccess` is added via SPM, swap the body of these
/// methods to call into `Keychain(service:)`. The call sites in this app do not change.
enum KeychainHelper {
    static let service = "com.leshko.freetube"

    static func set(_ data: Data, for key: String) throws {
        let identity: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(identity as CFDictionary, attributes as CFDictionary)
        let status: OSStatus
        if updateStatus == errSecItemNotFound {
            var addQuery = identity
            for (key, value) in attributes {
                addQuery[key] = value
            }
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            status = addStatus == errSecDuplicateItem
                ? SecItemUpdate(identity as CFDictionary, attributes as CFDictionary)
                : addStatus
        } else {
            status = updateStatus
        }
        guard status == errSecSuccess else { throw KeychainError.osStatus(status) }
    }

    static func set(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else { throw KeychainError.invalidUTF8 }
        try set(data, for: key)
    }

    static func data(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return data
    }

    static func string(for key: String) -> String? {
        guard let data = data(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

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
    case invalidUTF8
}
