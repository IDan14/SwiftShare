// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftShare",
    products: [.library(name: "SwiftShare", targets: ["SwiftShare"])],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.3")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.3")
    ],
    targets: [
        .target(name: "SwiftShare", path: "SwiftShare"),
        .testTarget(name: "SwiftShareTests", dependencies: ["SwiftShare"])
    ]
)
