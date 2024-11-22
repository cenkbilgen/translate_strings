//
//  TranslateCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices

struct Google: TranslatorCommand {
    static func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorGoogle {
        try TranslatorGoogle(key: key, sourceLanguage: source)
    }
        
    static let commandName = "google"
    static let name = "Google Gemini"
    static let keyEnvVarName = "TRANSLATE_GOOGLE_API_KEY"
    
    static let configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Translate using \(name) service.",
                                                    subcommands: [
                                                        TextCommand.self,
                                                        StringsCatalogCommand.self,
                                                        AvailableLanguagesCommand.self
                                                    ])


    struct StringsCatalogCommand: AsyncParsableCommand {
        @OptionGroup var globalOptions: StringsCatalogGlobalOptions
        
        mutating func run() async throws {
            try await runStringsCatalog(keyOptions: globalOptions.keyOptions,
                                        translationOptions: globalOptions.translationOptions,
                                        stringsCatalogFile: globalOptions.file,
                                        outFile: globalOptions.outFile,
                                        verbose: globalOptions.verbose)
        }
    }
    
    struct TextCommand: AsyncParsableCommand {
        @OptionGroup var globalOptions: TextGlobalOptions
        
        mutating func run() async throws {
            try await runText(keyOptions: globalOptions.keyOptions,
                                     translationOptions: globalOptions.translationOptions,
                                     source: globalOptions.source,
                                     text: globalOptions.input)
        }
    }
    
    struct AvailableLanguagesCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(commandName: "available_languages",
                                                        abstract: "List available translation language codes.")
        
        @OptionGroup var keyOptions: KeyOptions
        
        func run() async throws {
            try await runAvailableLanguages(keyOptions: keyOptions)
        }
    }
}
