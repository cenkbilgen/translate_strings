//
//  Untitled.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-21.
//

import Foundation

public struct TranslatorOpenAI: Translator, ModelSelectable {
    // See: https://platform.openai.com/docs/api-reference/chat/create

    let key: String
    let baseURL: URL
    let model: String
    
    public let sourceLanguage: Locale.LanguageCode?

    // TODO: Make model enum
    public init(key: String, model: String, sourceLanguage: Locale.LanguageCode?) throws {
        self.key = key
        self.model = model
//        guard let sourceLanguage else {
//            throw TranslatorError.sourceLanguageRequired
//        }
        self.sourceLanguage = sourceLanguage
//        self.baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
        self.baseURL = URL(string: "https://api.openai.com/v1")!
    }
    
    // NOTE: Used in Request and Response
    struct Message: Codable {
        let role: Role
        enum Role: String, Codable {
            case user, assistant, system
        }
        let content: String
    }
    
    func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        return request
    }

    func makePromptRequest(prompt: String) throws -> URLRequest {
        var request = makeRequest(path: "chat/completions")
        struct Body: Encodable {
            let model: String
            let messages: [Message]
            let n: Int = 1
            
            /* NOTES: On structured JSON Schema response
                1. See: https://json-schema.org/overview/what-is-jsonschema
                2. MUST also instruct to output json: ie "Provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"
                3. Can't specify a schema with top-level Array, must be "object"
                4. must be lower case
                5. additionalProperties: false, is required
            */
            
            // major pain, json_schema, response_format are snake case, additionalProperties is camel case,
            // can't use converting NetworkService Encoder and just specify CodingKey for "additionalProperties",
            // still converts it, so name properties in this mixed up way
            
            struct ResponseFormat: Encodable {
                let type = "json_schema"
                let json_schema = JSONSchema()
                struct JSONSchema: Encodable {
                    let name = "StringArrayObject" // OpenAI requires, not part of spec
                    let strict = true
                    let schema = Schema()
                    struct Schema: Encodable {
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
            }
            let response_format = ResponseFormat() //ResponseFormat()
        }

        request.httpBody = try JSONEncoder().encode(Body(model: model, messages: [
            Message(role: .system, content: #"Provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"#),
            Message(role: .user, content: prompt)
        ]))

        return request
    }
    
    struct ResponseBody: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let index: Int
            let finishReason: String // TODO: make enum, ie stop
            let message: Message
        }
    }
    
    struct Content: Decodable {
        let data: [String]
    }

    public func availableLanguageCodes() async throws -> Set<String> {
        let request = try makePromptRequest(
            prompt: "List all written langauges you as an llm can translate to. Your output must be a JSON array of strings. Each language as it's IETF BCP 47 language code.")
        let body: ResponseBody = try await send(request: request, decoder: NetService.decoder)
        guard let text = body.choices.first?.message.content,
              let data = text.data(using: .utf8) else {
            throw TranslatorError.invalidResponse
        }
        let languages = try JSONDecoder().decode(Content.self, from: data)
        return Set(languages.data)
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

        let request = try makePromptRequest(
            prompt: "Translate a JSON list of strings from langauge code \(sourceLanguage) to language with code \(targetLanguage). Your output must also be an unformatted list of JSON with a top-level array. Here is the list: \(textsJSON)"
        )

        let body: ResponseBody = try await send(request: request, decoder: NetService.decoder)
        guard let text = body.choices.first?.message.content,
              let data = text.data(using: .utf8) else {
            throw TranslatorError.invalidResponse
        }
        let results = try JSONDecoder().decode(Content.self, from: data)
        return results.data
    }
    
    // MARK: ModelSelectable
    
    public func listModels() async throws -> Set<String> {
        let request = makeRequest(path: "models")
        
        /*
         data": [
             {
               "id": "model-id-0",
               "object": "model",
               "created": 1686935002,
               "owned_by": "organization-owner"
             },
         */
        
        struct ResponseBody: Decodable {
            let data: [Model]
            struct Model: Decodable {
                let id: String
            }
        }
        
        let body: ResponseBody = try await send(request: request)
        return Set(body.data.map(\.id))
    }

}
