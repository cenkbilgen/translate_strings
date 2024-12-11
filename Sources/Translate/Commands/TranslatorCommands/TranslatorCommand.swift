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
    
    var globalOptions: StringsCatalogGlobalOptions { get}
    
    associatedtype T: Translator
    func makeTranslator() throws -> T
}
