// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Typenum",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
        .driverKit(.v19),
    ],
    products: [
        .library(
            name: "Typenum",
            targets: ["Typenum"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "603.0.0")
    ],
    targets: [
        .target(
            name: "Typenum",
            dependencies: ["TypenumMacros"],
            plugins: ["TypenumPlugin"]
        ),
        .macro(
            name: "TypenumMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .executableTarget(
            name: "TypenumCodegen"
        ),
        .executableTarget(
            name: "TypenumFailureHarness",
            dependencies: ["Typenum"]
        ),
        .plugin(
            name: "TypenumPlugin",
            capability: .buildTool(),
            dependencies: ["TypenumCodegen"]
        ),
        .testTarget(
            name: "TypenumTests",
            dependencies: ["Typenum", "TypenumFailureHarness"]
        ),
    ]
)
