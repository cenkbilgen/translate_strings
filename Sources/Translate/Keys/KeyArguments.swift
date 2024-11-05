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

enum KeyArgumentParser {

    static func parse(value: String, envVarName: String, allowSTDIN: Bool) throws -> String {
        if let match = value.firstMatch(of: /^key_id:(?<keyid>[A-Za-z0-9_-]+)$/) {
            try keyFrom(keyId: String(match.output.keyid), allowSTDIN: allowSTDIN)
        } else if value.firstMatch(of:  /^env:$/) != nil {
            try keyFrom(envVarName: envVarName)
        } else {
            value
        }
    }

    private static func keyFrom(keyId: String, allowSTDIN: Bool) throws -> String {
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

    private static func keyFrom(envVarName: String) throws -> String {
        guard let key = ProcessInfo().environment[envVarName.capitalized] else {
            print("No key for environment variable \"\(envVarName.capitalized)\"")
            throw TranslatorError.noAuthorizationKey
        }
        return key
    }

    private static func readSecureInput(prompt: String, allowStdin: Bool) throws -> String {
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


