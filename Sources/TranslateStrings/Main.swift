import Foundation
import Algorithms
import ArgumentParser
import Shared

@main
struct TranslateStrings: AsyncParsableCommand {
    @Flag(name: .shortAndLong, help: "Verbose output to STDOUT")
    var verbose: Bool = false

    @Option(name: .shortAndLong,
            help: "Input Strings Catalog file.",
            completion: .file(extensions: ["xcstrings"]))
    var file: String = "Localizable.xcstrings"

    @Option(name: .shortAndLong,
            help: "Output Strings Catalog file. Overwrites. Use \"-\" for STDOUT.",
            completion: .file(extensions: ["xcstrings"]))
    var outFile: String = "Localizable.xcstrings"

    static let keyIDPrefix = "key_id:"
    @Option(
        name: .shortAndLong,
        help: "API key. Required. If prefixed with \"\(Self.keyIDPrefix)\" the value of the key will be retrieved from the keychain for that id (macOS only) otherwise it will treated as the the literal key value."
    )
    var key: String

    @Option(name: .shortAndLong, help: "Allow STDIN input if prompted for key input. May be needed if using script or no direct tty access.")
    var allowSTDIN = false

    static let sourceDefault = "from xcstrings file"
    @Option(name: .shortAndLong, help: "Override the source language identifier, ie \"en\".")
    var source: String = Self.sourceDefault

    @Option(name: .shortAndLong, help: "The target language identifier, ie \"de\". Required.")
    var target: String

    mutating func run() async throws {
        let url = URL(fileURLWithPath: file)
        let catalog = try StringsCatalog.read(url: url)

        let source = (source == Self.sourceDefault) ? catalog.sourceLanguage : source
        guard let targetCode = Locale(identifier: target).language.languageCode else {
            throw TranslatorError.unrecognizedTargetLanguage
        }
        guard let sourceCode = Locale(identifier: source).language.languageCode else {
            throw TranslatorError.unrecognizedSourceLanguage
        }

        let key = try Arguments.parseKeyArgument(
            value: key,
            allowSTDIN: allowSTDIN
        )

        #if DEBUG
        print("Translating \(sourceCode) to \(targetCode)")
        #endif

        let translator = TranslateDeepL(
            key: key,
            sourceLanguage: sourceCode
        )
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

