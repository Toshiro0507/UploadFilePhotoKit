//
//  GalleryPickerView.swift
//  UploadFilePhotoKit
//
//  Created by Philip Lance Martinez
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct GalleryPickerView: UIViewControllerRepresentable {
    let selectionLimit: Int
    let onPick: ([PickedFile]) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = selectionLimit
        config.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: ([PickedFile]) -> Void
        let onCancel: () -> Void

        init(onPick: @escaping ([PickedFile]) -> Void, onCancel: @escaping () -> Void) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else {
                onCancel()
                return
            }

            var files: [PickedFile] = []
            let group = DispatchGroup()

            for result in results {
                let provider = result.itemProvider

                if provider.hasItemConformingToTypeIdentifier(UTType.png.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.png.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let baseName = provider.suggestedName ?? "image"
                        files.append(PickedFile(data: data, fileName: "\(baseName).png", fileExtension: "png", mimeType: "image/png"))
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.jpeg.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let baseName = provider.suggestedName ?? "image"
                        files.append(PickedFile(data: data, fileName: "\(baseName).jpg", fileExtension: "jpg", mimeType: "image/jpeg"))
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let baseName = provider.suggestedName ?? "image"
                        files.append(PickedFile(data: data, fileName: "\(baseName).jpg", fileExtension: "jpg", mimeType: "image/jpeg"))
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.movie.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let baseName = provider.suggestedName ?? "video"
                        files.append(PickedFile(data: data, fileName: "\(baseName).mov", fileExtension: "mov", mimeType: "video/quicktime"))
                    }
                }
            }

            group.notify(queue: .main) { [weak self] in
                self?.onPick(files)
            }
        }
    }
}
