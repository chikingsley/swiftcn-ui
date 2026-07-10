// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swiftcn-ui",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Swiftcn", targets: ["Swiftcn"])
    ],
    targets: [
        .target(name: "Swiftcn", path: "Sources/Swiftcn")
    ]
)
