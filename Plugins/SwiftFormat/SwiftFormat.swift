//
//  SwiftFormat.swift
//
//
//  Created by Vladimir Burdukov on 24/04/2024.
//

import Foundation
import PackagePlugin

@main
struct SwiftFormat: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: any PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        guard let files = target.sourceModule?.sourceFiles(withSuffix: "swift").map(\.url) else {
            return []
        }

        return [
            try makeCommand(
                executable: try context.tool(named: "swiftformat").url,
                root: context.package.directoryURL,
                pluginWorkDirectory: context.pluginWorkDirectoryURL,
                files: files
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftFormat: XcodeBuildToolPlugin {
        func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
            let files = target.inputFiles.filter { $0.type == .source }.map(\.url)

            return [
                try makeCommand(
                    executable: try context.tool(named: "swiftformat").url,
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
    var arguments = ["--lint"]

    if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
        arguments.append(contentsOf: ["--cache", "ignore"])
    } else {
        arguments.append(contentsOf: [
            "--cache",
            pluginWorkDirectory.appending(components: "swiftformat.cache").absoluteString
        ])
        arguments.append("--lenient")
    }

    arguments.append(contentsOf: files.map(\.absoluteString))

    return .prebuildCommand(
        displayName: "SwiftFormat",
        executable: executable,
        arguments: arguments,
        outputFilesDirectory: pluginWorkDirectory.appending(components: "output")
    )
}
