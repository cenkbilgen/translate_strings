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

public enum Arguments {

    public struct HelpText {

        public static let verbose = "Verbose output to STDOUT"

        public static let key = """
    The API key is required for this operation. 
    
    If you use the format `key_id:[SOME KEY_ID]`, the program will try to fetch the API key stored in the keychain under this KEY_ID. If the key is not found, you'll be prompted to enter it, and it will then be stored with that KEY_ID for future use. 
    
    Alternatively, if you use the format `env:`, the API key will be retrieved from the specified environment variable STRINGS_TRANSALTE_API_KEY_DEEPL or STRINGS_TRANSLATE_API_KEY_GOOGLE. 
    
    If you do not use either of these formats, the value you provide will be used directly as the API key."
    """
    }

    enum MatchResult {
        case keyID(String)
        case env
        case literal(String)
    }

    static func matchKeyArgument(value: String) -> MatchResult {
        if let match = value.firstMatch(of: /^key_id:(?<keyid>[A-Za-z0-9_-]+)$/) {
            return .keyID(String(match.output.keyid))
        } else if value.firstMatch(of:  /^env:$/) != nil {
            return .env
        } else {
            return .literal(value)
        }
    }

    static func handle(keyId: String, allowSTDIN: Bool) throws -> String {
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
    }

    static func handle(envName: String) throws -> String {
        guard let key = ProcessInfo().environment[envName.capitalized] else {
            print("No key for environment variable \"\(envName.capitalized)\"")
            throw TranslatorError.noAuthorizationKey
        }
        return key
    }

    public static func parseKeyArgument(value: String, envName: String, allowSTDIN: Bool) throws -> String {
        switch matchKeyArgument(value: value) {
            case .literal(let key):
                key
            case .keyID(let keyId):
                try handle(keyId: keyId, allowSTDIN: allowSTDIN)
            case .env:
                try handle(envName: envName)
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
