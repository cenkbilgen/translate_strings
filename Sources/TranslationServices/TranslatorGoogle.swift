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

public struct TranslatorGoogle: Translator {
    // See: https://cloud.google.com/vertex-ai/generative-ai/docs/translate/translate-text#translation_llm

    let key: String
    let baseURL: URL
    public let sourceLanguage: Locale.LanguageCode?

    public init(key: String, projectId: String? = nil, sourceLanguage: Locale.LanguageCode?) throws {
        self.key = key
        guard let sourceLanguage else {
            throw TranslatorError.sourceLanguageRequired
        }
        self.sourceLanguage = sourceLanguage
        guard let baseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(key)") else {
            throw TranslatorError.invalidURL
        }
        self.baseURL = baseURL
    }

    func makeRequest(texts: [String], sourceLanguage: Locale.LanguageCode, targetLanguage: Locale.LanguageCode) throws -> URLRequest {
        guard texts.count <= 50 else {
            throw TranslatorError.overTextCountLimit
        }
        var request = URLRequest(url: baseURL)

        // -d '{"contents":[{"parts":[{"text":"Explain how AI works"}]}]}' \

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        struct Body: Encodable {
            let contents: [Content]
            struct Content: Encodable {
                let parts: [Part]
                struct Part: Encodable {
                    let text: String
                }
            }
        }

        request.httpBody = try NetService.encoder.encode(Body(contents: [
            Body.Content(parts: [
                Body.Content.Part(text: "Translate the following strings found in an mobile app from langauge code \(sourceLanguage) to language with code \(targetLanguage). Only the results, each on a new line. Do not add any explanation or comment.: \(texts.joined(separator: "\n"))")
            ])
        ]))
        print("Request Body: \(String(data: request.httpBody!, encoding: .utf8)!)")
        return request
    }

    public func availableLanguageCodes() async throws -> Set<String> {
//        let request = makeRequest(path: "languages?type=target")
//        struct Language: Decodable {
//            let language: String
//            // let name: String
//            // let supportsFormaity: Bool
//        }
//        let body: [Language] = try await send(request: request)
//        return Set(body.map(\.language))
        // TODO:
        return []
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

    public func translate(texts: [String], targetLanguage: Locale.LanguageCode) async throws -> [String] {
        guard let sourceLanguage else {
            throw TranslatorError.sourceLanguageRequired
        }

        let request = try makeRequest(
            texts: texts,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )

        // NOTE: Looks similar to request body but slight difference mean can't reuse
        struct Body: Decodable {
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

        let body: Body = try await send(request: request, decoder: JSONDecoder())
        let translatedTexts = body.candidates.compactMap(\.content.parts.first?.text)
        return translatedTexts
    }
}
