import Foundation
import ArgumentParser

@main
struct TranslateCommand: AsyncParsableCommand {
    static let version = "2.3.0"
    
    static let configuration = CommandConfiguration(
        commandName: "translate_strings",
        abstract: "A utility for language translation of Xcode Strings Catalogs or just plain strings. \(isDEBUG ? "(DEBUG BUILD)" : "")",
        version: version,
        subcommands: [
            DeepL.self,
            Google.self,
            OpenAI.self,
            ListKeysCommand.self,
        ]
    )

    #if DEBUG
    static let isDEBUG = true
    #else
    static let isDEBUG = false
    #endif
}



