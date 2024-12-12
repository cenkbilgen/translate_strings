//
//  StringsCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-25.
//

import Foundation
import ArgumentParser
import Algorithms
import TranslationServices
import StringsCatalogKit

protocol StringsCatalogCommand: AsyncParsableCommand, TranslatorMaker {
    static var name: String { get }
    static var commandName: String { get }
    static var keyEnvVarName: String { get }
    
    var globalOptions: StringsCatalogGlobalOptions { get}
    var fileOptions: FileOptions { get }
    var targetLanguageOptions: TargetTranslationOptions { get }
}

protocol TranslatorMaker {
    associatedtype T: Translator
    func makeTranslator() throws -> T
}

extension StringsCatalogCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: commandName,
                             abstract: "Translate Xcode Strings Catalog using \(name) service.")
    }
    
    func printVerbose(_ string: String) {
        if globalOptions.verbose {
            print(string)
        }
    }
    
    func validate() throws {
        // not really validating, just a convenient place for printing
        #if DEBUG
        print(globalOptions)
        print(fileOptions)
        print(targetLanguageOptions)
        #endif
    }
    
    mutating func run() async throws {
        let key = try KeyArgumentParser.parse(value: globalOptions.keyOptions.key,
                                              envVarName: Self.keyEnvVarName,
                                              onlyInteractive: true)
#if DEBUG
        printVerbose("Using key \(key)")
#endif
        let translator = try makeTranslator()
        
        if globalOptions.getAvailableLanguages {
            let languages = try await translator.availableLanguageCodes()
            print(languages.sorted().map {
                $0.uppercased()
            }.formatted(.list(type: .and)))
            return
        }
        
        let url = URL(fileURLWithPath: fileOptions.inputFile)
        let catalog = try StringsCatalog.read(url: url)
        
        guard let sourceCode = Locale(identifier: catalog.sourceLanguage).language.languageCode else {
            throw TranslatorError.unrecognizedSourceLanguage
        }
                
//        guard let targetLanguage = targetLanguageOptions.targetLanguage else {
//            print("a target language argument is required when running \(Self.commandName) command")
//            throw MainCommand.Error.missingRequiredArgument("targetLanguage")
//        }
        let targetLanguage = targetLanguageOptions.targetLanguage
        guard let targetCode = Locale(identifier: targetLanguage).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }
        
#if DEBUG
        print("Translating \(sourceCode) to \(targetCode)")
#endif
        
        printVerbose("Parsing file \(url.lastPathComponent)")
        let stringKeys = catalog.strings.keys
        
        let untranslatedStringKeys = try stringKeys.filter { key in
            let translation = try catalog.getTranslation(key: key, language: targetCode.identifier)
            return translation == nil
        }
        printVerbose("Untranslated string keys:")
        printVerbose(untranslatedStringKeys.joined(separator: "\n"))
        printVerbose("----------------------------------------")
        
        // NOTE: Send translation in batches of 10 at a time,
        // arbitrary balance between minimizing network calls and not doing too much at once
        
        // NOTE: Using TaskGroup might cause rate limit issues with service, no need to rush
        for chunk in untranslatedStringKeys.chunks(ofCount: 10) {
            let texts = Array(chunk)
            let translations = try await translator.translate(
                texts: texts,
                targetLanguage: targetCode
            )
            guard texts.count == translations.count else {
                throw TranslatorError.missingResponses
            }
            for index in texts.indices {
                printVerbose("\(texts[index]) -> \(translations[index])")
                try catalog
                    .addTranslation(
                        key: texts[index],
                        language: targetCode.identifier,
                        value: translations[index]
                    )
            }
        }
        
        let output = try catalog.output()
        let outFile = fileOptions.outputFile
        if outFile == "-" {
            guard let string = String(data: output, encoding: .utf8) else {
                throw TranslatorError.notUTF8
            }
            print(string)
        } else {
            try output.write(to: URL(filePath: outFile))
            printVerbose("New strings catalog file written to \(outFile)")
        }
    }
}
