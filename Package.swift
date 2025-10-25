// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StormSDKAdapty",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "StormSDKAdapty",
            targets: ["StormSDKAdapty"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gixdev/AdaptySDK-SK1", branch: "master")
    ],
    targets: [
        .target(
            name: "StormSDKAdapty",
            dependencies: [.product(name: "Adapty", package: "AdaptySDK-SK1"),
                           .product(name: "AdaptyUI", package: "AdaptySDK-SK1")])
    ]
)
