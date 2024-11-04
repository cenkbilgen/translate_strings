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
                                                    abstract: "List ids for all API keys for translation models in the Keychain.")

    mutating func run() async throws {
        let itemIds = try  KeychainItem.searchItems()
        print(itemIds.formatted(.list(type: .and)))
    }
}
