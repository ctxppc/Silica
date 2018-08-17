// swift-tools-version:4.2
// Silica © 2018 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Silica",
	products: [
		.executable(name: "Silica", targets: ["Silica"])
	],
	dependencies: [
		.package(url: "https://github.com/ctxppc/DepthKit.git", from: "0.6.0"),
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.2.1"),
		.package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.21.1")
	],
	targets: [
		.target(name: "Silica", dependencies: ["DepthKit", "SwiftPM", "SourceKittenFramework"]),
		.testTarget(name: "SilicaTests", dependencies: ["Silica"])
	]
)
