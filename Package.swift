// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildPlugins",
    platforms: [.macOS(.v13)],
    products: [
        .plugin(name: "SwiftFormat", targets: ["SwiftFormat"]),
        .plugin(name: "SwiftFormatRun", targets: ["SwiftFormatRun"]),
        .plugin(name: "SwiftLint", targets: ["SwiftLint"]),
        .plugin(name: "SwiftLintRun", targets: ["SwiftLintRun"])
    ],
    targets: [
        .plugin(
            name: "SwiftFormat",
            capability: .buildTool,
            dependencies: [.target(name: "swiftformat")]
        ),
        .plugin(
            name: "SwiftFormatRun",
            capability: .command(
                intent: .custom(verb: "swiftformat", description: "Run swiftformat"),
                permissions: [.writeToPackageDirectory(reason: "Fixing SwiftFormat issues")]
            ),
            dependencies: [.target(name: "swiftformat")]
        ),
        .plugin(
            name: "SwiftLint",
            capability: .buildTool,
            dependencies: [.target(name: "swiftlint")]
        ),
        .plugin(
            name: "SwiftLintRun",
            capability: .command(
                intent: .custom(verb: "swiftlint", description: "Run swiftlint lint --fix"),
                permissions: [.writeToPackageDirectory(reason: "Fixing SwiftLint issues")]
            ),
            dependencies: [.target(name: "swiftlint")]
        ),
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.54.3/swiftformat.artifactbundle.zip",
            checksum: "b9d4e1a76449ab0c3beb3eb34fb3dcf396589afb1ee75764767a6ef541c63d67"
        ),
        .binaryTarget(
            name: "swiftlint",
            url: "https://github.com/realm/SwiftLint/releases/download/0.56.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "146ef723e83d301b9f1ef647dc924a55dae293887e633618e76f8cb526292f0c"
        )
    ]
)
