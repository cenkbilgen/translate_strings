//
//  TranslatorOpenAI.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2026-02-25.
//

import Foundation
import Testing
@testable import StringsCatalogKit
@testable import TranslationServices

@Suite("Translator OpenAI", .enabled("API Key", {
    // TODO: extract these definitions out of the executable target so can access here
    Process().environment?["OPENAI_API_KEY"] != nil
}))
class OpenAITranslatorTest {
    
    let translator: any Translator
    
    init() throws {
        guard let key = Process().environment?["OPENAI_API_KEY"] else {
            // Testing framework shouldn't really get here, but check anyway
            throw TranslatorError.noAuthorizationKey
        }
        translator = try TranslatorOpenAI(key: key)
    }
    
    private let sampleTexts = ["Tokyo", "Helsinki", "Aurora", "fjord", "glacier"]

    private func translateAndExpect(
        target: Locale.LanguageCode,
        expected: [String]
    ) async throws {
        let result = try await translator.translate(
            texts: sampleTexts,
            sourceLanguage: .english,
            targetLanguage: target
        )
        #expect(result == expected)
    }

    @Test("OpenAI translator returns expected Finnish translations")
    func translateFinnish() async throws {
        try await translateAndExpect(
            target: Locale.LanguageCode("fi"),
            expected: ["Tokio", "Helsinki", "Aurora", "vuono", "jäätikkö"]
        )
    }

    @Test("OpenAI translator returns expected Japanese translations")
    func translateJapanese() async throws {
        try await translateAndExpect(
            target: Locale.LanguageCode("ja"),
            expected: ["東京", "ヘルシンキ", "オーロラ", "フィヨルド", "氷河"]
        )
    }
    
}
