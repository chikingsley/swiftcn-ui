// swift-tools-version: 6.0
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Showcase",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Swiftcn Showcase",
            targets: ["AppModule"],
            bundleIdentifier: "com.swiftcn.showcase",
            displayVersion: "2.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .box),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(name: "swiftcn-ui", path: "..")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "Swiftcn", package: "swiftcn-ui")
            ],
            path: "Sources"
        )
    ]
)
