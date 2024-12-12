//
//  TranslateCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices

//struct Google: TranslatorCommand {
//    func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorGoogle {
//        try TranslatorGoogle(key: key, sourceLanguage: source)
//    }
//    
//    static let commandName = "google"
//    static let name = "Google Gemini"
//    static let keyEnvVarName = "TRANSLATE_GOOGLE_API_KEY"
//    
//    static let configuration = CommandConfiguration(commandName: commandName,
//                                                    abstract: "Translate using \(name) service.",
//                                                    subcommands: [
//                                                        TextCommand<Google>.self,
//                                                        StringsCatalogCommand<Google>.self,
//                                                        AvailableLanguagesCommand<Google>.self
//                                                    ])
//}
