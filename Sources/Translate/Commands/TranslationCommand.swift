//
//  TranslationCommand.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-04.
//

import Foundation
import ArgumentParser
import Algorithms
import TranslationServices

protocol TranslationServiceCommand: AsyncParsableCommand {
    static var model: (String, Locale.LanguageCode?) throws -> any Translator { get }
    var keyEnvVarName: String { get }
}

extension TranslationServiceCommand {

    func runText(keyOptions: KeyOptions,
                 translationOptions: TranslationOptions,
                 source: String?,
                 text: String) async throws {
        guard let targetCode = Locale(identifier: translationOptions.target).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }
        let sourceCode: Locale.LanguageCode? = if let source {
            Locale(identifier: source).language.languageCode
        } else {
            nil
        }
        let key = try KeyArgumentParser.parse(value: keyOptions.key, envVarName: keyEnvVarName, allowSTDIN: false)
        let translator = try Self.model(key, sourceCode)
        let output = try await translator.translate(texts: [text], targetLanguage: targetCode)
        guard let translation = output.first else {
            throw TranslatorError.noTranslations
        }
        print(translation)
    }

    func runStringsCatalog(keyOptions: KeyOptions,
                   translationOptions: TranslationOptions,
                   stringsCatalogFile file: String,
                   outFile: String,
                   verbose: Bool) async throws {

        let url = URL(fileURLWithPath: file)
        let catalog = try StringsCatalog.read(url: url)

        guard let sourceCode = Locale(identifier: catalog.sourceLanguage).language.languageCode else {
            throw TranslatorError.unrecognizedSourceLanguage
        }
        guard let targetCode = Locale(identifier: translationOptions.target).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }

        #if DEBUG
        print("Translating \(sourceCode) to \(targetCode)")
        #endif

        let key = try KeyArgumentParser.parse(value: keyOptions.key, envVarName: keyEnvVarName, allowSTDIN: false)
        let translator = try Self.model(key, sourceCode)

        printVerbose(verbose, "Parsing file \(url.lastPathComponent)")
        let stringKeys = catalog.strings.keys

        let untranslatedStringKeys = try stringKeys.filter { key in
            let translation = try catalog.getTranslation(key: key, language: targetCode.identifier)
            return translation == nil
        }
        printVerbose(verbose, ("Untranslated string keys:"))
        printVerbose(verbose, untranslatedStringKeys.joined(separator: "\n"))
        printVerbose(verbose, "----------------------------------------")

        // NOTE: Send translation in batches of 10 at a time,
        // arbitrary balance between minimizing network calls and not doing too much at once

        // NOTE: Using TaskGroup might cause rate limit issues with service, no need to rush
        for chunk in untranslatedStringKeys.chunks(ofCount: 10) {
            let texts = Array(chunk)
            let translations = try await translator.translate(
                texts: texts,
                targetLanguage: targetCode
            )
            printVerbose(verbose, "Sent \(texts.count) items for translation. Recieved \(translations.count)")
            guard texts.count == translations.count else {
                throw TranslatorError.missingResponses
            }
            for index in texts.indices {
                printVerbose(verbose, "\(texts[index]) -> \(translations[index])")
                try catalog
                    .addTranslation(
                        key: texts[index],
                        language: targetCode.identifier,
                        value: translations[index]
                    )
            }
        }

        let output = try catalog.output()
        if outFile == "-" {
            guard let string = String(data: output, encoding: .utf8) else {
                throw TranslatorError.notUTF8
            }
            print(string)
        } else {
            try output.write(to: URL(filePath: outFile))
            printVerbose(verbose, "New strings catalog file written to \(outFile)")
        }
    }

    // TODO: Use oslog
    private func printVerbose(_ verbose: Bool, _ string: String) {
        if verbose {
            print(string)
        }
    }

}

struct KeyOptions: ParsableArguments {
    static let helpText =
    """
    Required. You can provide the API key using one of the following methods:
    1. Keychain: Use the format `key_id:[YOUR_KEY_ID]` like `key_id:key1`, to prompt a search for the API key stored under your specified `YOUR_KEY_ID` in the keychain. If the key isn't found, you will be asked to enter it, and it will be saved under `YOUR_KEY_ID`, scoped to this program, for future use.
    2. Literal Value: If you do not specify a format, the provided value will be used directly as the API key.
    3. Environment Variable (NOT RECOMMENDED): Use the format `env:`. The program will look for the API key in environment variables \(DeepLCommand.keyEnvVarName) or \(GoogleCommand.keyEnvVarName). 
    """

    @Option(name: .shortAndLong,
            help: ArgumentHelp(stringLiteral: KeyOptions.helpText)
    )
    var key: String
}

// MARK: Source/Target Language Codes

struct TranslationOptions: ParsableArguments {

    // NOTE: Source langauge can be autodetected from String Catalog, auto recognized, or required for Google.
    // So handle it separately for each translation service

    @Option(name: .shortAndLong,
            help: "The target language identifier, ie \"de\". Required."
    )
    var target: String
}
