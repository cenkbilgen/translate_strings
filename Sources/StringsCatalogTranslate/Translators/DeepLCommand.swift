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

struct DeepL: StringsCatalogCommand {
    static let commandName = "deepl"
    static let name = "DeepL"
    static let defaultKeyEnvironmentVar = "DEEPL_API_KEY"
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    @OptionGroup var fileOptions: FileOptions
    @OptionGroup var targetLanguageOptions: TargetTranslationOptions
        
    func makeTranslator(key: String) async throws -> TranslatorDeepL {
        try TranslatorDeepL(key: key)
    }
}


