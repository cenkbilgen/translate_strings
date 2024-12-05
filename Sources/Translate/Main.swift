import Foundation
import ArgumentParser

@main
struct TranslateCommand: AsyncParsableCommand {
    static let version = "2.5.0"
    
    static let configuration = CommandConfiguration(
        commandName: "strings_catalog_translate",
        abstract: "A utility for language translation of Xcode Strings Catalogs. \(isDEBUG ? "(DEBUG BUILD)" : "")",
        version: version,
        subcommands: [
            StringsCatalogCommand<DeepL>.self,
            StringsCatalogCommand<OpenAI>.self,
            StringsCatalogCommand<Google>.self,
            ListKeysCommand.self,
        ],
        defaultSubcommand: StringsCatalogCommand<OpenAI>.self
    )

    #if DEBUG
    static let isDEBUG = true
    #else
    static let isDEBUG = false
    #endif
}



