// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ISHLogDNA",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "ISHLogDNA", targets: ["ISHLogDNA"]),
    ],
    targets: [
        .target(name: "ISHLogDNA",
                path: "Sources/ISHLogDNA",
                publicHeadersPath: ""),
        .testTarget(name: "ISHLogDNATests", dependencies: ["ISHLogDNA"])
    ]
)
