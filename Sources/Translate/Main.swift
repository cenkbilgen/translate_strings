import Foundation
import ArgumentParser

@main
struct TranslateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "translate",
        abstract: "A utility for language translation of Xcode Strings Catalogs or just plain strings.",
        subcommands: [
            DeepLCommand.self,
            GoogleCommand.self,
            ListKeysCommand.self,
        ]
    )
}


