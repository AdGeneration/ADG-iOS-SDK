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
            url: "https://github.com/AdGeneration/ADG-iOS-SDK/releases/download/2.28.0/ADG.xcframework.zip",
            checksum: "69bb1cff0ed9c18049c66df3aa9ee857fc538984478e85315ae528851d1a63ee"),
    ]
)
