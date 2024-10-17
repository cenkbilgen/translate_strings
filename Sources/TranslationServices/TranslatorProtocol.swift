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
    func availableLanguageCodes() async throws -> Set<String>
    init(key: String, sourceLanguage: Locale.LanguageCode?) // nil is automatic
}

enum NetService {
    static let encoder: JSONEncoder = {
        let coder = JSONEncoder()
        coder.keyEncodingStrategy = .convertToSnakeCase
        return coder
    }()

    static let decoder: JSONDecoder = {
        let coder = JSONDecoder()
        coder.keyDecodingStrategy = .convertFromSnakeCase
        return coder
    }()
}

extension Translator {

    func send<ResponseBody: Decodable>(request: URLRequest) async throws -> ResponseBody {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslatorError.invalidResponse
        }
        let statusCode = httpResponse.statusCode
        guard statusCode == 200 else {
            throw TranslatorError.httpResponseError(statusCode)
        }
        return try NetService.decoder.decode(ResponseBody.self, from: data)
    }

}
