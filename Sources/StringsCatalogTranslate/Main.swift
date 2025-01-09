import Foundation
import ArgumentParser

@main
struct MainCommand: AsyncParsableCommand {
    static let version = "3.3.1"
        
    static let configuration = CommandConfiguration(
        commandName: "strings_catalog_translate",
        abstract: "A utility for language translation of Xcode Strings Catalogs. \(isDEBUG ? "(DEBUG BUILD)" : "")",
        version: version,
        subcommands: [
            DeepL.self,
            OpenAI.self,
            GeminiAI.self,
            Anthropic.self,
            ListKeysCommand.self,
            DeleteKeyCommand.self,
            PrintKeyCommand.self
        ]
    )

    #if DEBUG
    static let isDEBUG = true
    #else
    static let isDEBUG = false
    #endif
    
    // MARK: Errors
    
    enum Error: Swift.Error {
        case missingRequiredArgument(String)
    }
}


