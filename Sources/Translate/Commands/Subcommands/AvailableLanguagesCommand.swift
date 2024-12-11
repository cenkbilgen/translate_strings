//
//  AvailableLanguages.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-25.
//

import Foundation
import ArgumentParser
import TranslationServices

struct AvailableLanguagesCommand<C: TranslatorCommand>: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "available_languages",
                             abstract: "List available translation language codes for \(C.name) service.")
    }
    
    @OptionGroup var keyOptions: KeyOptions
    
    func run() async throws {
        let command = C()
        let translator = try command.makeTranslator()
        let languages = try await translator.availableLanguageCodes()
        print(languages.sorted().map {
            $0.uppercased()
        }.formatted(.list(type: .and)))
    }
}
