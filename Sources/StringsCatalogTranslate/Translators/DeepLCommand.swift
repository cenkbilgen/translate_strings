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
    static let keyEnvVarName = "DEEPL_API_KEY"
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    
    func makeTranslator() throws -> TranslatorDeepL {
        try TranslatorDeepL(key: globalOptions.keyOptions.key,
                            sourceLanguage: nil)
    }
}

