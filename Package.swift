// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "simctl",
    products: [
        .library(name: "simctl", type: .dynamic, targets: ["simctl"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/core.git", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "simctl",
            dependencies: ["TuistCore"]
        ),
        .testTarget(
            name: "simctlTests",
            dependencies: ["TuistCoreTesting", "simctl"]
        ),
    ]
)
