// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swiftcn-ui",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Swiftcn", targets: ["Swiftcn"])
    ],
    dependencies: [
        // Engine for the `response` component (SCResponse), mirroring the
        // upstream registry item's `streamdown` npm dependency. See
        // docs/architecture.md, "Package dependencies for engine wrappers".
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.1")
    ],
    targets: [
        .target(
            name: "Swiftcn",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            path: "Sources/Swiftcn",
            swiftSettings: [
                // SE-0444: extension members resolve only in files that import
                // their module. Without this, MarkdownUI's Color(light:dark:)
                // would collide module-wide with Theme's own initializer.
                .enableUpcomingFeature("MemberImportVisibility"),
                // Keep Swift 6 data-race diagnostics enabled for every
                // package consumer, even while the manifest remains Swift 5.9.
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        )
    ]
)
