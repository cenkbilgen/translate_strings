//
//  TranslateCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices

struct OpenAICommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "openai",
                                                    abstract: "Translate using OpenAI service.",
                                                    subcommands: [
                                                        OpenAICommandStringsCatalog.self,
                                                        OpenAICommandText.self,
                                                        OpenAICommandAvailableLanguages.self
                                                    ])

    static let keyEnvVarName = "TRANSLATE_OPENAI_API_KEY"

// MARK: strings_catalog

    struct OpenAICommandStringsCatalog: OpenAITranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "strings_catalog",
                                                        abstract: "Translate Xcode Strings Catalog using \(name) service.")
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

// MARK: text

    struct OpenAICommandText: OpenAITranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "text",
                                                        abstract: "Translate text using \(name) service.")
        
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

    // MARK: available_languages

    struct OpenAICommandAvailableLanguages: OpenAITranslationServiceCommand {
        static let configuration = CommandConfiguration(commandName: "available_languages",
                                                        abstract: "List available translation language codes.")

        @OptionGroup var keyOptions: KeyOptions

        func run() async throws {
            try await runAvailableLanguages(keyOptions: keyOptions)
        }
    }
}

// MARK: Protocol

protocol OpenAITranslationServiceCommand: TranslationServiceCommand {}

extension OpenAITranslationServiceCommand {
    static var name: String { "OpenAI" }
    
    func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorOpenAI {
        try TranslatorOpenAI(key: key, sourceLanguage: source)
    }

    var keyEnvVarName: String { OpenAICommand.keyEnvVarName }
}
