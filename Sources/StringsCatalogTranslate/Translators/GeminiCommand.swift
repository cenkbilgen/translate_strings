//
//  TranslateCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import TranslationServices

struct GeminiAI: StringsCatalogCommand {
    static let commandName = "gemini"
    static let name = "Gemini"
    static let defaultKeyEnvironmentVar = "GEMINI_API_KEY"
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    @OptionGroup var fileOptions: FileOptions
    @OptionGroup var targetLanguageOptions: TargetTranslationOptions
    @Option var model: String = "gemini-1.5-flash"
    @Option var projectId: String?
    
    func makeTranslator(key: String) async throws -> TranslatorGemini {
        try TranslatorGemini(key: key, model: model, projectId: projectId)
    }
}
