//
//  Translate.swift
//  translate_strings
//
//  Created by Cenk Bilgen on 2024-10-06.
//

import Foundation
import Translation

public protocol Translator {
    var sourceLanguage: Locale.LanguageCode? { get }
    func translate(texts: [String], targetLanguage: Locale.LanguageCode) async throws -> [String]
}

public struct TranslateDeepL: Translator {
    let key: String

    // see https://developers.deepl.com/docs/resources/supported-languages#source-languages
    public let sourceLanguage: Locale.LanguageCode?

    public init(key: String, sourceLanguage: Locale.LanguageCode?) {
        self.key = key
        self.sourceLanguage = sourceLanguage
    }

    let baseURL = URL(string: "https://api-free.deepl.com/v2/translate")!

    func makeRequest() -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.setValue("DeepL-Auth-Key \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    let encoder: JSONEncoder = {
        let coder = JSONEncoder()
        coder.keyEncodingStrategy = .convertToSnakeCase
        return coder
    }()

    let decoder: JSONDecoder = {
        let coder = JSONDecoder()
        coder.keyDecodingStrategy = .convertFromSnakeCase
        return coder
    }()

    func makeRequestBody(texts: [String], targetLanguage: Locale.LanguageCode) throws -> Data {
        // specfic to DeepL service
        guard texts.count <= 50 else {
            throw TranslatorError.unsupportedRequest
        }
        struct Body: Encodable {
            let sourceLang: String? // nil is automatic
            let targetLang: String
            let text: [String]
            // let formality = "prefer_more"
            // let context = "text on a UI element of an app"
        }

        return try encoder.encode(Body(
            sourceLang: sourceLanguage?.identifier.uppercased(),
            targetLang: targetLanguage.identifier.uppercased(),
            text: texts))
    }

    public func translate(texts: [String], targetLanguage: Locale.LanguageCode) async throws -> [String] {
        var request = makeRequest()
        request.httpMethod = "POST"
        request.httpBody = try makeRequestBody(
            texts: texts,
            targetLanguage: targetLanguage
        )
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslatorError.invalidResponse
        }
        let statusCode = httpResponse.statusCode
        guard statusCode == 200 else {
            throw TranslatorError.httpResponseError(statusCode)
        }
        struct Body: Decodable {
            struct Translation: Decodable {
                let text: String
                let detectedSourceLanguage: String
            }
            let translations: [Translation]
        }
        let body = try decoder.decode(Body.self, from: data)
        return body.translations.map(\.text)
    }
}
