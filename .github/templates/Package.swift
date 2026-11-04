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
            url: "https://mobile.cdn.qualifio.app/libs/ios/{{VERSION}}/spm-qualifio.zip",
            checksum: "{{QUALIFIO_CHECKSUM}}"
        ),
    ]
)
