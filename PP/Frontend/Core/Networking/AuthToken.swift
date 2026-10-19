//
//  AuthToken.swift
//  PP
//
//  Created by Ly Kimheng on 19/10/26.
//

import Foundation
import Security

nonisolated enum AuthToken {
    private static var query: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.lykimheng.plantfarm.api",
            kSecAttrAccount as String: "token"
        ]
    }

    static var current: String? {
        var lookup = query
        lookup[kSecReturnData as String] = true
        lookup[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        guard SecItemCopyMatching(lookup as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func save(_ token: String) {
        clear()
        var item = query
        item[kSecValueData as String] = Data(token.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(item as CFDictionary, nil)
        if status != errSecSuccess {
            AppLog.warning("Couldn't save the sign-in token (\(status))")
        }
    }

    static func clear() {
        SecItemDelete(query as CFDictionary)
    }
}

extension Notification.Name {
    nonisolated static let sessionExpired = Notification.Name("PPSessionExpired")
}
