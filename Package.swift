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
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27"),
        .visionOS("27"),
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
            name: "IEEE 754 Shims",
            dependencies: []
        ),
        .target(
            name: "IEEE 754",
            dependencies: [
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Decimal Primitives", package: "swift-decimal-primitives"),
                .product(name: "Dependency Primitives", package: "swift-dependency-primitives"),
                .target(
                    name: "IEEE 754 Shims",
                    condition: .when(platforms: [.macOS, .linux, .iOS, .tvOS, .watchOS])
                ),
            ],
            // Gate the C-shim source paths on a define that mirrors the IEEE_754_Shims
            // dependency condition exactly. `canImport(IEEE_754_Shims)` is unreliable
            // here: the IEEE_754_Shims target is built for the whole package graph, so
            // canImport reports true on platforms (e.g. Windows) where IEEE_754_Shims
            // is deliberately NOT a dependency of this target — the guarded
            // `import IEEE_754_Shims` then fails with "no such module 'IEEE_754_Shims'".
            swiftSettings: [
                .define(
                    "IEEE_754_SHIMS",
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
                    name: "IEEE 754 Shims",
                    condition: .when(platforms: [.macOS, .linux, .iOS, .tvOS, .watchOS])
                ),
            ],
            // Mirror the "IEEE 754" target's shim gating so the C-shim
            // integration tests compile out on Windows (see the note above).
            swiftSettings: [
                .define(
                    "IEEE_754_SHIMS",
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
