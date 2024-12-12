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
import KeychainSimple

enum KeyArgumentParser {

    static func parse(value: String, envVarName: String, onlyInteractive: Bool) throws -> String {
        if let match = value.firstMatch(of: /^key_id:(?<keyid>[A-Za-z0-9_-]+)$/) {
            try keyFrom(keyId: String(match.output.keyid), onlyInteractive: onlyInteractive)
        } else if value.firstMatch(of:  /^env:$/) != nil {
            try keyFrom(envVarName: envVarName)
        } else {
            value
        }
    }

    private static func keyFrom(keyId: String, onlyInteractive: Bool) throws -> String {
        do {
            return try Keychain.access.read(id: keyId)
        } catch KeychainAccess.Error.notFound {
            print("No key entry with id \"\(keyId)\" is stored. Creating one now.")
            let key = try SecureInput.read(prompt: "Enter the key to store as id \(keyId)",
                                         echoInput: false,
                                         onlyInteractiveInput: onlyInteractive,
                                         allocationSize: 512)
            Task {
                try Keychain.access.save(id: keyId, value: key)
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
}


