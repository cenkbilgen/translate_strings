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

struct ListKeysCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list_keys",
                                                    abstract: "List API keys stored in Keychain.")

    mutating func run() async throws {
        let itemIds = try await Keychain.access.searchItems()
        if itemIds.isEmpty {
            logger.info("No saved keys found.")
        } else {
            logger.info("\(itemIds.formatted(.list(type: .and)))")
            logger.info("\n")
            logger.info("Edit or delete keys through the macOS \"keychain-access\" tool. Search for keys with the prefix \"\(Keychain.namePrefix)\".")
        }
    }
}
