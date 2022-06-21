// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftShare",
    platforms: [.iOS(.v13)],
    products: [.library(name: "SwiftShare", targets: ["SwiftShare"])],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.9.6"))
    ],
    targets: [
        .target(name: "SwiftShare",
                dependencies: ["Alamofire", "RxSwift", "SwiftyBeaver"],
                path: "SwiftShare"),
        .testTarget(name: "SwiftShareTests", dependencies: ["SwiftShare"], path: "SwiftShareTests")
    ]
)
