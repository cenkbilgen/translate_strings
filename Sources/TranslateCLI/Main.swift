import Foundation
import ArgumentParser

@main
struct TranslatorCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "translate",
        abstract: "A utility for language translation of Xcode Strings Catalogs or just plain strings.",
        subcommands: [
            DeepLCommand.self
//            TranslateStringsCatalogCommand.self,
//            TranslateCommand.self,
//            ListKeysCommand.self,
//            AvailableLanguagesCommand.self
        ]
    )
}

protocol TranslationSubcommand: AsyncParsableCommand {

}


