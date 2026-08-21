// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-ieee-754",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
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
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
