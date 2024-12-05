//
//  StringsCatalog.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-25.
//

import Foundation
import ArgumentParser
import TranslationServices
import StringsCatalogKit

struct StringsCatalogCommand<C: TranslatorCommand>: AsyncParsableCommand, VerbosePrinter {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: C.commandName,
                             abstract: "Translate Xcode Strings Catalog using \(C.name) service.")
    }
    
    @OptionGroup var globalOptions: StringsCatalogGlobalOptions
    
    mutating func run() async throws {
        let url = URL(fileURLWithPath: globalOptions.inputFile)
        let catalog = try StringsCatalog.read(url: url)
        
        guard let sourceCode = Locale(identifier: catalog.sourceLanguage).language.languageCode else {
            throw TranslatorError.unrecognizedSourceLanguage
        }
        guard let targetCode = Locale(identifier: globalOptions.translationOptions.targetLanguage).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }
        
#if DEBUG
        print("Translating \(sourceCode) to \(targetCode)")
#endif
        
        let key = try KeyArgumentParser.parse(value: globalOptions.keyOptions.key, envVarName: C.keyEnvVarName, allowSTDIN: true)
#if DEBUG
        printVerbose(globalOptions.verbose, "Using key \(key)")
#endif
        let translator = try C.model(key: key, source: sourceCode)
        
        printVerbose(globalOptions.verbose, "Parsing file \(url.lastPathComponent)")
        let stringKeys = catalog.strings.keys
        
        let untranslatedStringKeys = try stringKeys.filter { key in
            let translation = try catalog.getTranslation(key: key, language: targetCode.identifier)
            return translation == nil
        }
        printVerbose(globalOptions.verbose, ("Untranslated string keys:"))
        printVerbose(globalOptions.verbose, untranslatedStringKeys.joined(separator: "\n"))
        printVerbose(globalOptions.verbose, "----------------------------------------")
        
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
                printVerbose(globalOptions.verbose, "\(texts[index]) -> \(translations[index])")
                try catalog
                    .addTranslation(
                        key: texts[index],
                        language: targetCode.identifier,
                        value: translations[index]
                    )
            }
        }
        
        let output = try catalog.output()
        let outFile = globalOptions.outputFile
        if outFile == "-" {
            guard let string = String(data: output, encoding: .utf8) else {
                throw TranslatorError.notUTF8
            }
            print(string)
        } else {
            try output.write(to: URL(filePath: outFile))
            printVerbose(globalOptions.verbose, "New strings catalog file written to \(outFile)")
        }
    }
}
