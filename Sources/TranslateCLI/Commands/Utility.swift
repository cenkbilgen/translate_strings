//
//  ServiceCommands.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import Translator

struct ListKeysCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list-keys",
                                                    abstract: "List API keys for translation models in the Keychain.")

    mutating func run() async throws {
        let itemIds = try  KeychainItem.searchItems()
        print(itemIds.formatted(.list(type: .and)))
    }
}

//struct AvailableLanguagesCommand: AsyncParsableCommand {
//    static let configuration = CommandConfiguration(commandName: "available-languages",
//                                                    abstract: "List available language codes for translation model.")
//
//    @OptionGroup var keyOptions: KeyOptions
//    @OptionGroup var modelOptions: TranslationModelOptions
//
//    mutating func run() async throws {
//
//        let key = try Arguments.parseKeyArgument(
//            value: keyOptions.key,
//            allowSTDIN: false
//        )
//
//        let translator = try modelOptions.model.translator(key: key)
//
//        let languages = try await translator.availableLanguageCodes()
//
//        print(languages.formatted(.list(type: .and)))
//    }
//
//}
