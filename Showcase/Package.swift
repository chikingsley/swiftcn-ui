// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftcnShowcase",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SwiftcnShowcase", targets: ["SwiftcnShowcase"])
    ],
    dependencies: [
        .package(name: "swiftcn-ui", path: "..")
    ],
    targets: [
        .executableTarget(
            name: "SwiftcnShowcase",
            dependencies: [
                .product(name: "Swiftcn", package: "swiftcn-ui")
            ],
            path: "Sources"
        )
    ]
)
