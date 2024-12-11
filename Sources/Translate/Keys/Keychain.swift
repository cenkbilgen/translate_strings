import Foundation
import KeychainSimple

enum Keychain {
    static let access = KeychainAccess(itemNamePrefix: "tools.xcode.translate_strings.")
}

//import Foundation
//import Security
//
//public struct KeychainItem {
//
//    public enum Error: Swift.Error {
//        case notFound
//        case notUTF8Encoded
//        case unexpectedPasswordData
//        case unexpectedItemData
//        case securityError(CFError?)
//        case systemError(OSStatus)
//    }
//
//    public static let appKeychainPrefix = "tools.xcode.translate_strings."
//
//    private static func accountString(_ key: String) -> String {
//        appKeychainPrefix + key
//    }
//
//    public static func saveItem(id: String, value: String, updateExisting: Bool = true) throws {
//        guard let data = value.data(using: .utf8) else {
//            throw Error.notUTF8Encoded
//        }
//        // let accessControl = try createAccessControl()
//        var query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: accountString(id),
//            kSecValueData as String: data,
//        ]
//        let status = SecItemAdd(query as CFDictionary, nil)
//        switch status {
//            case errSecSuccess:
//                break
//            case errSecDuplicateItem:
//                if updateExisting {
//                    query.removeValue(forKey: kSecValueData as String)
//                    SecItemUpdate(
//                        query as CFDictionary,
//                        [kSecValueData as String: data] as CFDictionary
//                    )
//                } else {
//                    fallthrough
//                }
//            default:
//                throw Error.systemError(status)
//        }
//    }
//
//    public static func readItem(id: String) throws -> String {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: accountString(id),
//            kSecReturnData as String: kCFBooleanTrue!,
//            kSecMatchLimit as String: kSecMatchLimitOne,
//        ]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//        guard status == errSecSuccess else {
//            if status == errSecItemNotFound {
//                throw Error.notFound
//            } else {
//                throw Error.systemError(status)
//            }
//        }
//        guard let data = item as? Data else {
//            throw Error.unexpectedItemData
//        }
//        guard let string = String(data: data, encoding: .utf8) else {
//            throw Error.notUTF8Encoded
//        }
//        return string
//    }
//
//    public static func searchItems(prefix: String = appKeychainPrefix) throws -> [String] {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            // kSecAttrAccount as String: prefix + "*",
//            kSecMatchLimit as String: kSecMatchLimitAll,
//            kSecReturnAttributes as String: kCFBooleanTrue!,
//            kSecReturnData as String: kCFBooleanFalse!
//        ]
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        guard status == errSecSuccess else {
//            if status == errSecItemNotFound {
//                throw Error.notFound
//            } else {
//                throw Error.systemError(status)
//            }
//        }
//        guard let items = result as? [[String: Any]] else {
//            throw Error.unexpectedItemData
//        }
//        return items
//            .compactMap { item in
//                if let account = item[kSecAttrAccount as String] as? String,
//                   account.hasPrefix(prefix) {
//                    return account.replacingOccurrences(of: prefix, with: "")
//                } else {
//                    return nil
//                }
//            }
//    }
//}
//
//
