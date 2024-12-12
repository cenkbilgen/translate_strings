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

struct OpenAI: StringsCatalogCommand {
    static let commandName = "openai"
    static let name = "OpenAI"
    static let keyEnvVarName = "OPENAI_API_KEY"
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    @OptionGroup var fileOptions: FileOptions
    @OptionGroup var targetLanguageOptions: TargetTranslationOptions
    @Option var model: String = "gpt-4o"
    
    func makeTranslator(key: String) async throws -> TranslatorOpenAI {
        try TranslatorOpenAI(key: key, model: model)
    }
}
