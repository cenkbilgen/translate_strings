//
//  TranslatorGemini.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-15.
//

// MARK: Translator for the DeepL Service

import Foundation

public struct TranslatorDeepL: Translator {
    let key: String

    // see https://developers.deepl.com/docs/resources/supported-languages#source-languages
    public let sourceLanguage: Locale.LanguageCode?

    public init(key: String, sourceLanguage: Locale.LanguageCode?) {
        self.key = key
        self.sourceLanguage = sourceLanguage
    }

    let baseURL = URL(string: "https://api-free.deepl.com/v2/")!

    func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.setValue("DeepL-Auth-Key \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    func makeRequestBody(texts: [String], targetLanguage: Locale.LanguageCode) throws -> Data {
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

        return try NetService.encoder.encode(Body(
            sourceLang: sourceLanguage?.identifier.uppercased(),
            targetLang: targetLanguage.identifier.uppercased(),
            text: texts))
    }

    public func availableLanguageCodes() async throws -> Set<String> {
        let request = makeRequest(path: "languages?type=target")
        struct Language: Decodable {
            let language: String
            // let name: String
            // let supportsFormaity: Bool
        }
        let body: [Language] = try await send(request: request)
        return Set(body.map(\.language))
    }

    public func translate(texts: [String], targetLanguage: Locale.LanguageCode) async throws -> [String] {
        var request = makeRequest(path: "translate")
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
        let body = try NetService.decoder.decode(Body.self, from: data)
        return body.translations.map(\.text)
    }
}


