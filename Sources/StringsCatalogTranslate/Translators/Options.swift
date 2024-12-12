//
//  GlobalOptions.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-22.
//

import ArgumentParser

struct StringsCatalogGlobalOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Verbose output to STDOUT")
    var verbose: Bool = false
    
    @OptionGroup var keyOptions: KeyOptions
    
    @Flag(name: .customLong("available_languages"),
          help: "List available translation language codes for service.") var getAvailableLanguages: Bool = false
}

struct KeyOptions: ParsableArguments {
    static let keyArgumentHelpText = """
    --key <key> (Required)
    The API key used for authentication. You can provide it in one of two ways:
    1. From Keychain:
       Use the format `key_id:[YOUR_KEY_ID]` (e.g., `key_id:key1`). The tool will search for the specified `YOUR_KEY_ID` in the keychain.
       - If the key isn't found, you will be prompted to enter it.
       - The entered key will be securely saved under the provided `YOUR_KEY_ID` for future use.
    2. Direct Value:
       Simply pass the API key as a literal string without any format (e.g., `--key your-api-key`).
    """
//    3. Environment Variable (NOT RECOMMENDED): Use the format `env:`. The program will look for the API key in environment variables \("DeepLCommand.keyEnvVarName") or \(GoogleCommand.keyEnvVarName).
//    """
    
    @Option(name: .shortAndLong,
            help: ArgumentHelp(stringLiteral: KeyOptions.keyArgumentHelpText)
    )
    var key: String
}

// MARK: Source/Target Language Codes

struct TargetTranslationOptions: ParsableArguments {
    @Option(name: .shortAndLong,
            help: "The target language identifier, ie \"de\". Case-insensitive."
    )
    var targetLanguage: String = "xxx"
}

//struct SourceTranslationOptions: ParsableArguments {
//    @Option(name: .shortAndLong,
//            help: "Override autodetected source language identifier, ie \"de\". Case-insensitive."
//    )
//    var sourceLanguage: String?
//}

struct FileOptions: ParsableArguments {
    @Option(name: .shortAndLong,
            help: "Input Strings Catalog file.",
            completion: .file(extensions: ["xcstrings"]))
    var inputFile: String = "Localizable.xcstrings"
    
    @Option(name: .shortAndLong,
            help: "Output Strings Catalog file. Overwrites. Use \"-\" for STDOUT.",
            completion: .file(extensions: ["xcstrings"]))
    var outputFile: String = "Localizable.xcstrings"
}



