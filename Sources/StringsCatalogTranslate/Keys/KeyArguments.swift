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
    
    enum ParsedValue {
        case keychain(String)
        case env(String)
        case verbatim(String)
    }
    
    static func parse(value: String) throws -> ParsedValue {
        if let match = value.firstMatch(of: /^key_id:(?<keyId>[A-Za-z0-9_-]+)$/) {
           .keychain(String(match.output.keyId))
        } else if let match = value.firstMatch(of:  /^env:(?<name>[.*])$/) {
            .env(String(match.output.name))
        } else {
            .verbatim(value)
        }
    }
    
    static func getKeyValue(parsed: ParsedValue) async throws -> String {
        switch parsed {
        case .verbatim(let value):
            return value
        case .env(let name):
            return try key(envVarName: name)
        case .keychain(let keyId):
            print("Getting value from keychain \(keyId)")
            do {
                let key = try await Keychain.access.read(id: keyId)
                print("Found key with id \(keyId): \(key)")
                return key
            } catch KeychainAccess.Error.notFound {
                print("Prompting for new key")
                return try promptForKeyValue(keyId: keyId, onlyInteractive: true)
            } catch {
                print(error.localizedDescription)
                throw error
            }
        }
    }

    private static func promptForKeyValue(keyId: String, onlyInteractive: Bool) throws -> String {
        
        print("No key entry with id \"\(keyId)\" is stored. Creating one now.")
        let key = try SecureInput.read(prompt: "Enter the key to store as id \(keyId)",
                                       echoInput: false,
                                       onlyInteractiveInput: onlyInteractive,
                                       allocationSize: 512)
        Task {
            try Keychain.access.save(id: keyId, value: key)
        }
        return key
    }
    
    private static func key(envVarName name: String) throws -> String {
        guard let value = ProcessInfo().environment[name.capitalized] else {
            print("No key for environment variable \"\(name.capitalized)\"")
            throw TranslatorError.noAuthorizationKey
        }
        return value
    }
}


