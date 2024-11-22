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

protocol TranslatorCommand: AsyncParsableCommand {
    static var name: String { get }
    static var commandName: String { get }
    static var keyEnvVarName: String { get }
    associatedtype T: Translator
    static func model(key: String, source: Locale.LanguageCode?) throws -> T
}

extension TranslatorCommand {
// MARK: text command

    static func runText(keyOptions: KeyOptions,
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
        let key = try KeyArgumentParser.parse(value: keyOptions.key, envVarName: Self.keyEnvVarName, allowSTDIN: true)
        let translator = try Self.model(key: key, source: sourceCode)
        let output = try await translator.translate(texts: [text], targetLanguage: targetCode)
        guard let translation = output.first else {
            throw TranslatorError.noTranslations
        }
        print(translation)
    }

// MARK: strings_catalog command

    static func runStringsCatalog(keyOptions: KeyOptions,
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

        let key = try KeyArgumentParser.parse(value: keyOptions.key, envVarName: Self.keyEnvVarName, allowSTDIN: true)
        #if DEBUG
        printVerbose(verbose, "Using key \(key)")
        #endif
        let translator = try model(key: key, source: sourceCode)

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

// MARK: available_languages command

    static func runAvailableLanguages(keyOptions: KeyOptions) async throws {
        let key = try KeyArgumentParser.parse(value: keyOptions.key, envVarName: Self.keyEnvVarName, allowSTDIN: true)
        let translator = try Self.model(key: key, source: nil)
        let languages = try await translator.availableLanguageCodes()
        print(languages.formatted(.list(type: .and)))
    }

    // TODO: Use oslog
    static private func printVerbose(_ verbose: Bool, _ string: String) {
        if verbose {
            print(string)
        }
    }

}
