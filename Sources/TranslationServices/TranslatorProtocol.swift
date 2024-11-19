//
//  Translate.swift
//  translate_strings
//
//  Created by Cenk Bilgen on 2024-10-06.
//

import Foundation

public protocol Translator {
    var sourceLanguage: Locale.LanguageCode? { get }
    func translate(texts: [String], targetLanguage: Locale.LanguageCode) async throws -> [String]
    func availableLanguageCodes() async throws -> Set<String>
    init(key: String, projectId: String?, sourceLanguage: Locale.LanguageCode?) throws
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

    func send<ResponseBody: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = NetService.decoder
    ) async throws -> ResponseBody {

        #if DEBUG
        print(String(data: request.httpBody!, encoding: .utf8)!)
        #endif

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslatorError.invalidResponse
        }
        let statusCode = httpResponse.statusCode
        guard statusCode == 200 else {
            print(String(data: data, encoding: .utf8)!)
            throw TranslatorError.httpResponseError(statusCode)
        }

        #if DEBUG
        print(String(data: data, encoding: .utf8)!)
        #endif

        return try decoder.decode(ResponseBody.self, from: data)
    }

}
