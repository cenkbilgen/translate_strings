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

    func makeRequest(prompt: String) throws -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")

        struct Body: Encodable {
            let model: String
            let messages: [Message]
            let n: Int = 1
            
            // NOTES: On JSON Schema
            // 1. See: https://json-schema.org/overview/what-is-jsonschema
            // 2. MUST also instruct to output json: ie "Provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"
            // 3. Can't specify a schema with top-level Array, must be object
            // 4. must be lower case
            /*
             "response_format": {
                 "type": "json_schema",
                 "json_schema": {
                   "name": "ArrayOfStringsObject",
                   "schema": {
                     "type": "object",
                     "properties": {
                       "data": {
                         "type": "array",
                         "items": {
                           "type": "string"
                         }
                       }
                     },
                     "required": ["data"]
                   },
                   "strict": true
                 }
               }
             }
*/
            
            struct ResponseFormat: Encodable {
                let type = "json_schema"
                let jsonSchema = JSONSchema()
                struct JSONSchema: Encodable {
                    let name = "ArrayOfString" // OpenAI requires, not part of spec
                    let strict = true
                    let schema = Schema()
                    struct Schema: Encodable {
                        let type = "object"
                        let additionalProperties = false
                        let properties = Properties()
                        struct Properties: Encodable {
                            let data = StringArraySchema()
                        }
                        //let required = #"data"#
                    }
                    struct StringArraySchema: Encodable {
                        let type = "array"
                        let items = [
                            "type": "string"
                        ]
                    }
                }
            }
            struct JSONResponseFormat: Encodable {
                let type = "json_array"
            }
            let responseFormat = JSONResponseFormat() //ResponseFormat()
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
            prompt: "Translate a JSON list of strings from langauge code \(sourceLanguage) to language with code \(targetLanguage). Your output must also be an unformatted list of JSON with a top-level array. Here is the list: \(textsJSON)"
        )

        struct Body: Decodable {
            let choices: [Choice]
            struct Choice: Decodable {
                let index: Int
                let finishReason: String // TODO: make enum, ie stop
                let message: Message
            }
        }

        let body: Body = try await send(request: request, decoder: NetService.decoder)
        let translatedTexts = body.choices.map(\.message).first?.content // should be 1 in n=1
        guard let data = translatedTexts?.data(using: .utf8) else {
            throw TranslatorError.notUTF8
        }
        let results = try JSONDecoder().decode([String].self, from: data)
        return results
    }
}
