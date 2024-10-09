//
//  SwiftFormatRun.swift
//
//
//  Created by Vladimir Burdukov on 12/06/2024.
//

import PackagePlugin
import Foundation

@main
struct SwiftFormatRun: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        var files: [Path] = []
        for target in context.package.targets {
            guard let inputFiles = target.sourceModule?.sourceFiles(withSuffix: "swift") else {
                continue
            }

            files.append(contentsOf: inputFiles.map(\.path))
        }

        let swiftformat = try context.tool(named: "swiftformat")
        let arguments = makeArguments(pluginWorkDirectory: context.pluginWorkDirectory, files: files)
        try execute(swiftformat: swiftformat, arguments: arguments, displayName: context.package.displayName)
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftFormatRun: XcodeCommandPlugin {
        func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
            var files: [Path] = []
            for target in context.xcodeProject.targets {
                let inputFiles = target.inputFiles.filter { $0.type == .source }
                files.append(contentsOf: inputFiles.map(\.path))
            }

            let swiftformat = try context.tool(named: "swiftformat")
            let arguments = makeArguments(pluginWorkDirectory: context.pluginWorkDirectory, files: files)
            try execute(swiftformat: swiftformat, arguments: arguments, displayName: context.xcodeProject.displayName)
        }
    }
#endif

private func makeArguments(
    pluginWorkDirectory: Path,
    files: [Path]
) -> [String] {
    var arguments = [
        "--cache",
        pluginWorkDirectory.appending("swiftformat.cache").string
    ]

    arguments.append(contentsOf: files.map(\.string))

    return arguments
}

private func execute(swiftformat: PluginContext.Tool, arguments: [String], displayName: String) throws {
    let executable = URL(filePath: swiftformat.path.string)

    let process = try Process.run(executable, arguments: arguments)
    process.waitUntilExit()

    if process.terminationReason == .exit && process.terminationStatus == 0 {
        print("Formatted the source code in \(displayName).")
    } else {
        let problem = "\(process.terminationReason):\(process.terminationStatus)"
        Diagnostics.error("Formatting invocation failed: \(problem)")
    }
}