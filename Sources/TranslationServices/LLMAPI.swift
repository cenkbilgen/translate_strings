//
//  LLMAPI.swift
//  translate_tool
//
//  Created by cenk on 2024-12-12.
//

import Foundation

protocol LLMAPI: Translator {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    func makePromptRequest(prompt: String) throws -> URLRequest
    associatedtype ResponseBody: Decodable
    func decodeStructuredReply(body: ResponseBody) throws -> LLM.Schema.StructuredContent
}

extension LLMAPI {
    internal func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        return request
        // NOTE: body is empty
    }
    
    private func send(prompt: String) async throws -> ResponseBody {
        let request = try makePromptRequest(prompt: prompt)
        let body: ResponseBody = try await send(request: request, decoder: NetService.decoder)
        return body
    }
    
    public func translate(texts: [String],
                          sourceLanguage sourceLangauge: Locale.LanguageCode?,
                          targetLanguage: Locale.LanguageCode) async throws -> [String] {
        guard texts.count <= 50 else {
            throw TranslatorError.overTextCountLimit
        }
        guard let textsJSON = String(data: try NetService.encoder.encode(texts), encoding: .utf8) else {
            throw TranslatorError.invalidInput
        }

        let body = try await send(prompt:  "Translate a JSON list of strings from langauge code \(sourceLangauge?.identifier ?? "automatically detected from the text") to language with code \(targetLanguage). Your output must also be an unformatted list of JSON with a top-level array. Here is the list: \(textsJSON)")
        
        let structuredReply = try decodeStructuredReply(body: body)
        return structuredReply.data
    }
    
    public func availableLanguageCodes() async throws -> Set<String> {
        let body = try await send(prompt: "List all written langauges you as an llm can translate to. Your output must be a JSON array of strings. Each language as it's IETF BCP 47 language code with only the first part, such as DE, EN, ZH and that matches the language as it would be represented in an Xcode StringsCatalog file.")
        let structuredReply = try decodeStructuredReply(body: body)
        return Set(structuredReply.data)
    }
}

// General data types commonly used

enum LLM {
    struct Message: Codable {
        let role: Role
        enum Role: String, Codable {
            case user, assistant, system
        }
        let content: String
    }
    
    struct Schema: Encodable {
        struct StructuredContent: Decodable {
            let data: [String]
        }
        
        let type = "object"
        let additionalProperties: Bool = false
        let required: [String] = ["data"]
        let properties = Properties()
        struct Properties: Encodable {
            let data = StringArraySchema()
        }
        // NOTE: specifying camel case doesn't effect encoding, even with custom encoder init
//                        enum CodingKeys: String, CodingKey {
//                            case additionalProperties = "additionalProperties"
//                            case type, required, properties
//                        }
    }
    struct StringArraySchema: Encodable {
        let type = "array"
        let items = [
            "type": "string"
        ]
    }
}
