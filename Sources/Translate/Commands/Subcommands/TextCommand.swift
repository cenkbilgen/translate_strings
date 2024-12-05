//
//  Text.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-25.
//

import Foundation
import ArgumentParser
import TranslationServices

struct TextCommand<C: TranslatorCommand>: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "text",
                             abstract: "Translate text using \(C.name) service.")
    }
    
    @OptionGroup var globalOptions: TextGlobalOptions
    
    mutating func run() async throws {
        guard let targetCode = Locale(identifier: globalOptions.translationOptions.targetLanguage).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }
        let sourceCode: Locale.LanguageCode? = if let source = globalOptions.sourceTranslationOptions.sourceLanguage {
            Locale(identifier: source).language.languageCode
        } else {
            nil
        }
        let key = try KeyArgumentParser.parse(value: globalOptions.keyOptions.key, envVarName: C.keyEnvVarName, allowSTDIN: true)
        let translator = try C.model(key: key, source: sourceCode)
        let text = globalOptions.input
        let output = try await translator.translate(texts: [text], targetLanguage: targetCode)
        guard let translation = output.first else {
            throw TranslatorError.noTranslations
        }
        print(translation)
    }
}
