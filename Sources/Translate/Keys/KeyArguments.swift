//
//  Utility.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-08.
//

// Gettings arguments related code

import Foundation
import ArgumentParser
import TranslationServices

public enum KeyOptionPrefix: String, CustomStringConvertible {
    case access = "key_id:"
    public var description: String { rawValue }
}

public enum Arguments {

    public struct HelpText {

        public static let verbose = "Verbose output to STDOUT"

        public static let key = """
    API key. Required. 
    If \"\(KeyOptionPrefix.access)[SOME KEY_ID]\" the key with id KEY_ID from the keychain will be used. If not found, you will be prompted to enter the key and it will be stored with that KEY_ID for subsequent calls.
    Otherwise, it will be treated as the literal API key value.
    """
    }

    public static func parseKeyArgument(value: String, allowSTDIN: Bool) throws -> String {
        if value.hasPrefix(KeyOptionPrefix.access.description),
            let keyIdComponent = value.split(separator: try Regex("^\(KeyOptionPrefix.access)")).first {
            let keyId = String(keyIdComponent)
            do {
                return try KeychainItem.readItem(id: keyId)
            } catch KeychainItem.Error.notFound {
                print("No key entry with id \"\(keyId)\" is stored. Creating one now.")
                let key = try readSecureInput(
                    prompt: "Enter the key to store as id \(keyId)",
                    allowStdin: allowSTDIN
                )
                Task {
                    try KeychainItem.saveItem(id: keyId, value: key)
                }
                return key
            } catch {
                print(error)
                throw error
            }
        } else {
            return value
        }
    }

    static func readSecureInput(prompt: String, allowStdin: Bool) throws -> String {
        var buffer: [Int8] = Array(repeating: 0, count: 512)
        let options = allowStdin ? (RPP_STDIN | RPP_ECHO_OFF) : RPP_ECHO_OFF
        let result = readpassphrase(prompt.cString(using: .utf8),
                                    &buffer,
                                    buffer.count,
                                    options)
        guard let result,
              let string = String(validatingCString: result) else {
            throw TranslatorError.keyInputFailed
        }
        return string
    }
}
