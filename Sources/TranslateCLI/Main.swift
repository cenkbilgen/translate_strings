import Foundation
import ArgumentParser

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

