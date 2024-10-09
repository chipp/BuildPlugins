//
//  SwiftLint.swift
//
//
//  Created by Vladimir Burdukov on 24/04/2024.
//

import Foundation
import PackagePlugin

@main
struct SwiftLint: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: any PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        guard let files = target.sourceModule?.sourceFiles(withSuffix: "swift").map(\.url) else {
            return []
        }

        return [
            try makeCommand(
                executable: try context.tool(named: "swiftlint").url,
                root: context.package.directoryURL,
                pluginWorkDirectory: context.pluginWorkDirectoryURL,
                files: files
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftLint: XcodeBuildToolPlugin {
        func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
            let files = target.inputFiles.filter { $0.type == .source }.map(\.url)

            return [
                try makeCommand(
                    executable: try context.tool(named: "swiftlint").url,
                    root: context.xcodeProject.directoryURL,
                    pluginWorkDirectory: context.pluginWorkDirectoryURL,
                    files: files
                )
            ]
        }
    }
#endif

private func makeCommand(
    executable: URL,
    root: URL,
    pluginWorkDirectory: URL,
    files: [URL]
) throws -> PackagePlugin.Command {
    var arguments: [String] = [
        "lint",
        "--config", root.appending(components: ".swiftlint.yml").absoluteString
    ]

    let baselineFileURL = root.appending(components: ".swiftlint.baseline.json")

    if FileManager.default.fileExists(atPath: baselineFileURL.path) {
        arguments.append("--baseline")
        arguments.append(baselineFileURL.absoluteString)
    }

    if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
        arguments.append("--no-cache")
        arguments.append("--strict")
    } else {
        arguments.append(contentsOf: [
            "--cache-path",
            pluginWorkDirectory.appending(components: "cache").absoluteString
        ])
    }

    arguments.append(contentsOf: files.map(\.absoluteString))

    return .prebuildCommand(
        displayName: "SwiftLint",
        executable: executable,
        arguments: arguments,
        outputFilesDirectory: pluginWorkDirectory.appending(components: "output")
    )
}
