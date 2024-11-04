//
//  TranslateOptions.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-17.
//

import Foundation
import ArgumentParser
import Translator

struct KeyOptions: ParsableArguments {
    @Option(name: .shortAndLong,
        help: ArgumentHelp(stringLiteral: Arguments.HelpText.key)
    )
    var key: String
}

struct TranslationOptions: ParsableArguments {
    @Option(name: .shortAndLong,
            help: "Specify the source language identifier, ie \"en\". Optional.")
    var source: String?

    @Option(name: .shortAndLong,
            help: "The target language identifier, ie \"de\". Required."
    )
    var target: String

}

struct TranslationModelOptions: ParsableArguments {
    @Option(name: .shortAndLong,
            help: "The translation model to use.")
    var model: TranslationModel = .deepl
}
