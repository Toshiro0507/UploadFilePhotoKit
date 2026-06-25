//
//  PickerPresentationHost.swift
//  UploadFilePhotoKit
//
//  Created by Toshiro
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum ActiveSheet: Identifiable {
    case gallery, fileManager
    var id: Self { self }
}

struct PickerPresentationHost: UIViewControllerRepresentable {
    @Binding var activeSheet: ActiveSheet?
    let selectionLimit: Int
    let allowedDocumentTypes: [UTType]
    let onPick: ([PickedFile]) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        guard let activeSheet else { return }
        guard host.presentedViewController == nil else { return }
        let picker = context.coordinator.makePicker(for: activeSheet)
        host.present(picker, animated: true)
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate, UIDocumentPickerDelegate {
        var parent: PickerPresentationHost

        init(parent: PickerPresentationHost) { self.parent = parent }

        func makePicker(for sheet: ActiveSheet) -> UIViewController {
            switch sheet {
            case .gallery:
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = parent.selectionLimit
                config.filter = .any(of: [.images, .videos])
                let vc = PHPickerViewController(configuration: config)
                vc.delegate = self
                return vc
            case .fileManager:
                let vc = UIDocumentPickerViewController(forOpeningContentTypes: parent.allowedDocumentTypes, asCopy: true)
                vc.allowsMultipleSelection = parent.selectionLimit != 1
                vc.delegate = self
                return vc
            }
        }

        // MARK: PHPickerViewControllerDelegate

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.activeSheet = nil
                    self?.parent.onCancel()
                }
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
                        let name = provider.suggestedName ?? "image"
                        files.append(PickedFile(data: data, fileName: "\(name).png", fileExtension: "png", mimeType: "image/png"))
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.jpeg.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let name = provider.suggestedName ?? "image"
                        files.append(PickedFile(data: data, fileName: "\(name).jpg", fileExtension: "jpg", mimeType: "image/jpeg"))
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let name = provider.suggestedName ?? "image"
                        files.append(PickedFile(data: data, fileName: "\(name).jpg", fileExtension: "jpg", mimeType: "image/jpeg"))
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    group.enter()
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.movie.identifier) { data, _ in
                        defer { group.leave() }
                        guard let data else { return }
                        let name = provider.suggestedName ?? "video"
                        files.append(PickedFile(data: data, fileName: "\(name).mov", fileExtension: "mov", mimeType: "video/quicktime"))
                    }
                }
            }

            group.notify(queue: .main) { [weak self] in
                self?.parent.activeSheet = nil
                self?.parent.onPick(files)
            }
        }

        // MARK: UIDocumentPickerDelegate

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let files: [PickedFile] = urls.compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                let ext = url.pathExtension.lowercased()
                let mime = UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
                return PickedFile(url: url, data: data, fileName: url.lastPathComponent, fileExtension: ext, mimeType: mime)
            }
            DispatchQueue.main.async { [weak self] in
                self?.parent.activeSheet = nil
                self?.parent.onPick(files)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.activeSheet = nil
                self?.parent.onCancel()
            }
        }
    }
}
