import Foundation
import Security

public struct KeychainItem {

    public enum Error: Swift.Error {
        case notFound
        case notUTF8Encoded
        case unexpectedPasswordData
        case unexpectedItemData
        case securityError(CFError?)
        case systemError(OSStatus)
    }

    private static func accountString(_ key: String) -> String {
        "tools.xcode.translate_strings." + key
    }

    public static func saveItem(id: String, value: String, updateExisting: Bool = true) throws {
        guard let data = value.data(using: .utf8) else {
            throw Error.notUTF8Encoded
        }
        // let accessControl = try createAccessControl()
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountString(id),
            kSecValueData as String: data,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
            case errSecSuccess:
                break
            case errSecDuplicateItem:
                if updateExisting {
                    query.removeValue(forKey: kSecValueData as String)
                    SecItemUpdate(
                        query as CFDictionary,
                        [kSecValueData as String: data] as CFDictionary
                    )
                } else {
                    fallthrough
                }
            default:
                throw Error.systemError(status)
        }
    }

    public static func readItem(id: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountString(id),
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw Error.notFound
            } else {
                throw Error.systemError(status)
            }
        }
        guard let data = item as? Data else {
            throw Error.unexpectedItemData
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw Error.notUTF8Encoded
        }
        return string
    }

}


