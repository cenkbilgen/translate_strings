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

struct Anthropic: StringsCatalogCommand {
    static let commandName = "anthropic"
    static let name = "Anthropic"
    static let defaultKeyEnvironmentVar = "CLAUDE_API_KEY"
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    @OptionGroup var fileOptions: FileOptions
    @OptionGroup var targetLanguageOptions: TargetTranslationOptions
    @Option(help: ModelOptions.modelHelp) var model: String = "claude-3-5-haiku-latest"
    
    func makeTranslator(key: String) async throws -> TranslatorAnthropic {
        try TranslatorAnthropic(key: key, model: model)
    }
}
