// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Simulator",
    products: [
        .library(name: "Simulator", type: .dynamic, targets: ["Simulator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/Shell.git", .upToNextMinor(from: "1.0.2")),
        .package(url: "https://github.com/antitypical/Result.git", .upToNextMinor(from: "4.0.1")),
    ],
    targets: [
        .target(
            name: "Simulator",
            dependencies: ["Shell", "Result"]
        ),
        .testTarget(
            name: "SimulatorTests",
            dependencies: ["Simulator", "ShellTesting"]
        ),
    ]
)
