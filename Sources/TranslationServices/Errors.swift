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
    case overTextCountLimit
    case noAuthorizationKey
    case keyInputFailed
    case missingResponses
    case notUTF8
    case invalidURL
    case invalidInput
    case sourceLanguageRequired
    case unexpectedResponseFormat
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
        case .noAuthorizationKey:
            return NSLocalizedString("No authorization key was provided.", comment: "No authorization key error")
        case .keyInputFailed:
            return NSLocalizedString("Console input of key failed.", comment: "Key input failed error")
        case .missingResponses:
            return NSLocalizedString("Some expected responses are missing.", comment: "Missing responses error")
        case .notUTF8:
            return NSLocalizedString("The input text is not encoded in UTF-8.", comment: "Not UTF-8 encoded error")
            case .sourceLanguageRequired:
                return NSLocalizedString("This service requires a source language to be specified.", comment: "Source language required")

        default:
                return NSLocalizedString("An error occurred.", comment: "Unspecified error")
        }
    }
}
