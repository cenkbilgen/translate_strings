// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "translate_tool",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "strings_catalog_translate", targets: ["StringsCatalogTranslate", "TranslationServices"]),
        .library(name: "TranslationServices", targets: ["TranslationServices"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/cenkbilgen/StringsCatalogKit.git", from: "1.0.0"),
        .package(url: "https://github.com/cenkbilgen/KeychainSimple.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "StringsCatalogTranslate",
            dependencies: [
                "TranslationServices",
                .product(name: "StringsCatalogKit", package: "StringsCatalogKit"),
                .product(name: "KeychainSimple", package: "KeychainSimple"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            path: "Sources/StringsCatalogTranslate",
            swiftSettings: [
                .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
            ]
        ),
        .target(name: "TranslationServices",
                dependencies: [
                ],
                path: "Sources/TranslationServices",
                swiftSettings: [
                    .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
                ]),
    ]
)
