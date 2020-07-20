// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Metadata",
	platforms: [ .macOS(.v10_12), .iOS(.v13) ],
    products: [
        .library(name: "Metadata", targets: ["Metadata"]),
    ],
    dependencies: [
		.package(url: "git@github.com:bilm/Logger.git", .branch("swift-5_3")),
    ],
    targets: [
        .target(name: "Metadata", dependencies: ["Logger"]),
        .testTarget(name: "MetadataTests", dependencies: ["Metadata"]),
    ]
)
