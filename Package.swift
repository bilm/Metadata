// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Metadata",
	platforms: [ .macOS(.v11), .iOS(.v14) ],
    products: [
        .library(name: "Metadata", targets: ["Metadata"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Metadata", dependencies: []),
        .testTarget(name: "MetadataTests", dependencies: ["Metadata"]),
    ]
)
