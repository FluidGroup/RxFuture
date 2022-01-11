// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "RxFuture",
  platforms: [.iOS(.v12)],
  products: [
    .library(name: "RxFuture", targets: ["RxFuture"]),
  ],
  dependencies: [
     .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.2.0"),
  ],
  targets: [
    .target(
      name: "RxFuture",      
      dependencies: ["RxSwift"],
      path: "RxFuture",
      exclude: ["Info.plist"]
    ),
  ]
)
