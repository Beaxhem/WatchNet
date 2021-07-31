// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DyetRestApi",
    products: [
        .library(
            name: "DyetRestApi",
            targets: ["DyetRestApi"]),
        .library(
            name: "RxDyetRestApi",
            targets: ["DyetRestApi", "RxDyetRestApi"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DyetRestApi",
            dependencies: []),
        .target(
            name: "RxDyetRestApi",
            dependencies: ["RxSwift", "DyetRestApi"]),
        .testTarget(
            name: "DyetRestApiTests",
            dependencies: ["DyetRestApi"]),
    ]
)
