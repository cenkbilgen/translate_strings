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
        let key = try KeyArgumentParser.parse(value: keyOptions.key, envVarName: C.keyEnvVarName, allowSTDIN: true)
        let translator = try C.model(key: key, source: nil)
        let languages = try await translator.availableLanguageCodes()
        print(languages.formatted(.list(type: .and)))
    }
}
