//
//  TranslateCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices

struct GoogleCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "google",
                                                    abstract: "Translate using Google AI service.",
                                                    subcommands: [
                                                        GoogleCommandStringsCatalog.self,
                                                        GoogleCommandText.self
                                                    ])

    static let keyEnvVarName = "TRANSLATE_GOOGLE_API_KEY"

    struct GoogleCommandStringsCatalog: GoogleTranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "strings_catalog",
                                                        abstract: "Translate Xcode Strings Catalog using Google service.")
        @Flag(name: .shortAndLong, help: "Verbose output to STDOUT")
        var verbose: Bool = false

        @OptionGroup var keyOptions: KeyOptions

        @OptionGroup var translationOptions: TranslationOptions
        
        @Option(name: .shortAndLong,
                help: "Input Strings Catalog file.",
                completion: .file(extensions: ["xcstrings"]))
        var file: String = "Localizable.xcstrings"
        
        @Option(name: .shortAndLong,
                help: "Output Strings Catalog file. Overwrites. Use \"-\" for STDOUT.",
                completion: .file(extensions: ["xcstrings"]))
        var outFile: String = "Localizable.xcstrings"
        
        mutating func run() async throws {
            try await runStringsCatalog(keyOptions: keyOptions,
                                        translationOptions: translationOptions,
                                        stringsCatalogFile: file,
                                        outFile: outFile,
                                        verbose: verbose)
        }
    }
    
    struct GoogleCommandText: GoogleTranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "text",
                                                        abstract: "Translate text using Google AI service.")
        
        @OptionGroup var keyOptions: KeyOptions

        @OptionGroup var translationOptions: TranslationOptions
        
        @Option(name: .shortAndLong,
                help: "Override autodetected source language, ie \"en\". Optional.")
        var source: String?
        
        @Argument(help: "The phrase to translate")
        var input: String

        mutating func run() async throws {
            try await runText(keyOptions: keyOptions, translationOptions: translationOptions, source: source, text: input)
        }
    }
}

protocol GoogleTranslationServiceCommand: TranslationServiceCommand {}

extension GoogleTranslationServiceCommand {
    func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorGoogle {
        try TranslatorGoogle(key: key, sourceLanguage: source)
    }

    var keyEnvVarName: String { GoogleCommand.keyEnvVarName }
}
