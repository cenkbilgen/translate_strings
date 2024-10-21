//
//  Utility.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-08.
//

// Gettings arguments related code

import Foundation
import ArgumentParser
import Translator

public enum TranslationModel: CaseIterable, ExpressibleByArgument, Sendable {
    case deepl, google(projectId: String)

    // For argument help
    public static let allCases: [TranslationModel] = [
        .deepl, .google(projectId: "PROJECT_ID")
    ]

    public init?(argument: String) {
        if argument == "deepL" {
            self = .deepl
        } else if argument.hasPrefix("google:") {
            guard let projectId = argument.split(
                separator: "google:",
                maxSplits: 1
            ).last else {
                return nil
            }
            self = .google(projectId: String(projectId))
        } else {
            return nil
        }
    }

    public func translator(key: String, sourceCode: Locale.LanguageCode? = nil) throws -> any Translator {
        switch self {
            case .deepl:
                try TranslatorDeepL(key: key, sourceLanguage: sourceCode)
            case .google(let projectId):
                try TranslatorGoogle(key: key, projectId: projectId, sourceLanguage: sourceCode)
        }
    }
}

public enum KeyOptionPrefix: String, CustomStringConvertible {
    case access = "key_id:"
    case list = "list:"
    public var description: String { rawValue }
}

public enum Arguments {

    public struct HelpText {

        public static let verbose = "Verbose output to STDOUT"

        public static let key = """
    API key. Required. 
    If \"\(KeyOptionPrefix.access)[SOME KEY_ID]\" the key with id KEY_ID from the keychain will be used. If there is not found, you will be prompted to enter the key and it will be stored with that KEY_ID for subsequent calls.
    If \"\(KeyOptionPrefix.list)\", lists currently saved key ids in the keychain.
    Otherwise, it will be treated as the literal API key value.
    """
    }

    public static let autoDetectArgument = "auto"

    public static func isListKeyArgument(argument: String) -> Bool {
        argument.hasPrefix(KeyOptionPrefix.list.description)
    }

    public static func parseKeyArgument(value: String, allowSTDIN: Bool) throws -> String {
        if value.hasPrefix(KeyOptionPrefix.access.description),
            let keyIdComponent = value.split(separator: try Regex("^\(KeyOptionPrefix.access)")).first {
       //     let keyIdComponent = value.split(separator: Regex(/^key_id:/)).first {
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
