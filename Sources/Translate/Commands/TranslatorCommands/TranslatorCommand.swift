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

// TODO: Use os_log
protocol VerbosePrinter {}
    
extension VerbosePrinter {
    func printVerbose(_ verbose: Bool, _ string: String) {
        if verbose {
            print(string)
        }
    }
}
