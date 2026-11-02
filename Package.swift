// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ColorVault",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ColorVault",
            targets: ["ColorVault"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ColorVault",
            path: "Sources/ColorVault",
            linkerSettings: [
                .unsafeFlags([
                    "-L", "./target/release",
                    "-lcolorvault_core",
                    "-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"
                ])
            ]
        )
    ]
)
