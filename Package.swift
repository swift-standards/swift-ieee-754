// swift-tools-version: 6.3.3

import PackageDescription

// IEEE 754: Standard for Floating-Point Arithmetic
//
// Implements IEEE 754-2019 binary floating-point standard
// - IEEE 754-2019: Current standard (published August 2019)
// - IEEE 754-2008: Previous revision
// - IEEE 754-1985: Original standard
//
// This package provides canonical binary serialization for Float and Double
// types following IEEE 754 binary interchange formats.
//
// Pure Swift implementation with no Foundation dependencies,
// suitable for Swift Embedded and constrained environments.

let package = Package(
    name: "swift-ieee-754",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "IEEE 754",
            targets: ["IEEE 754"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-binary-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-decimal-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-dependency-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "CIEEE754",
            dependencies: []
        ),
        .target(
            name: "IEEE 754",
            dependencies: [
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Decimal Primitives", package: "swift-decimal-primitives"),
                .product(name: "Dependency Primitives", package: "swift-dependency-primitives"),
                .target(
                    name: "CIEEE754",
                    condition: .when(platforms: [.macOS, .linux, .iOS, .tvOS, .watchOS])
                ),
            ],
            // Gate the C-shim source paths on a define that mirrors the CIEEE754
            // dependency condition exactly. `canImport(CIEEE754)` is unreliable
            // here: the CIEEE754 target is built for the whole package graph, so
            // canImport reports true on platforms (e.g. Windows) where CIEEE754
            // is deliberately NOT a dependency of this target — the guarded
            // `import CIEEE754` then fails with "no such module 'CIEEE754'".
            swiftSettings: [
                .define(
                    "CIEEE754_SHIM",
                    .when(platforms: [.macOS, .linux, .iOS, .tvOS, .watchOS])
                )
            ]
        ),
        .testTarget(
            name: "IEEE 754 Tests",
            dependencies: [
                "IEEE 754",
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
                .target(
                    name: "CIEEE754",
                    condition: .when(platforms: [.macOS, .linux, .iOS, .tvOS, .watchOS])
                ),
            ],
            // Mirror the "IEEE 754" target's shim gating so the C-shim
            // integration tests compile out on Windows (see the note above).
            swiftSettings: [
                .define(
                    "CIEEE754_SHIM",
                    .when(platforms: [.macOS, .linux, .iOS, .tvOS, .watchOS])
                )
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
