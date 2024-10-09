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
        guard let files = target.sourceModule?.sourceFiles(withSuffix: "swift").map(\.path) else {
            return []
        }

        return [
            try makeCommand(
                executable: try context.tool(named: "swiftformat").path,
                root: context.package.directory,
                pluginWorkDirectory: context.pluginWorkDirectory,
                files: files
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftFormat: XcodeBuildToolPlugin {
        func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
            let files = target.inputFiles.filter { $0.type == .source }.map(\.path)

            return [
                try makeCommand(
                    executable: try context.tool(named: "swiftformat").path,
                    root: context.xcodeProject.directory,
                    pluginWorkDirectory: context.pluginWorkDirectory,
                    files: files
                )
            ]
        }
    }
#endif

private func makeCommand(
    executable: Path,
    root: Path,
    pluginWorkDirectory: Path,
    files: [Path]
) throws -> PackagePlugin.Command {
    var arguments = ["--lint"]

    if ProcessInfo.processInfo.environment["CI"] == "TRUE" {
        arguments.append(contentsOf: ["--cache", "ignore"])
    } else {
        arguments.append(contentsOf: [
            "--cache",
            pluginWorkDirectory.appending("swiftformat.cache").string
        ])
        arguments.append("--lenient")
    }

    arguments.append(contentsOf: files.map(\.string))

    return .prebuildCommand(
        displayName: "SwiftFormat",
        executable: executable,
        arguments: arguments,
        outputFilesDirectory: pluginWorkDirectory.appending("output")
    )
}
