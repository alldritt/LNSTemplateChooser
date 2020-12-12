// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LNSTemplateChooser",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LNSTemplateChooser",
            targets: ["LNSTemplateChooser"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LNSTemplateChooser",
            dependencies: [],
            resources: [.process("LNSTemplateCell.xib")]),
    ],
    swiftLanguageVersions: [.v5]
)
