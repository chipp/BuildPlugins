// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "update",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-package-manager", branch: "swift-5.10.1-RELEASE")
    ],
    targets: [
        .executableTarget(name: "update", dependencies: [
            .product(name: "SwiftPMDataModel", package: "swift-package-manager")
        ]),
    ]
)
