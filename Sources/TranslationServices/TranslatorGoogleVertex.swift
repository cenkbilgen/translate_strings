//
//  TranslatorDeepL.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2024-10-15.
//

import Foundation

public struct TranslatorGoogleVertex: Translator {
    
    // See: https://cloud.google.com/vertex-ai/generative-ai/docs/translate/translate-text#translation_llm

    let key: String
    let baseURL: URL
    let runLocation: String = "us-central1" // from GCP
    let projectId: String

    public init(key: String,
                projectId: String?) throws {
        self.key = key
        guard let projectId,
              let baseURL = URL(string:  "https://\(runLocation)-aiplatform.googleapis.com/v1/projects/\(projectId)/locations/\(runLocation)/publishers/google/models/cloud-translate-text:predict") else {
            throw TranslatorError.invalidURL
        }
        self.projectId = projectId
        self.baseURL = baseURL
    }

    func makeRequest(texts: [String], sourceLanguage: Locale.LanguageCode, targetLanguage: Locale.LanguageCode) throws -> URLRequest {
        guard texts.count <= 50 else {
            throw TranslatorError.overTextCountLimit
        }
        var request = URLRequest(url: baseURL)
        request.setValue(key, forHTTPHeaderField: "X-goog-api-key: API_KEY")

        /*
         "instances": [{
         "source_language_code": "SOURCE_LANGUAGE_CODE",
         "target_language_code": "TARGET_LANGUAGE_CODE",
         "contents": ["SOURCE_TEXT"],
         "mimeType": "MIME_TYPE",
         "model": "projects/PROJECT_ID/locations/LOCATION/models/general/translation-llm"
         }]
         */

        struct Body: Encodable {
            let instances: [Instance]
            struct Instance: Encodable {
                let sourceLanguageCode: String
                let targetLanguageCode: String
                let contents: [String]
                let model: String
            }
        }

        request.httpMethod = "POST"
        request.httpBody = try NetService.encoder.encode(Body(
            instances: [
                Body
                    .Instance(
                        sourceLanguageCode: sourceLanguage.identifier,
                        targetLanguageCode: targetLanguage.identifier,
                        contents: texts,
                        model: "projects/\(projectId)/locations/\(runLocation)/models/general/translation-llm"
                    )
            ]
        ))
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

    public func translate(texts: [String],
                          sourceLanguage sourceLanugage: Locale.LanguageCode?,
                          targetLanguage: Locale.LanguageCode) async throws -> [String] {
        guard let sourceLanugage else {
            throw TranslatorError.sourceLanguageRequired
        }
        
        let request = try makeRequest(
            texts: texts,
            sourceLanguage: sourceLanugage,
            targetLanguage: targetLanguage
        )

        /*
         {
           "translations": [
             {
               "translatedText": "TRANSLATED_TEXT"
             }
           ],
           "languageCode": "TARGET_LANGUAGE"
         }
         */
        // NOTE: unlike request, it's caml case

        struct Body: Decodable {
            let translations: [Translation]
            struct Translation: Decodable {
                let translatedText: String
            }
            let languageCode: String
        }

        let body: Body = try await send(request: request, decoder: JSONDecoder())
        return body.translations.map(\.translatedText)
    }
}
