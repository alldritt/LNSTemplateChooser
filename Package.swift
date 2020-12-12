// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LNSTemplateChooser",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library( name: "LNSTemplateChooser", targets: ["LNSTemplateChooser"])
    ],
    dependencies: [],
    targets: [
        .target(name: "LNSTemplateChooser", dependencies: [], path: "LNSTemplateChooser")
    ],
    swiftLanguageVersions: [.v5]
)