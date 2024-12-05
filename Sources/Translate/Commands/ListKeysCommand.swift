//
//  ServiceCommands.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices

struct ListKeysCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list_keys",
                                                    abstract: "List API keys stored in Keychain.")

    mutating func run() async throws {
        let itemIds = try  KeychainItem.searchItems()
        if itemIds.isEmpty {
            print("No saved keys found.")
        } else {
            print(itemIds.formatted(.list(type: .and)))
            print("\n")
            print("Edit or delete keys through the macOS \"keychain-access\" tool. Search for keys with the prefix \"tools.xcode.translate_strings.\".")
        }
    }
}
