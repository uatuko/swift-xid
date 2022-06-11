// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swift-xid",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13)
	],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "xid",
			targets: ["xid"]),
	],
	dependencies: [
		.package(
			url: "https://github.com/apple/swift-atomics.git",
			.upToNextMajor(from: "1.0.2")
		)
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "xid",
			dependencies: [
				.product(name: "Atomics", package: "swift-atomics")
			],
			path: "src"),
		.testTarget(
			name: "xidTests",
			dependencies: ["xid"],
			path: "test"),
	]
)