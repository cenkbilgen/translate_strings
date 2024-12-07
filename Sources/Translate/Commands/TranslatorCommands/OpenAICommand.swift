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
    static let commandName = "openai"
    static let name = "OpenAI"
    static let keyEnvVarName = "TRANSLATE_OPENAI_API_KEY"
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    @Option var model: String = "gpt-4o"
    
    func makeTranslator() throws -> TranslatorOpenAI {
        try TranslatorOpenAI(key: globalOptions.keyOptions.key,
                             model: model,
                             sourceLanguage: nil)
    }
    
    static let configuration = CommandConfiguration(commandName: commandName,
                                                    abstract: "Translate using \(name) service.")
}
