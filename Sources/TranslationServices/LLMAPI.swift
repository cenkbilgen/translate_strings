//
//  LLMAPI.swift
//  translate_tool
//
//  Created by cenk on 2024-12-12.
//

import Foundation

protocol LLMAPI {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    func makePromptRequest(prompt: String) throws -> URLRequest
}

extension LLMAPI {
    func makeRequest(path: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        return request
        // NOTE: body is empty
    }
    
    var availableLanguagePrompt: String {
        "List all written langauges you as an llm can translate to. Your output must be a JSON array of strings. Each language as it's IETF BCP 47 language code with only the first part, such as DE, EN, ZH and that matches the language as it would be represented in an Xcode StringsCatalog file."
    }
}

// General data types commonly used

enum LLM {
    // NOTE: Used in Request and Response
    struct Message: Codable {
        let role: Role
        enum Role: String, Codable {
            case user, assistant, system
        }
        let content: String
    }
    
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
