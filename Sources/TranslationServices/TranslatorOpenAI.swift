//
//  Untitled.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-21.
//

import Foundation

public struct TranslatorOpenAI: Translator {
    // See: https://platform.openai.com/docs/api-reference/chat/create

    let key: String
    let baseURL: URL
    public let sourceLanguage: Locale.LanguageCode?

    public init(key: String, projectId: String? = nil, sourceLanguage: Locale.LanguageCode?) throws {
        self.key = key
        guard let sourceLanguage else {
            throw TranslatorError.sourceLanguageRequired
        }
        self.sourceLanguage = sourceLanguage
        self.baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    }
    
    // NOTE: Used in Request and Response
    struct Message: Codable {
        let role: Role
        enum Role: String, Codable {
            case user, assistant, system
        }
        let content: String
    }

    func makeRequest(prompt: String, model: String = "gpt-4o") throws -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")

        struct Body: Encodable {
            let model: String
            let messages: [Message]
            let n: Int = 1
            // must also instruct to output json: ie "Provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"
            let responseFormat: String = #"{"type": "json_schema", "json_schema": { "[String]"}}"#
        }

        request.httpBody = try NetService.encoder.encode(Body(model: model, messages: [
            Message(role: .system, content: #"Provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"#),
            Message(role: .user, content: prompt)
        ]))

        return request
    }

    public func availableLanguageCodes() async throws -> Set<String> {
        let request = try makeRequest(
            prompt: "List all written langauges you as an llm can translate to. Your output must be a JSON array of strings. Each language as it's IETF BCP 47 language code.")

        let languages: [String] = try await send(request: request, decoder: JSONDecoder())
        return Set(languages)

    }

    public func translate(texts: [String], targetLanguage: Locale.LanguageCode) async throws -> [String] {
        guard texts.count <= 50 else {
            throw TranslatorError.overTextCountLimit
        }
        guard let sourceLanguage else {
            throw TranslatorError.sourceLanguageRequired
        }
        guard let textsJSON = String(data: try NetService.encoder.encode(texts), encoding: .utf8) else {
            throw TranslatorError.invalidInput
        }

        let request = try makeRequest(
            prompt: "Translate a JSON list of strings from langauge code \(sourceLanguage) to language with code \(targetLanguage). Your output must also be an unformatted list of JSON. Here is the list: \(textsJSON)"
        )

        // NOTE: Looks similar to request body but slight difference mean can't reuse
        struct Body: Decodable {
            let choices: [Choice]
            struct Choice: Decodable {
                let index: Int
                let finishReason: String // TODO: make enum, ie stop
                let message: Message
            }
        }

        let body: Body = try await send(request: request, decoder: JSONDecoder())
        let translatedTexts = body.choices.map(\.message).first?.content // should be 1 in n=1
        guard let data = translatedTexts?.data(using: .utf8) else {
            throw TranslatorError.notUTF8
        }
        // response mixes camel and snake case, use standard decoder
        let results = try JSONDecoder().decode([String].self, from: data)
        return results
    }
}
