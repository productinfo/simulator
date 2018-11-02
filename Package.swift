// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Simulator",
    products: [
        .library(name: "Simulator", type: .dynamic, targets: ["Simulator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/ReactiveTask.git", .upToNextMinor(from: "0.15.0")),
    ],
    targets: [
        .target(
            name: "Simulator",
            dependencies: ["ReactiveTask"]
        ),
        .testTarget(
            name: "SimulatorTests",
            dependencies: ["Simulator"]
        ),
    ]
)
