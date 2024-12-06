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

struct OpenAI: TranslatorCommand {
    
    static func model(key: String, source: Locale.LanguageCode?) throws -> TranslatorOpenAI {
        try TranslatorOpenAI(key: key, model: "gpt-4o", sourceLanguage: source)
    }
    
    static let commandName = "openai"
    static let name = "OpenAI"
    static let keyEnvVarName = "TRANSLATE_OPENAI_API_KEY"
    
    // mutable, but only setting in validation of instance, which is only once
    // nonisolated(unsafe) private(set) static var model = ""
    
//    @Option var model: String = "gpt-4o"
    
//    func validate() throws {
//        OpenAI.model = model
//    }
    
    static let configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Translate using \(name) service.",
                                                    subcommands: [
                                                        TextCommand<OpenAI>.self,
                                                        StringsCatalogCommand<OpenAI>.self,
                                                        AvailableLanguagesCommand<OpenAI>.self
                                                    ])
}
