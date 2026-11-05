// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SetsigSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SetsigSDK",
            targets: ["SetsigSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SetsigSDK",
            dependencies: [],
            path: "Sources/SetsigSDK"
        ),
    ]
)

