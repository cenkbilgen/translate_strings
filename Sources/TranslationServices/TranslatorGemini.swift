//
//  Untitled.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-22.
//

/*
curl \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Explain how AI works"}]}]}' \
  -X POST 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=YOUR_API_KEY'
*/

import Foundation

public struct TranslatorGemini: Translator, ModelSelectable, LLMAPI {
    // See: https://cloud.google.com/vertex-ai/generative-ai/docs/translate/translate-text#translation_llm

    let key: String
    let baseURL: URL
    let headers: [String: String]
    let model: String

    public init(key: String,
                model: String,
                projectId: String?) throws {
        self.key = key
        self.model = model
        self.headers = [
            "Content-Type": "application/json"
        ]
        guard let baseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(key)") else {
            throw TranslatorError.invalidURL
        }
        self.baseURL = baseURL
    }
    
    func listModels() async throws -> Set<String> {
        ["gemini-1.5-flash", "gemini-2.0-flash-exp"]
    }

    func makePromptRequest(prompt: String) throws -> URLRequest {
        var request = makeRequest(path: "")

        // -d '{"contents":[{"parts":[{"text":"Explain how AI works"}]}]}' \
        struct Body: Encodable {
            let contents: [Content]
            struct Content: Encodable {
                let parts: [Part]
                struct Part: Encodable {
                    let text: String
                }
            }
            struct GenerationConfig: Encodable {
                let responseMimeType = "application/json"

                /* the response schema is a subset of OpenAPI 3.0
                 which can be encoded as JSON, not yaml. Google's example:
                 response_schema={
                 "type": "STRING",
                 "enum": ["Percussion", "String", "Woodwind", "Brass", "Keyboard"],
                 },
                 */

                /*
                 type: array
                        items: type: string
                 */
                struct StringArraySchema: Encodable {
                    let type = "ARRAY"
                    let items = [
                        "type": "STRING"
                    ]
                }
                let responseSchema = StringArraySchema()
            }
            let generationConfig = GenerationConfig()
        }
        
        request.httpBody = try JSONEncoder().encode(Body(contents: [
            Body.Content(parts: [
                Body.Content.Part(text: prompt)
            ])
        ]))
        
        return request
    }
    
    func decodeStructuredReply(body: ResponseBody) throws -> LLM.Schema.StructuredContent {
//        guard let reply = body.candidates.first?.content.parts.map(\.text) else {
//            throw TranslatorError.unexpectedResponseStructure
//        }
        guard let text = body.candidates.first?.content.parts.first?.text,
              let data = text.data(using: .utf8) else {
            throw TranslatorError.unexpectedResponseStructure
        }
        // the structured content specification for Gemini is somewhat looser, but dont' want to make another data structure, just decode and cast as the LLM.Schema.StructuredContent
        let words = try JSONDecoder().decode([String].self, from: data)
        return LLM.Schema.StructuredContent(data: words)
    }
    

