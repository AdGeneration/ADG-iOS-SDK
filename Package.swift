// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ADG-iOS-SDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ADG",
            targets: ["ADG"]),
        .library(
            name: "ADGAdMobMediation",
            targets: ["ADGAdMobMediationTarget"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            from: "11.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "ADG",
            url: "https://github.com/AdGeneration/ADG-iOS-SDK/releases/download/2.27.1/ADG.xcframework.zip",
            checksum: "c41df930206312a04c37c9900fd3f495e80cac9fdefb86ca49a4b5d08397e9c2"),
        .target(
            name: "ADGAdMobMediationTarget",
            dependencies: [
                .target(name: "ADGAdMobMediation"),
                .target(name: "ADG"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "ADGAdMobMediationTarget"),
        .binaryTarget(
            name: "ADGAdMobMediation",
            url: "https://github.com/AdGeneration/ADG-AdMobMediation-iOS-SDK/releases/download/2.27.100/ADGAdMobMediation.xcframework.zip",
            checksum: "bfade17cf5c6330302b5da0e98feb0ae3a8ddeb9a339130aaf24eee6dc8a2f58"),
    ]
)
