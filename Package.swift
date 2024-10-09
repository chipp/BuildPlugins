// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BuildPlugins",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        .plugin(
            name: "SwiftFormat",
            targets: ["SwiftFormat"]
        ),
        .plugin(
            name: "SwiftFormatRun",
            targets: ["SwiftFormatRun"]
        ),
        .plugin(
            name: "SwiftLint",
            targets: ["SwiftLint"]
        ),
        .plugin(
            name: "SwiftLintRun",
            targets: ["SwiftLintRun"]
        ),
        .plugin(
            name: "Sourcery",
            targets: ["Sourcery"]
        )
    ],
    targets: [
        .plugin(
            name: "SwiftFormat",
            capability: .buildTool(),
            dependencies: [
                .target(name: "swiftformat")
            ]
        ),
        .plugin(
            name: "SwiftFormatRun",
            capability: .command(intent: .custom(verb: "swiftformat", description: "Run swiftformat"), permissions: [
                .writeToPackageDirectory(reason: "Fixing SwiftFormat issues")
            ]),
            dependencies: [
                .target(name: "swiftformat")
            ]
        ),
        .plugin(
            name: "SwiftLint",
            capability: .buildTool(),
            dependencies: [
                .target(name: "swiftlint")
            ]
        ),
        .plugin(
            name: "SwiftLintRun",
            capability: .command(intent: .custom(verb: "swiftlint", description: "Run swiftlint lint --fix"), permissions: [
                .writeToPackageDirectory(reason: "Fixing SwiftLint issues")
            ]),
            dependencies: [
                .target(name: "swiftlint")
            ]
        ),
        .plugin(
            name: "Sourcery",
            capability: .buildTool(),
            dependencies: [
                .target(name: "sourcery")
            ]
        ),
        .binaryTarget(
            name: "sourcery",
            url: "https://github.com/krzysztofzablocki/Sourcery/releases/download/2.2.5/sourcery-2.2.5.artifactbundle.zip",
            checksum: "875ef49ba5e5aeb6dc6fb3094485ee54062deb4e487827f5756a9ea75b66ffd8"
        ),
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.54.5/swiftformat.artifactbundle.zip",
            checksum: "39b4530054003cf9c668b0f9391b977fc13215925aaaaa3038d6379099b8486d"
        ),
        .binaryTarget(
            name: "swiftlint",
            url: "https://github.com/realm/SwiftLint/releases/download/0.57.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "a1bbafe57538077f3abe4cfb004b0464dcd87e8c23611a2153c675574b858b3a"
        )
    ]
)