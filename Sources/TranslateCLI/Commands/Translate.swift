//
//  Translate.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import Translator

struct TranslateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "text",
                                                    abstract: "Translate a phrase and output translation to STDOUT.")

    @OptionGroup var keyOptions: KeyOptions
    @OptionGroup var translationOptions: TranslationOptions
    @OptionGroup var modelOptions: TranslationModelOptions

    @Argument(help: "The phrase to translate")
    var input: String

    mutating func run() async throws {

        let sourceCode: Locale.LanguageCode? = try {
            if translationOptions.source == nil {
                return nil
            } else if let source = translationOptions.source,
                      let code = Locale(identifier: source).language.languageCode {
                return code
            } else {
                throw TranslatorError.unrecognizedSourceLanguage
            }
        }()

        guard let targetCode = Locale(identifier: translationOptions.target).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }

        let key = try Arguments.parseKeyArgument(
            value: keyOptions.key,
            allowSTDIN: false
        )

        #if DEBUG
        print("Translating \(sourceCode ?? "AUTO") to \(targetCode)")
        print("Key: \(key)")
        #endif

        let translator = try modelOptions.model.translator(key: key, sourceCode: sourceCode)

        let translations = try await translator.translate(
            texts: [input],
            targetLanguage: targetCode
        )

        guard let translation = translations.first else {
            throw TranslatorError.noTranslations
        }

        print(translation)
    }
}
