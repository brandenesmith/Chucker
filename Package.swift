// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chucker",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Chucker",
            targets: ["Chucker"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", .exact("5.4.1")),
        .package(name: "Apollo", url: "https://github.com/apollographql/apollo-ios.git", .exact("0.49.1"))
    ],
    targets: [
        .target(
            name: "Chucker",
            dependencies: ["Alamofire", "Apollo"]
        ),
        .testTarget(
            name: "ChuckerTests",
            dependencies: ["Chucker"])
    ]
)
