//
//  Utility.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-08.
//

// Gettings arguments related code

import Foundation

public enum Arguments {

    public static let keyIDPrefix = "key_id:"

    public static func parseKeyArgument(value: String, allowSTDIN: Bool) throws -> String {
        if value.hasPrefix(Self.keyIDPrefix),
           let keyIdComponent = value.split(separator: try Regex("^\(keyIDPrefix)")).first {
//            let keyIdComponent = value.split(separator: Regex(/^key_id:/)).first {
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
