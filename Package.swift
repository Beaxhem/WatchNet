// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WatchNet",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "WatchNet",
            targets: ["WatchNet"]),
        .library(
            name: "RxWatchNet",
            targets: ["RxWatchNet"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.2.0")),
    ],
    targets: [
        .target(
            name: "WatchNet",
            dependencies: []),
        .target(
            name: "RxWatchNet",
            dependencies: ["RxSwift", "WatchNet"]),
        .testTarget(
            name: "WatchNetTests",
            dependencies: ["WatchNet"]),
        .testTarget(
            name: "RxWatchNetTests",
            dependencies: ["RxWatchNet", "WatchNet", "RxSwift"])
    ]
)
