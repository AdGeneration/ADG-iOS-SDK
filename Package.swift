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
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "ADG",
            url: "https://github.com/AdGeneration/ADG-iOS-SDK/releases/download/2.28.1/ADG.xcframework.zip",
            checksum: "e4388a639cdb0e3feb217dfebe36311db8a665c676e3c1313b9a686719520ff7"),
    ]
)
