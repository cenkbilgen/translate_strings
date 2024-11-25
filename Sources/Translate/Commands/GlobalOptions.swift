//
//  GlobalOptions.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-22.
//

import ArgumentParser

struct KeyOptions: ParsableArguments {
    static let helpText =
    """
    Required. You can provide the API key using one of the following methods:
    1. Keychain: Use the format `key_id:[YOUR_KEY_ID]` like `key_id:key1`, to prompt a search for the API key stored under your specified `YOUR_KEY_ID` in the keychain. If the key isn't found, you will be asked to enter it, and it will be saved under `YOUR_KEY_ID`, scoped to this program, for future use.
    2. Literal Value: If you do not specify a format, the provided value will be used directly as the API key.
    """
//    3. Environment Variable (NOT RECOMMENDED): Use the format `env:`. The program will look for the API key in environment variables \("DeepLCommand.keyEnvVarName") or \(GoogleCommand.keyEnvVarName).
//    """

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

struct StringsCatalogGlobalOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Verbose output to STDOUT")
    var verbose: Bool = false

    @OptionGroup var keyOptions: KeyOptions

    @OptionGroup var translationOptions: TranslationOptions
    
    @Option(name: .shortAndLong,
            help: "Input Strings Catalog file.",
            completion: .file(extensions: ["xcstrings"]))
    var file: String = "Localizable.xcstrings"
    
    @Option(name: .shortAndLong,
            help: "Output Strings Catalog file. Overwrites. Use \"-\" for STDOUT.",
            completion: .file(extensions: ["xcstrings"]))
    var outFile: String = "Localizable.xcstrings"
}

struct TextGlobalOptions: ParsableArguments {
    @OptionGroup var keyOptions: KeyOptions
    
    @OptionGroup var translationOptions: TranslationOptions
    
    @Option(name: .shortAndLong,
            help: "Override autodetected source language, ie \"en\". Optional.")
    var source: String?
    
    @Argument(help: "The phrase to translate")
    var input: String
}
