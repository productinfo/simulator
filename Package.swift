// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "simulator",
    products: [
        .library(name: "simulator", type: .dynamic, targets: ["simulator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/ReactiveTask.git", .upToNextMinor(from: "0.15.0")),
    ],
    targets: [
        .target(
            name: "simulator",
            dependencies: ["ReactiveTask"]
        ),
        .testTarget(
            name: "simulatorTests",
            dependencies: ["simulator"]
        ),
    ]
)
