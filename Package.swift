// swift-tools-version:4.2
// Silica © 2018 Constantino Tsarouhas

import PackageDescription

let package = Package(
	name: "Silica",
	products: [
		.executable(name: "Silica", targets: ["Silica"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.2.1")
	],
	targets: [
		.target(name: "Silica", dependencies: ["SwiftPM"]),
		.testTarget(name: "SilicaTests", dependencies: ["Silica"])
	]
)
