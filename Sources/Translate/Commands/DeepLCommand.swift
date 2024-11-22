////
////  TranslateCatalog.swift
////  translate_tool
////
////  Created by Cenk Bilgen on 2024-10-17.
////
//
import Foundation
import ArgumentParser
import TranslationServices


struct DeepL: TranslatorCommand {
    static func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorDeepL {
        try TranslatorDeepL(key: key, sourceLanguage: source)
    }
        
    static let commandName = "deepl"
    static let name = "DeepL"
    static let keyEnvVarName = "TRANSLATE_DEEPL_API_KEY"
    
    static let configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Translate using \(name) service.",
                                                    subcommands: [
                                                        TextCommand.self,
                                                        StringsCatalogCommand.self,
                                                        AvailableLanguagesCommand.self
                                                    ])


    struct StringsCatalogCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(commandName: "strings_catalog",
                                                                abstract: "Translate Xcode Strings Catalog using \(name) service.")
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
        static let configuration = CommandConfiguration(commandName: "text",
                                                        abstract: "Translate text using \(name) service.")
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


//struct DeepLCommand: AsyncParsableCommand {
//    static let configuration = CommandConfiguration(commandName: "deepl",
//                                                    abstract: "Translate using DeepL service.",
//                                                    subcommands: [
//                                                        DeepLCommandStringsCatalog.self,
//                                                        DeepLCommandText.self,
//                                                        DeepLCommandAvailableLanguages.self
//                                                    ])
//
//    static let keyEnvVarName = "TRANSLATE_DEEPL_API_KEY"
//
//// MARK: strings_catalog
//
//    struct DeepLCommandStringsCatalog: DeepLTranslationServiceCommand {
//        static let configuration = CommandConfiguration(commandName: "strings_catalog",
//                                                        abstract: "Translate Xcode Strings Catalog using \(name) service.")
//
//        @Flag(name: .shortAndLong, help: "Verbose output to STDOUT")
//        var verbose: Bool = false
//
//        @OptionGroup var keyOptions: KeyOptions
//
//        @OptionGroup var translationOptions: TranslationOptions
//        
//        @Option(name: .shortAndLong,
//                help: "Input Strings Catalog file.",
//                completion: .file(extensions: ["xcstrings"]))
//        var file: String = "Localizable.xcstrings"
//        
//        @Option(name: .shortAndLong,
//                help: "Output Strings Catalog file. Overwrites. Use \"-\" for STDOUT.",
//                completion: .file(extensions: ["xcstrings"]))
//        var outFile: String = "Localizable.xcstrings"
//        
//        func run() async throws {
//            try await runStringsCatalog(keyOptions: keyOptions,
//                                        translationOptions: translationOptions,
//                                        stringsCatalogFile: file,
//                                        outFile: outFile,
//                                        verbose: verbose)
//        }
//    }
//
//// MARK: text
//
//    struct DeepLCommandText: DeepLTranslationServiceCommand {
//        static let configuration = CommandConfiguration(commandName: "text",
//                                                        abstract: "Translate text using \(name) service.")
//
//        @OptionGroup var keyOptions: KeyOptions
//
//        @OptionGroup var translationOptions: TranslationOptions
//        
//        @Option(name: .shortAndLong,
//                help: "Override autodetected source language, ie \"en\". Optional.")
//        var source: String?
//        
//        @Argument(help: "The phrase to translate")
//        var input: String
//        
//        func run() async throws {
//            try await runText(keyOptions: keyOptions, translationOptions: translationOptions, source: source, text: input)
//        }
//    }
//
//// MARK: available_languages
//
//    struct DeepLCommandAvailableLanguages: DeepLTranslationServiceCommand {
//        static let configuration = CommandConfiguration(commandName: "available_languages",
//                                                        abstract: "List available translation language codes.")
//
//        @OptionGroup var keyOptions: KeyOptions
//
//        func run() async throws {
//            try await runAvailableLanguages(keyOptions: keyOptions)
//        }
//    }
//
//}
//
//// MARK: Protocol
//
//protocol DeepLTranslationServiceCommand: TranslationServiceCommand {}
//
//extension DeepLTranslationServiceCommand {
//    static var name: String { "DeepL" }
//    
//    func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorDeepL {
//        try TranslatorDeepL(key: key, sourceLanguage: source)
//    }
//
//    var keyEnvVarName: String { DeepLCommand.keyEnvVarName }
//}