//    public func availableLanguageCodes() async throws -> Set<String> {
//        let request = try makePromptRequest(
//            prompt: "List all written langauges you as an llm can translate to. Your output must be a JSON array of strings. Each language as it's IETF BCP 47 language code.")
//
//        let body: ResponseBody = try await send(request: request, decoder: JSONDecoder())
//        guard let text = body.candidates.first?.content.parts.first?.text,
//              let data = text.data(using: .utf8) else {
//            throw TranslatorError.invalidResponse
//        }
//        let languages = try JSONDecoder().decode([String].self, from: data)
//        return Set(languages)
//    }
        
    struct ResponseBody: Decodable {
        let candidates: [Candidate]
        struct Candidate: Decodable {
            let finishReason: String // "STOP"
            let content: Content
            struct Content: Decodable {
                let role: String // "model" for response
                let parts: [Part]
                struct Part: Decodable {
                    let text: String
                }
            }
        }
    }

    /*
     "candidates": [
         {
           "content": {
             "parts": [
               {
                 "text": "## How AI Works: A Simple Explanation\n\nArtificial Intelligence (AI) is a broad field encompassing many techniques that enable computers to \"think\" and learn like humans. Here's a simplified explanation of how it works:\n\n**1. Data is King:** AI systems learn from massive datasets, just like humans learn from experience. This data can be anything from images and text to sensor readings and financial data.\n\n**2. Algorithms: The Learning Process:** AI uses algorithms, which are sets of instructions, to analyze and interpret this data. These algorithms can be categorized as:\n\n* **Supervised Learning:** The algorithm is \"trained\" on labeled data, where each piece of data has a known outcome. For example, feeding the algorithm many pictures of cats labeled \"cat\" helps it identify future pictures of cats.\n* **Unsupervised Learning:** The algorithm is given unlabeled data and must find patterns and relationships on its own. This is useful for tasks like clustering data into groups based on similarities.\n* **Reinforcement Learning:** The algorithm learns by trial and error, receiving feedback (rewards or penalties) for its actions. This is how AI systems like game-playing bots learn to win.\n\n**3. Models are Created:** As the algorithm processes the data, it builds a \"model\" – a representation of the patterns and relationships it discovered. This model acts like a brain that the AI uses to make predictions and decisions.\n\n**4. AI Makes Predictions:** Once trained, the AI can use its model to analyze new data and make predictions about the future. For example, a spam filter uses a model trained on labeled spam emails to identify and block new spam messages.\n\n**5. Continuous Learning:** AI is constantly learning and improving. New data is fed into the system, and the model is updated to reflect the changing patterns and relationships.\n\n**Here's a simple analogy:** Imagine teaching a child to recognize different animals. You show them pictures of cats and dogs labeled as such. This is like supervised learning. The child starts to notice the differences between cats and dogs. Over time, they can recognize new pictures of cats and dogs without needing to be told what they are.\n\n**AI is transforming many industries, from healthcare and finance to transportation and entertainment.** It's a powerful tool that can help us automate tasks, solve complex problems, and make better decisions.\n\n**However, it's important to note that AI is still under development and has limitations.** It's not perfect and can sometimes make mistakes. Ethical considerations are also crucial as AI becomes more sophisticated.\n\nThis is just a basic overview. AI is a vast and complex field with many different approaches and techniques. Learning more about specific AI applications and their impact on various sectors is important for understanding the true potential of this technology.\n"
               }
             ],
             "role": "model"
           },
           "finishReason": "STOP",
           "index": 0,
           "safetyRatings": [
             {
               "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
               "probability": "NEGLIGIBLE"
             },
             {
               "category": "HARM_CATEGORY_HATE_SPEECH",
               "probability": "NEGLIGIBLE"
             },
             {
               "category": "HARM_CATEGORY_HARASSMENT",
               "probability": "NEGLIGIBLE"
             },
             {
               "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
               "probability": "NEGLIGIBLE"
             }
           ]
         }
       ],
       "usageMetadata": {
         "promptTokenCount": 4,
         "candidatesTokenCount": 572,
         "totalTokenCount": 576
       },
       "modelVersion": "gemini-1.5-flash-latest"
     }


     */

//    public func translate(texts: [String],
//                          sourceLanguage: Locale.LanguageCode?,
//                          targetLanguage: Locale.LanguageCode) async throws -> [String] {
//        guard texts.count <= 50 else {
//            throw TranslatorError.overTextCountLimit
//        }
//        guard let sourceLanguage else {
//            throw TranslatorError.sourceLanguageRequired
//        }
//        guard let textsJSON = String(data: try NetService.encoder.encode(texts), encoding: .utf8) else {
//            throw TranslatorError.invalidInput
//        }
//
//        let request = try makePromptRequest(
//            prompt: "Translate a JSON list of strings from langauge code \(sourceLanguage) to language with code \(targetLanguage). Your output must also be an unformatted list of JSON. Here is the list: \(textsJSON)"
//        )
//
//        // NOTE: Looks similar to request body but slight difference mean can't reuse
//       
//
//        let body: ResponseBody = try await send(request: request, decoder: JSONDecoder())
//        let translatedTexts = body.candidates.compactMap(\.content.parts.first?.text).joined()
//        guard let data = translatedTexts.data(using: .utf8) else {
//            throw TranslatorError.notUTF8
//        }
//        // response mixes camel and snake case, use standard decoder
//        let results = try JSONDecoder().decode([String].self, from: data)
//        return results
//    }
}
