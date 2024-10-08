//
//  Errors.swift
//  translate_strings
//
//  Created by Cenk Bilgen on 2024-10-08.
//
//
import Foundation

public enum TranslatorError: Error {
    case unrecognizedSourceLanguage
    case unrecognizedTargetLanguage
    case invalidResponse
    case httpResponseError(Int)
    case noTranslations
    case unsupportedRequest
    case noEntry(String)
    case markedDoNotTranslate
    case noAuthorizationKey
    case keyInputFailed
    case missingResponses
    case notUTF8
}

// AI generated
extension TranslatorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unrecognizedSourceLanguage:
            return NSLocalizedString("The source language is not recognized.", comment: "Source language error")
        case .unrecognizedTargetLanguage:
            return NSLocalizedString("The target language is not recognized.", comment: "Target language error")
        case .invalidResponse:
            return NSLocalizedString("The response from the translation service was invalid.", comment: "Invalid response error")
        case .httpResponseError(let statusCode):
            return String(format: NSLocalizedString("Received HTTP error with status code %d.", comment: "HTTP response error"), statusCode)
        case .noTranslations:
            return NSLocalizedString("No translations were found.", comment: "No translations found")
        case .unsupportedRequest:
            return NSLocalizedString("The translation request is unsupported.", comment: "Unsupported request error")
        case .noEntry(let entry):
            return String(format: NSLocalizedString("No entry found for '%@'.", comment: "No entry found error"), entry)
        case .markedDoNotTranslate:
            return NSLocalizedString("The text is marked as 'Do Not Translate'.", comment: "Do not translate error")
        case .noAuthorizationKey:
            return NSLocalizedString("No authorization key was provided.", comment: "No authorization key error")
        case .keyInputFailed:
            return NSLocalizedString("Console input of key failed.", comment: "Key input failed error")
        case .missingResponses:
            return NSLocalizedString("Some expected responses are missing.", comment: "Missing responses error")
        case .notUTF8:
            return NSLocalizedString("The input text is not encoded in UTF-8.", comment: "Not UTF-8 encoded error")
        }
    }
}
