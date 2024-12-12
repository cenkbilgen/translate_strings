//
//  Untitled.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-11-21.
//

import Foundation

public struct TranslatorAnthropic: Translator, ModelSelectable, LLMAPI {
    
    // See: https://docs.anthropic.com/en/api/messages

    let baseURL = URL(string: "https://api.anthropic.com/v1")!
    let headers: [String: String]
    let model: String
    
    public init(key: String, model: String = "claude-3-5-haiku-latest") throws {
        self.model = model
        self.headers = ["x-api-key": key,
                        "anthropic-version": "2023-06-01"]
    }
    
    let toolName = "StringArray" // check when response comes back that this matches
    
    func makePromptRequest(prompt: String) throws -> URLRequest {
        var request = makeRequest(path: "messages")
        
        struct RequestBody: Encodable {
            let model: String
            let maxTokens = 1024
            let system = #"You only provide a JSON response containing an array of strings: ['example1', 'example2', 'example3']"#
            let messages: [LLM.Message]
            let tools: [Tool]
                /*tools: [
                  {
                    "name": "get_stock_price",
                    "description": "Get the current stock price for a given ticker symbol.",
                    "input_schema": {
                      "type": "object",
                      "properties": {
                        "ticker": {
                          "type": "string",
                          "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
                        }
                      },
                      "required": ["ticker"]
                    }
                  }
                 ]
                 */
        }
        
        struct Tool: Encodable {
            let name: String
            let description: String
            let inputSchema: LLM.Schema
        }

        request.httpBody = try NetService.encoder
            .encode(RequestBody(
                model: model,
                messages: [
                    LLM.Message(role: .user, content: prompt)
                ],
                tools: [
                    Tool(name: toolName,
                         description: "Array of translated strings",
                         inputSchema: LLM.Schema())
                    ]
                ))

        return request
    }
    
    /*
     {"id":"msg_01XSkUh1BRh1HAcnt66GRMdh","type":"message","role":"assistant","model":"claude-3-5-haiku-20241022","content":[{"type":"text","text":"I'll use the StringArray tool to provide a comprehensive list of language codes I can potentially translate to:"},{"type":"tool_use","id":"toolu_01FX8wjSLz4T25xRVctXT5AH","name":"StringArray","input":{"data":["af","sq","am","ar","hy","az","eu","be","bn","bs","bg","ca","ceb","zh-CN","zh-TW","co","hr","cs","da","nl","en","eo","et","fi","fr","fy","gl","ka","de","el","gu","ht","ha","haw","he","hi","hmn","hu","is","ig","id","ga","it","ja","jw","kn","kk","km","ko","ku","ky","lo","la","lv","lt","lb","mk","mg","ms","ml","mt","mi","mr","mn","my","ne","no","ny","ps","fa","pl","pt","pa","ro","ru","sm","gd","sr","st","sn","sd","si","sk","sl","so","es","su","sw","sv","tl","tg","ta","tt","te","th","tr","uk","ur","ug","uz","vi","cy","xh","yi","yo","zu"]}}],"stop_reason":"tool_use","stop_sequence":null,"usage":{"input_tokens":408,"output_tokens":415}}

     */
    
    struct ResponseBody: Decodable {
        let content: [Content]
        struct Content: Decodable {
            // NOTE: this is type of response when specifying a tool, not text field
            let type: ToolType // tool_use
            enum ToolType: String, Decodable {
                case text
                case toolUse = "tool_use"
            }
            // for text type
            let text: String?
            
            // for tool_use type
            let name: String? // tool name should be StringArray or toolName var
            let input: Input?
            struct Input: Decodable {
                let data: [String]
            }
        }
        let stopReason: String
    }
    
    /*
     {"id":"msg_01GNPtAgB8vx6eRRe1tYoL9h","type":"message","role":"assistant","model":"claude-3-5-haiku-20241022","content":[{"type":"tool_use","id":"toolu_012uXXVJESQiReh1me18uiza","name":"StringArray","input":{"data":["af-ZA","am-ET","ar-SA","az-AZ","be-BY","bg-BG","bn-BD","bs-BA","ca-ES","cs-CZ","cy-GB","da-DK","de-DE","el-GR","en-US","es-ES","et-EE","eu-ES","fa-IR","fi-FI","fr-FR","ga-IE","he-IL","hi-IN","hr-HR","hu-HU","hy-AM","id-ID","is-IS","it-IT","ja-JP","ka-GE","kk-KZ","km-KH","kn-IN","ko-KR","lt-LT","lv-LV","mk-MK","ml-IN","mn-MN","mr-IN","ms-MY","mt-MT","my-MM","ne-NP","nl-NL","no-NO","or-IN","pa-IN","pl-PL","ps-AF","pt-BR","pt-PT","ro-RO","ru-RU","si-LK","sk-SK","sl-SI","so-SO","sq-AL","sr-RS","su-ID","sv-SE","sw-KE","ta-IN","te-IN","th-TH","tr-TR","uk-UA","ur-PK","uz-UZ","vi-VN","xh-ZA","zh-CN","zh-TW","zu-ZA"]}}],"stop_reason":"tool_use","stop_sequence":null,"usage":{"input_tokens":408,"output_tokens":472}}
     */
    
    func decodeArray(body: ResponseBody) throws -> [String] {
        guard let content = body.content
            .first(where: { content in
                content.type == .toolUse && content.name == toolName
            }),
              let stringArray = content.input?.data else {
            throw TranslatorError.unexpectedResponseFormat
        }
        return stringArray
    }

    public func availableLanguageCodes() async throws -> Set<String> {
        let request = try makePromptRequest(
            prompt: "List all written langauges you as an llm can translate to. Your output must be a JSON array of strings. Each language as it's IETF BCP 47 language code.")
        let body: ResponseBody = try await send(request: request, decoder: NetService.decoder)
        let languages = try decodeArray(body: body)
        return Set(languages)
    }

    public func translate(texts: [String],
                          sourceLanguage: Locale.LanguageCode?,
                          targetLanguage: Locale.LanguageCode) async throws -> [String] {
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
        
        // TODO: Factor out for the LLM protocol extension

        let body: ResponseBody = try await send(request: request, decoder: NetService.decoder)
//        guard let text = body.content.first?.text,
//              let data = text.data(using: .utf8) else {
//            throw TranslatorError.invalidResponse
//        }
//        let results = try JSONDecoder().decode([String].self, from: data)
        let results = try decodeArray(body: body)
        return results
    }
    
    // MARK: ModelSelectable
    
    public func listModels() async throws -> Set<String> {
        // see https://docs.anthropic.com/en/docs/about-claude/models
        // no endpoint to list
        return []
    }

}