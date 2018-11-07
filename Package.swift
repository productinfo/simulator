// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Simulator",
    products: [
        .library(name: "Simulator", type: .dynamic, targets: ["Simulator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell.git", .upToNextMinor(from: "4.1.2")),
    ],
    targets: [
        .target(
            name: "Simulator",
            dependencies: ["SwiftShell"]
        ),
        .testTarget(
            name: "SimulatorTests",
            dependencies: ["Simulator"]
        ),
    ]
)
