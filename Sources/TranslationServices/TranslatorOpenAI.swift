//
//  Untitled.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-21.
//

import Foundation

public struct TranslatorOpenAI: Translator, ModelSelectable, LLMAPI {
    // See: https://platform.openai.com/docs/api-reference/chat/create

    let baseURL = URL(string: "https://api.openai.com/v1")!
    let headers: [String: String]
    let model: String
    
    public init(key: String, model: String = "gpt-4o") throws {
        self.model = model
        self.headers = ["Authorization": "Bearer \(key)"]
    }
    
    internal func makePromptRequest(prompt: String) throws -> URLRequest {
        var request = makeRequest(path: "chat/completions")
        struct Body: Encodable {
            let model: String
            let messages: [LLM.Message]
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
                    let schema = LLM.Schema()
//                    struct Schema: Encodable {
//                        let type = "object"
//                        let additionalProperties: Bool = false
//                        let required: [String] = ["data"]
//                        let properties = Properties()
//                        struct Properties: Encodable {
//                            let data = StringArraySchema()
//                        }
//                        // NOTE: specifying camel case doesn't effect encoding, even with custom encoder init
////                        enum CodingKeys: String, CodingKey {
////                            case additionalProperties = "additionalProperties"
////                            case type, required, properties
////                        }
//                    }
//                    struct StringArraySchema: Encodable {
//                        let type = "array"
//                        let items = [
//                            "type": "string"
//                        ]
//                    }
                }
            }
            let response_format = ResponseFormat()
        }

        request.httpBody = try JSONEncoder().encode(Body(model: model, messages: [
            LLM.Message(role: .system, content: #"Provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"#),
            LLM.Message(role: .user, content: prompt)
        ]))

        return request
    }
    
    struct ResponseBody: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let index: Int
            let finishReason: String // TODO: make enum, ie stop
            let message: Message
            struct Message: Decodable {
                let role: LLM.Message.Role
                let content: LLM.Schema.StructuredContent
            }
        }
    }
    
//    func decodeAssistantReply(body: ResponseBody) throws -> String {
//        guard let message = body.choices.first?.message else {
//            throw TranslatorError.unexpectedResponseStructure
//        }
//        return message.content
//    }
    func decodeStructuredReply(body: ResponseBody) throws -> LLM.Schema.StructuredContent {
        guard let reply = body.choices.first?.message.content else {
            throw TranslatorError.unexpectedResponseStructure
        }
        return reply
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
