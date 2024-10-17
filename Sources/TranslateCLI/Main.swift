import Foundation
import ArgumentParser
import Shared

@main
struct TranslatorCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "translate",
        abstract: "A utility for language translation of Xcode Strings Catalogs.",
        subcommands: [
            TranslateStringsCatalogCommand.self,
            TranslateCommand.self,
            ListKeysCommand.self,
            AvailableLanguagesCommand.self
        ]
    )
}

struct ListKeysCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list-keys",
                                                    abstract: "List API keys for translation models in the Keychain.")

    mutating func run() async throws {
        let itemIds = try  KeychainItem.searchItems()
        print(itemIds.formatted(.list(type: .and)))
    }
}

struct AvailableLanguagesCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "available-languages",
                                                    abstract: "List available language codes for translation model.")

    @OptionGroup var keyOptions: KeyOptions
    @OptionGroup var modelOptions: TranslationModelOptions

    mutating func run() async throws {

        let key = try Arguments.parseKeyArgument(
            value: keyOptions.key,
            allowSTDIN: false
        )

        let translator = modelOptions.model.translator(key: key)

        let languages = try await translator.availableLanguageCodes()

        print(languages.formatted(.list(type: .and)))
    }

}
