import PackageDescription

let package = Package(
    name: "Peripheral",
    targets: [
        Target(name: "Peripheral")
    ],
    dependencies: [
        .Package(url: "https://github.com/PureSwift/GATT", majorVersion: 1)
    ],
    exclude: ["Xcode"]
)
