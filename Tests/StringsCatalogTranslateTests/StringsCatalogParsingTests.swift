import Foundation
import Testing
@testable import StringsCatalogKit

private enum CatalogSample {
    static let base = #"""
    {
      "version": "1.0",
      "sourceLanguage": "en",
      "strings": {
        "greeting": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello"
              }
            }
          }
        },
        "pending": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "new",
                "value": "Translate this"
              }
            }
          }
        },
        "emptyDescription": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": ""
              }
            }
          }
        },
        "specialFormat": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Line\\nBreak \"Quote\""
              }
            }
          }
        },
        "doNotTranslate": {
          "shouldTranslate": false,
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Keep this as-is"
              }
            }
          }
        }
      }
    }
    """#

    static let malformed = #"""
    {
      "version": ["unexpected", "type"],
      "sourceLanguage": "en",
      "strings": "not-a-dictionary"
    }
    """#
}

private enum CatalogTestError: Error, LocalizedError {
    case invalidUTF8Output
    case unexpectedStructure(String)

    var errorDescription: String? {
        switch self {
        case .invalidUTF8Output:
            return "Catalog output is not valid UTF-8."
        case .unexpectedStructure(let detail):
            return "Unexpected catalog JSON structure: \(detail)"
        }
    }
}

private final class CatalogFixture {
    let fileURL: URL
    let catalog: StringsCatalog

    init(sample: String = CatalogSample.base) throws {
        let directory = FileManager.default.temporaryDirectory
        let url = directory
            .appending(path: UUID().uuidString, directoryHint: .notDirectory)
            .appendingPathExtension("xcstrings")
        try sample.write(to: url, atomically: true, encoding: .utf8)
        let catalog = try StringsCatalog.read(url: url)
        self.fileURL = url
        self.catalog = catalog
    }

    deinit {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func serializedCatalog() throws -> StringsCatalog {
        let data = try catalog.output()
        return try JSONDecoder().decode(StringsCatalog.self, from: data)
    }

    func serializedString() throws -> String {
        let data = try catalog.output()
        guard let string = String(data: data, encoding: .utf8) else {
            throw CatalogTestError.invalidUTF8Output
        }
        return string
    }
}

@Suite("Catalog Tests")
struct StringsCatalogParsing {
    private let fixture: CatalogFixture

    init() throws {
        fixture = try CatalogFixture()
    }

    @Test("Catalog file decodes schema metadata")
    func catalogDecodesMetadata() throws {
        let catalog = fixture.catalog
        #expect(catalog.version == "1.0")
        #expect(catalog.sourceLanguage == "en")
        #expect(catalog.strings.keys.contains("greeting"))
    }

    @Test("Pending entries return nil translations before processing")
    func pendingEntryIsNil() throws {
        #expect(try fixture.catalog.getTranslation(key: "pending", language: "en") == nil)
    }

    @Test("Adding translation creates new language entry")
    func addingTranslationAddsLanguage() throws {
        try fixture.catalog.addTranslation(key: "greeting", language: "es", value: "Hola")
        #expect(try fixture.catalog.getTranslation(key: "greeting", language: "es") == "Hola")

        let serialized = try fixture.serializedCatalog()
        #expect(try serialized.getTranslation(key: "greeting", language: "es") == "Hola")
    }

    @Test("Serialized output contains new language section")
    func serializedOutputIncludesLanguage() throws {
        try fixture.catalog.addTranslation(key: "pending", language: "fr", value: "Bonjour")
        let output = try fixture.serializedString()
        #expect(output.contains("\"fr\""))
        #expect(output.contains("Bonjour"))
    }

    @Test("Overwriting translation updates serialized value")
    func overwritingTranslationUpdatesOutput() throws {
        try fixture.catalog.addTranslation(key: "greeting", language: "es", value: "Hola")
        try fixture.catalog.addTranslation(key: "greeting", language: "es", value: "Hola Mundo")
        let serialized = try fixture.serializedString()
        #expect(serialized.contains("\"Hola Mundo\""))
        #expect(serialized.contains("\"es\""))
    }

    @Test("Empty translations stay empty through serialization")
    func emptyTranslationRemainsEmpty() throws {
        #expect(try fixture.catalog.getTranslation(key: "emptyDescription", language: "en") == "")
        let serialized = try fixture.serializedCatalog()
        #expect(try serialized.getTranslation(key: "emptyDescription", language: "en") == "")
    }

    @Test("Do-not-translate flag prevents mutation")
    func doNotTranslateThrows() throws {
        var sawError = false
        do {
            try fixture.catalog.addTranslation(key: "doNotTranslate", language: "es", value: "No traducir")
        } catch {
            if case StringsCatalog.Error.markedDoNotTranslate = error {
                sawError = true
            } else {
                throw error
            }
        }
        #expect(sawError)
    }

    @Test("Missing keys throw noEntry error")
    func missingKeyThrows() throws {
        do {
            _ = try fixture.catalog.getTranslation(key: "missing-key", language: "en")
            Issue.record("missing-key should not exist")
        } catch {
            if case let StringsCatalog.Error.noEntry(key) = error {
                #expect(key == "missing-key")
            } else {
                throw error
            }
        }
    }

    @Test("Serialization can be decoded back into catalog")
    func roundTripSerialization() throws {
        try fixture.catalog.addTranslation(key: "greeting", language: "de", value: "Hallo")
        let roundTrip = try fixture.serializedCatalog()
        #expect(roundTrip.version == fixture.catalog.version)
        #expect(roundTrip.sourceLanguage == fixture.catalog.sourceLanguage)
        #expect(try roundTrip.getTranslation(key: "greeting", language: "de") == "Hallo")
    }

    @Test("Malformed catalog file fails decoding")
    func malformedCatalogThrows() throws {
        let directory = FileManager.default.temporaryDirectory
        let url = directory
            .appending(path: UUID().uuidString, directoryHint: .notDirectory)
            .appendingPathExtension("xcstrings")
        defer {
            try? FileManager.default.removeItem(at: url)
        }

        try CatalogSample.malformed.write(to: url, atomically: true, encoding: .utf8)
        do {
            _ = try StringsCatalog.read(url: url)
            Issue.record("Decoding should fail for malformed catalog")
        } catch {
            #expect(error is DecodingError)
        }
    }

    @Test("Multiple language additions increment counts")
    func multipleTranslationsUpdateCounts() throws {
        try fixture.catalog.addTranslation(key: "greeting", language: "it", value: "Ciao")
        try fixture.catalog.addTranslation(key: "emptyDescription", language: "pt", value: "Descrição")
        let counts = fixture.catalog.getLanguages()
        #expect(counts["it"] == 1)
        #expect(counts["pt"] == 1)
    }
}
