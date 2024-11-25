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
                                                        TextCommand<DeepL>.self,
                                                        StringsCatalogCommand<DeepL>.self,
                                                        AvailableLanguagesCommand<DeepL>.self
                                                    ])
}
