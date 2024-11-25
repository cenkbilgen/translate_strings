//
//  StringsCatalog.swift
//  translate_strings
//
//  Created by Cenk Bilgen on 2024-10-06.
//

import Foundation

public final class StringsCatalog: Codable {
    public let version: String
    public let sourceLanguage: String
    public var strings: [String: Entry]

    public struct Entry: Codable {
        public var shouldTranslate: Bool?
        public var localizations: [String: [String: Unit]]? // [language: ["stringUnit": unit]]
        public static let localizationsStringUnitKey = "stringUnit"
        public struct Unit: Codable {
            public var state: State
            public var value: String
        }
        public enum State: String, Codable {
            case new, translated
        }
    }

    public enum Error: Swift.Error {
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

    public static func read(url: URL) throws -> StringsCatalog {
        try JSONDecoder().decode(
            StringsCatalog.self,
            from: try Data(contentsOf: url)
        )
    }

    public func output() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }

    public func getTranslation(key: String, language: String) throws -> String? {
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

    public func addTranslation(key: String, language: String, value: String) throws {
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

