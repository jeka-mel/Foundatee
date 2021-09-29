// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "Foundatee"

let package = Package(
    name: packageName,
    products: [
        .library(
            name: packageName,
            targets: ["Foundatee"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: packageName,
            dependencies: []),
        .testTarget(
            name: "FoundateeTests",
            dependencies: ["Foundatee"]),
    ]
)