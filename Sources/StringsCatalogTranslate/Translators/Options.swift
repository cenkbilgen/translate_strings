//
//  GlobalOptions.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-22.
//

import ArgumentParser

struct StringsCatalogGlobalOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Enable verbose output to STDOUT.")
    var verbose: Bool = false
    
    @OptionGroup var keyOptions: KeyOptions
    
    @Flag(name: .customLong("available_languages"),
          help: "List all available translation language codes supported by the service.") var getAvailableLanguages: Bool = false
}

struct KeyOptions: ParsableArguments {
    static let keyArgumentHelpText = """
    --key <key> 
    1. **From Keychain**:
        - Format: `key_id:[YOUR_KEY_ID]` (e.g., `key_id:key1`)
        - The tool will search for `YOUR_KEY_ID` in the keychain.
        - If not found, you will be prompted to enter the key.
        - The entered key will be securely saved under `YOUR_KEY_ID` for future use.
    2. **From Environment Variable**:
        - Set a standard environment variable like `OPENAI_API_KEY`.
        - Or specify a custom variable using the format `env:MY_API_KEY`.
    3. **Direct Value**:
        - Provide the API key as a plain string (e.g., `--key your-api-key`).
    """
    
    @Option(name: .shortAndLong,
            help: ArgumentHelp(stringLiteral: KeyOptions.keyArgumentHelpText)
    )
    var key: String?
}

// MARK: Source/Target Language Codes

struct TargetTranslationOptions: ParsableArguments {
    @Option(name: .shortAndLong,
            help: "Target language identifier (e.g., `de` for German). Case-insensitive."
    )
    var targetLanguage: String?
}

//struct SourceTranslationOptions: ParsableArguments {
//    @Option(name: .shortAndLong,
//            help: "Override autodetected source language identifier, ie \"de\". Case-insensitive."
//    )
//    var sourceLanguage: String?
//}

struct FileOptions: ParsableArguments {
    @Option(name: .shortAndLong,
            help: "Path to the input Strings Catalog file.",
            completion: .file(extensions: ["xcstrings"]))
    var inputFile: String = "Localizable.xcstrings"
    
    @Option(name: .shortAndLong,
            help: """
Path to the output Strings Catalog file.
    - This file will be overwritten if it exists.
    - Use `-` to output to STDOUT.
""",
            completion: .file(extensions: ["xcstrings"]))
    var outputFile: String = "Localizable.xcstrings"
}

struct ModelOptions {
    static let modelHelp =  ArgumentHelp("Specify the model to use.")
}



