// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JiraSwift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "JiraSwift",
            targets: ["JiraSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/gestrich/SwiftRestTools.git", .revision("d922571863d5b0d72cb33bf99de6dc5e3665e064")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "JiraSwift",
            dependencies: ["SwiftRestTools"]),
        .testTarget(
            name: "JiraSwiftTests",
            dependencies: ["JiraSwift"]),
    ]
)
