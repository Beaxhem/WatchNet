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
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(
            name: "WatchNet",
            dependencies: []),
        .target(
            name: "RxWatchNet",
            dependencies: ["RxSwift", "WatchNet",.productItem(name: "RxCocoa", package: "RxSwift", condition: .when(platforms: [.iOS])) ]),
        .testTarget(
            name: "WatchNetTests",
            dependencies: ["WatchNet"]),
        .testTarget(
            name: "RxWatchNetTests",
            dependencies: ["RxWatchNet", "WatchNet", "RxSwift"])
    ]
)


