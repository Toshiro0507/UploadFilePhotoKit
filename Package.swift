// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UploadFilePhotoKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "UploadFilePhotoKit", targets: ["UploadFilePhotoKit"])
    ],
    targets: [
        .target(
            name: "UploadFilePhotoKit",
            path: "Sources/UploadFilePhotoKit"
        )
    ]
)
