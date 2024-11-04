//
//  TranslateCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import Translator

struct DeepLCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "deepl",
                                                    abstract: "Translate using DeepL service.",
                                                    subcommands: [
                                                        DeepLCommandStringsCatalog.self,
                                                        DeepLCommandText.self
                                                    ])
    
    struct DeepLCommandStringsCatalog: TranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "strings_catalog",
                                                        abstract: "Translate Xcode Strings Catalog using DeepL service.")
        @Flag(name: .shortAndLong, help: "Verbose output to STDOUT")
        var verbose: Bool = false
        
        @OptionGroup var keyOptions: KeyOptions
        
        @OptionGroup var translationOptions: TranslationOptions
        
        @Option(name: .shortAndLong,
                help: "Specify the source language identifier, ie \"en\". Optional or string_catalog base language.")
        var source: String?
        
        @Option(name: .shortAndLong,
                help: "Input Strings Catalog file.",
                completion: .file(extensions: ["xcstrings"]))
        var file: String = "Localizable.xcstrings"
        
        @Option(name: .shortAndLong,
                help: "Output Strings Catalog file. Overwrites. Use \"-\" for STDOUT.",
                completion: .file(extensions: ["xcstrings"]))
        var outFile: String = "Localizable.xcstrings"
        
        nonisolated(unsafe) static let model: (String, Locale.LanguageCode?) throws -> Translator = { key, source in
            try TranslatorDeepL(key: key, sourceLanguage: source)
        }
        
        mutating func run() async throws {
            try await runStringsCatalog(keyOptions: keyOptions,
                                        translationOptions: translationOptions,
                                        stringsCatalogFile: file,
                                        outFile: outFile,
                                        verbose: verbose)
        }
    }
    
    struct DeepLCommandText: TranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "text",
                                                        abstract: "Translate text using DeepL service.")
        @OptionGroup var keyOptions: KeyOptions
        
        @OptionGroup var translationOptions: TranslationOptions
        
        @Option(name: .shortAndLong,
                help: "Override autodetected source language, ie \"en\". Optional.")
        var source: String?
        
        @Argument(help: "The phrase to translate")
        var input: String
        
        nonisolated(unsafe) static let model: (String, Locale.LanguageCode?) throws -> Translator = { key, source in
            try TranslatorDeepL(key: key, sourceLanguage: source)
        }
        
        mutating func run() async throws {
            try await runText(keyOptions: keyOptions, translationOptions: translationOptions, source: source, text: input)
        }
    }
}
