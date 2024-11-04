//
//  StringsCatalog.swift
//  translate_strings
//
//  Created by Cenk Bilgen on 2024-10-06.
//

import Foundation

class StringsCatalog: Codable {
    let version: String
    let sourceLanguage: String
    var strings: [String: Entry]

    struct Entry: Codable {
        var shouldTranslate: Bool?
        var localizations: [String: [String: Unit]]? // [language: ["stringUnit": unit]]
        static let localizationsStringUnitKey = "stringUnit"
        struct Unit: Codable {
            var state: State
            var value: String
        }
        enum State: String, Codable {
            case new, translated
        }
    }

    enum Error: Swift.Error {
        case noEntry(String)
        case markedDoNotTranslate
        // TODO: NSLocalizedString
//        case .noEntry(let entry):
//            return String(format: NSLocalizedString("No entry found for '%@'.", comment: "No entry found error"), entry)
//        case .markedDoNotTranslate:
//            return NSLocalizedString("The text is marked as 'Do Not Translate'.", comment: "Do not translate error")
    }
}

extension StringsCatalog {

    static func read(url: URL) throws -> StringsCatalog {
        try JSONDecoder().decode(
            StringsCatalog.self,
            from: try Data(contentsOf: url)
        )
    }

    func output() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }

    func getTranslation(key: String, language: String) throws -> String? {
        guard let entry = strings[key] else {
            throw Error.noEntry(key)
        }
        if entry.shouldTranslate == false {
            return key
        } else if let unit = entry.localizations?[language.lowercased()]?[StringsCatalog.Entry.localizationsStringUnitKey] {
            return if unit.state == .translated {
                unit.value
            } else {
                nil
            }
        } else {
            return nil
        }
    }

    func addTranslation(key: String, language: String, value: String) throws {
        guard let entry = strings[key] else {
            throw Error.noEntry(key)
        }
        guard entry.shouldTranslate != false else {
            throw Error.markedDoNotTranslate
        }
        let unit = Entry.Unit(state: .translated, value: value)
        if entry.localizations == nil {
            self.strings[key]?.localizations = [language.lowercased():
                                                    [StringsCatalog.Entry.localizationsStringUnitKey: unit]]
        } else {
            self.strings[key]?
                .localizations?[language.lowercased()] = [StringsCatalog.Entry.localizationsStringUnitKey: unit]
        }
    }
}

