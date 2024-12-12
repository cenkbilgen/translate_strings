////
////  AvailableLanguages.swift
////  translate_tool
////
////  Created by Cenk Bilgen on 2024-11-25.
////
//
//import Foundation
//import ArgumentParser
//import TranslationServices
//
//struct AvailableLanguagesCommand<C: StringsCatalogCommand>: AsyncParsableCommand {
//    
//    static var configuration: CommandConfiguration {
//        CommandConfiguration(commandName: "available_languages",
//                             abstract: "List available translation language codes for \(C.name) service.")
//    }
//    
//    @OptionGroup var keyOptions: KeyOptions
//    
//    func run() async throws {
//        let parsedKey = try KeyArgumentParser.parse(value: keyOptions.key)
//        let key = try await KeyArgumentParser.getKeyValue(parsed: parsedKey)
//        let translator = try await C().makeTranslator(key: key)
//        let languages = try await translator.availableLanguageCodes()
//        print(languages.sorted().map {
//            $0.uppercased()
//        }.formatted(.list(type: .and)))
//    }
//}
