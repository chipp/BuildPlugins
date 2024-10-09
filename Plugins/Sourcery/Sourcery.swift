//
//  Sourcery.swift
//
//
//  Created by Vladimir Burdukov on 24/04/2024.
//

import Foundation
import PackagePlugin

@main
struct Sourcery: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: any PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        guard let sourceModule = target.sourceModule else {
            return []
        }

        let files = sourceModule.sourceFiles(withSuffix: "swift").map(\.path)
        let templates = context.package.directory.appending(subpath: "Templates")

        return [
            try makeCommand(
                executable: try context.tool(named: "sourcery").path,
                root: context.package.directory,
                pluginWorkDirectory: context.pluginWorkDirectory,
                templates: [templates],
                files: files
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension Sourcery: XcodeBuildToolPlugin {
        func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
            let files = target.inputFiles.filter { $0.type == .source }.map(\.path)
            let templates = target.inputFiles.filter { $0.path.extension == "stencil" }.map(\.path)

            return [
                try makeCommand(
                    executable: try context.tool(named: "sourcery").path,
                    root: context.xcodeProject.directory,
                    pluginWorkDirectory: context.pluginWorkDirectory,
                    templates: templates,
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
    templates: [Path],
    files: [Path]
) throws -> PackagePlugin.Command {
    var arguments = [
        "--output", pluginWorkDirectory.appending("output").string
    ]

    if ProcessInfo.processInfo.environment["CI"] != "TRUE" {
        arguments.append(contentsOf: [
            "--cacheBasePath",
            pluginWorkDirectory.appending("sourcery.cache").string
        ])
    }

    for template in templates {
        arguments.append("--templates")
        arguments.append(template.string)
    }

    for file in files {
        arguments.append("--sources")
        arguments.append(file.string)
    }

    return .prebuildCommand(
        displayName: "Sourcery",
        executable: executable,
        arguments: arguments,
        outputFilesDirectory: pluginWorkDirectory.appending("output")
    )
}
