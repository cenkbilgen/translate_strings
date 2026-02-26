//
//  ServiceCommands.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices
import KeychainSimple

// MARK: List Keys

struct ListKeysCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list_keys",
                                                    abstract: "List API keys stored in Keychain.")

    mutating func run() async throws {
        let itemIds = try await Keychain.access.searchItems()
        if itemIds.isEmpty {
            print("No saved keys found.")
        } else {
            print(itemIds.formatted(.list(type: .and)))
            print("* Edit or delete keys through the macOS \"keychain-access\" tool. Search for keys with the prefix \"\(Keychain.namePrefix)\".")
        }
    }
}

// MARK: Delete Keys


struct DeleteKeyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "delete_key",
                                                    abstract: "Delete an API keys stored in Keychain.")
    @Argument var keyId: String

    mutating func run() async throws {
        try await Keychain.access.delete(id: keyId)
    }
}

//MARK: Print Keys

struct PrintKeyCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "print_key",
                                                    abstract: "Print an API key stored in Keychain to STDOUT.")
    @Argument var keyId: String

    mutating func run() async throws {
        let value = try await Keychain.access.read(id: keyId)
        print(value)
    }
}
