//
//  Interpolation.swift
//  translate_tool
//
//  Created by Cenk Bilgen on 2026-02-23.
//

import OSLog
import Logging

extension OSLogInterpolation {
    /// Appends an interpolated value, making it public by default if it conforms to CustomStringConvertible.
    /// This covers many common types like String, Int, Double, Bool, Array, etc.
    mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T) {
        #if DEBUG
        appendInterpolation(value.description, privacy: .public)
        #else
        appendInterpolation(value.description, privacy: .auto)
        #endif
    }

    // You might still need specific overloads for types that don't conform
    // to CustomStringConvertible or if you need different default privacy/formatting.
    // For example, if you have a custom struct that you want to log publicly
    // but it doesn't conform to CustomStringConvertible, you'd add:
    /*
    mutating func appendInterpolation(_ myCustomStruct: MyCustomStruct) {
        appendInterpolation(myCustomStruct.debugDescription, privacy: .public)
    }
    */

    // Example of a custom interpolation that applies privacy based on a debug flag
    mutating func appendInterpolation<T: CustomStringConvertible>(debugPublic value: T) {
        #if DEBUG
        appendInterpolation(value.description, privacy: .public)
        #else
        appendInterpolation(value.description, privacy: .auto)
        #endif
    }
}
