import Foundation
import ArgumentParser
import Shared

@main
struct Translate: AsyncParsableCommand {
    @Option(
        name: .shortAndLong,
        help: "API key. Required. If prefixed with \"\(Arguments.keyIDPrefix)\" the value of the key will be retrieved from the keychain for that id (macOS only) otherwise it will treated as the the literal key value."
    )
    var key: String

    @Option(name: .shortAndLong, help: "Specify the source language identifier, ie \"en\". Optional.")
    var source: String?

    @Option(name: .shortAndLong, help: "The target language identifier, ie \"de\". Required.")
    var target: String

    @Argument(help: "The phrase to translate")
    var input: String

    mutating func run() async throws {

        let sourceCode: Locale.LanguageCode? = try {
            if source == nil {
                return nil
            } else if let source,
                      let code = Locale(identifier: source).language.languageCode {
                return code
            } else {
                throw TranslatorError.unrecognizedSourceLanguage
            }
        }()

        guard let targetCode = Locale(identifier: target).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }

        let key = try Arguments.parseKeyArgument(value: key, allowSTDIN: false)

        #if DEBUG
        print("Translating \(sourceCode ?? "AUTO") to \(targetCode)")
        #endif

        let translator = TranslateDeepL(
            key: key,
            sourceLanguage: sourceCode
        )

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

