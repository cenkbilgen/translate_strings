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
//    static var configuration: CommandConfiguration {
//        CommandConfiguration(commandName: "available_languages",
//                             abstract: "List available translation language codes for \(C.name) service.")
//    }
//                
//    func run() async throws {
//        print("TODO: Get available languages.")
////        let languages = try await translator.availableLanguageCodes()
////        print(languages.sorted().map {
////            $0.uppercased()
////        }.formatted(.list(type: .and)))
//    }
//}
//
