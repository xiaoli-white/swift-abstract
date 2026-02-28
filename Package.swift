// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SwiftAbstract",
    products: [
        .library(
            name: "SwiftAbstract",
            targets: ["SwiftAbstract"]
        ),
        .executable(
            name: "SwiftAbstractClient",
            targets: ["SwiftAbstractClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest")
    ],
    targets: [
        .macro(
            name: "SwiftAbstractMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(name: "SwiftAbstract", dependencies: ["SwiftAbstractMacros"]),
        .executableTarget(name: "SwiftAbstractClient", dependencies: ["SwiftAbstract"]),
    ]
)
