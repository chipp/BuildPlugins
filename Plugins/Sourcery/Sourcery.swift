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

        let files = sourceModule.sourceFiles(withSuffix: "swift").map(\.url)
        let templates = context.package.directoryURL.appending(components: "Templates")

        return [
            try makeCommand(
                executable: try context.tool(named: "sourcery").url,
                root: context.package.directoryURL,
                pluginWorkDirectory: context.pluginWorkDirectoryURL,
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
            let files = target.inputFiles.filter { $0.type == .source }.map(\.url)
            let templates = target.inputFiles.filter { $0.url.pathExtension == "stencil" }.map(\.url)

            return [
                try makeCommand(
                    executable: try context.tool(named: "sourcery").url,
                    root: context.xcodeProject.directoryURL,
                    pluginWorkDirectory: context.pluginWorkDirectoryURL,
                    templates: templates,
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
    templates: [URL],
    files: [URL]
) throws -> PackagePlugin.Command {
    var arguments = [
        "--output", pluginWorkDirectory.appending(components: "output").absoluteString
    ]

    if ProcessInfo.processInfo.environment["CI"] != "TRUE" {
        arguments.append(contentsOf: [
            "--cacheBasePath",
            pluginWorkDirectory.appending(components: "sourcery.cache").absoluteString
        ])
    }

    for template in templates {
        arguments.append("--templates")
        arguments.append(template.absoluteString)
    }

    for file in files {
        arguments.append("--sources")
        arguments.append(file.absoluteString)
    }

    return .prebuildCommand(
        displayName: "Sourcery",
        executable: executable,
        arguments: arguments,
        outputFilesDirectory: pluginWorkDirectory.appending(components: "output")
    )
}
