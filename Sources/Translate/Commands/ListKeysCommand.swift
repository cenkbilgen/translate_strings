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
        print(itemIds.formatted(.list(type: .and)))
    }
}
