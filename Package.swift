// swift-tools-version: 6.0
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
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.55.3/swiftformat.artifactbundle.zip",
            checksum: "5c28b67a7c64b2494324b0fe7c1a6c73bb42cc3f673f9be36fa7759cc55b34f7"
        ),
        .binaryTarget(
            name: "swiftlint",
            url: "https://github.com/realm/SwiftLint/releases/download/0.57.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "c88bf3e5bc1326d8ca66bc3f9eae786f2094c5172cd70b26b5f07686bb883899"
        )
    ]
)