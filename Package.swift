// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "PubNubCSM",
  platforms: [.iOS(.v8), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2)],
  products: [
    .library(name: "PubNubCSM", targets: ["PubNubCSM"])
  ],
  dependencies: [
    .package(url: "https://github.com/pubnub/swift", from: "2.5.0"),
    .package(url: "https://github.com/ReSwift/ReSwift", from: "5.0.0")
  ],
  targets: [
    .target(
      name: "PubNubCSM",
      dependencies: ["PubNub", "ReSwift"]
    ),
    .testTarget(
      name: "PubNubCSMTests",
      dependencies: ["PubNubCSM"]
    )
  ],
  swiftLanguageVersions: [.v5]
)
