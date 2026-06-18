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
            url: "https://cdn-mobile.qualifio.com/libs/ios/{{VERSION}}/spm-qualifio.zip",
            checksum: "{{QUALIFIO_CHECKSUM}}"
        ),
    ]
)
