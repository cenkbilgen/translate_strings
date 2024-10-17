// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "translate_tool",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "Translate",
            dependencies: [
                "Translator",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            path: "Sources/TranslateCLI",
            swiftSettings: [
                .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
            ]
        ),
        .target(name: "Translator",
                path: "Sources/TranslationServices",
                swiftSettings: [
                    .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
                ]),
    ]
)
