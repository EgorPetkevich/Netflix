//
//  KeychainManager.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 10.04.26.
//

import Foundation
import Security

protocol KeychainManaging {
    func save(_ value: String, usage: KeychainUsage)
    func get(_ usage: KeychainUsage) -> String?
    func delete(_ usage: KeychainUsage)
}

final class KeychainManager: KeychainManaging {

    private let logger: Logger = Logger(KeychainManager.self)

    func save(_ value: String, usage: KeychainUsage) {
        save(
            value,
            service: usage.service,
            account: usage.account
        )
    }

    func get(_ usage: KeychainUsage) -> String? {
        get(
            service: usage.service,
            account: usage.account
        )
    }

    func delete(_ usage: KeychainUsage) {
        delete(
            service: usage.service,
            account: usage.account
        )
    }

    private func save(_ value: String, service: String, account: String) {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            logger.error("Error saving - status code \(status)")
        }
    }

    private func get(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    private func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
