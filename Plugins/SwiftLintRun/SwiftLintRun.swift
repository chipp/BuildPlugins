//
//  SwiftLintRun.swift
//
//
//  Created by Vladimir Burdukov on 12/06/2024.
//

import PackagePlugin
import Foundation

@main
struct SwiftLintRun: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        var files: [URL] = []
        for target in context.package.targets {
            guard let inputFiles = target.sourceModule?.sourceFiles(withSuffix: "swift") else {
                continue
            }

            files.append(contentsOf: inputFiles.map(\.url))
        }

        let swiftlint = try context.tool(named: "swiftlint")
        let arguments = makeArguments(
            pluginWorkDirectory: context.pluginWorkDirectoryURL,
            root: context.package.directoryURL,
            files: files
        )
        try execute(swiftlint: swiftlint, arguments: arguments, displayName: context.package.displayName)
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftLintRun: XcodeCommandPlugin {
        func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
            var files: [URL] = []
            for target in context.xcodeProject.targets {
                let inputFiles = target.inputFiles.filter { $0.type == .source }
                files.append(contentsOf: inputFiles.map(\.url))
            }

            let swiftformat = try context.tool(named: "swiftlint")
            let arguments = makeArguments(
                pluginWorkDirectory: context.pluginWorkDirectoryURL,
                root: context.xcodeProject.directoryURL,
                files: files
            )
            try execute(swiftlint: swiftformat, arguments: arguments, displayName: context.xcodeProject.displayName)
        }
    }
#endif

private func makeArguments(
    pluginWorkDirectory: URL,
    root: URL,
    files: [URL]
) -> [String] {
    var arguments = [
        "lint",
        "--fix",
        "--cache-path",
        pluginWorkDirectory.appending(components: "swiftformat.cache").path(),
        "--config",
        root.appending(components: ".swiftlint.yml").path()
    ]

    arguments.append(contentsOf: files.map { $0.path() })

    return arguments
}

private func execute(swiftlint: PluginContext.Tool, arguments: [String], displayName: String) throws {
    let process = try Process.run(swiftlint.url, arguments: arguments)
    process.waitUntilExit()

    if process.terminationReason == .exit && process.terminationStatus == 0 {
        print("Formatted the source code in \(displayName).")
    } else {
        let problem = "\(process.terminationReason):\(process.terminationStatus)"
        Diagnostics.error("Formatting invocation failed: \(problem)")
    }
}
