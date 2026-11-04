// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Qualifio",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "QualifioKit",
            targets: ["QualifioKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "QualifioKit",
            url: "https://mobile.cdn.qualifio.app/libs/ios/1.0.0-beta.1/spm-qualifio.zip",
            checksum: "0762776194832b06ca48b784b1f4724ba93af091c5860b9145c6fe4f7b2be3e6"
        ),
    ]
)
