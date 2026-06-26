# UploadFilePhotoKit

A lightweight SwiftUI package for iOS that provides a unified file and photo picker — gallery, file manager, or both — with a single view modifier.

## Requirements

- iOS 16+
- Swift 5.9+
- Xcode 15+

## Installation

In Xcode: **File → Add Package Dependencies**, paste the repository URL, and select a version.

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/philiplancemartinez/UploadFilePhotoKit.git", from: "1.0.0")
]
```

Then add `"UploadFilePhotoKit"` to your target's dependencies.

## Permissions

Add the following key to your app's `Info.plist` when using the gallery source:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload images and videos.</string>
```

## Usage

### View modifier (recommended)

```swift
import SwiftUI
import UploadFilePhotoKit

struct ContentView: View {
    @State private var showPicker = false
    @State private var pickedFiles: [PickedFile] = []

    var body: some View {
        Button("Upload") { showPicker = true }
            .uploadPicker(
                isPresented: $showPicker,
                source: .both,           // .gallery | .fileManager | .both
                selectionLimit: 3,
                onPick: { files in
                    pickedFiles = files
                }
            )
    }
}
```

### Direct view

```swift
UploadPickerView(
    source: .gallery,
    selectionLimit: 1,
    allowedDocumentTypes: [.pdf, .image],
    onPick: { files in print(files) },
    onCancel: { }
)
```

## API Reference

### `UploadSource`

| Case | Description |
|---|---|
| `.gallery` | Opens the photo/video picker directly |
| `.fileManager` | Opens the document picker directly |
| `.both` | Shows a confirmation dialog to choose |

### `PickedFile`

| Property | Type | Description |
|---|---|---|
| `id` | `UUID` | Unique identifier |
| `url` | `URL?` | Original file URL (documents only) |
| `data` | `Data` | Raw file bytes |
| `fileName` | `String` | File name with extension |
| `fileExtension` | `String` | Lowercased extension (e.g. `"pdf"`) |
| `mimeType` | `String` | MIME type (e.g. `"image/png"`) |
| `fileSize` | `Int` | File size in bytes |
| `base64String` | `String` | Base64-encoded file content |

### `.uploadPicker(...)` modifier

```swift
func uploadPicker(
    isPresented: Binding<Bool>,
    source: UploadSource,
    selectionLimit: Int = 1,
    allowedDocumentTypes: [UTType] = [.pdf, .image, .spreadsheet, .presentation, .text],
    sizeLimit: Int? = nil,
    onPick: @escaping (PickResult) -> Void,
    onCancel: @escaping () -> Void = {}
) -> some View
```

`sizeLimit` is in bytes. `onPick` always fires with a `PickResult` containing `files` and `hasError`. `hasError` is `true` if any file exceeds the limit, `false` otherwise. If `sizeLimit` is `nil`, `hasError` is always `false`.

```swift
.uploadPicker(
    isPresented: $showPicker,
    source: .both,
    sizeLimit: 5 * 1024 * 1024,
    onPick: { result in
        result.files    // [PickedFile]
        result.hasError // Bool
    }
)
```

## License

Copyright © 2026 Toshiro. Use permitted; modification and redistribution prohibited. See [LICENSE](LICENSE) for full terms.
