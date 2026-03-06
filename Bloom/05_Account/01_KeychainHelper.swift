import Foundation
import Security

struct KeychainHelper {
    static func savePassword(_ password: String, account: String, service: String = Bundle.main.bundleIdentifier ?? "AppService") throws {
        let passwordData = Data(password.utf8)

        // Delete existing item if present
        try? deletePassword(account: account, service: service)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to save password to Keychain (status: \(status))"])
        }
    }

    static func readPassword(account: String, service: String = Bundle.main.bundleIdentifier ?? "AppService") throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to read password from Keychain (status: \(status))"])
        }
        return String(data: data, encoding: .utf8)
    }

    static func deletePassword(account: String, service: String = Bundle.main.bundleIdentifier ?? "AppService") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to delete password from Keychain (status: \(status))"])
        }
    }
}
