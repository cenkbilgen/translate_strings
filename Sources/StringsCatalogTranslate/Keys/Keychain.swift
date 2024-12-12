import Foundation
import KeychainSimple

enum Keychain {
    static let namePrefix = "tools.xcode.translate_strings"
    static let access = KeychainAccess(itemNamePrefix: namePrefix)
}
