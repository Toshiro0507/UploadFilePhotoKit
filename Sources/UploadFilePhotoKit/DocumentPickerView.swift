//
//  DocumentPickerView.swift
//  UploadFilePhotoKit
//
//  Created by Philip Lance Martinez
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let allowsMultiple: Bool
    let onPick: ([PickedFile]) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.allowsMultipleSelection = allowsMultiple
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([PickedFile]) -> Void
        let onCancel: () -> Void

        init(onPick: @escaping ([PickedFile]) -> Void, onCancel: @escaping () -> Void) {
            self.onPick = onPick
            self.onCancel = onCancel
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let files: [PickedFile] = urls.compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                let ext = url.pathExtension.lowercased()
                let mime = UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
                return PickedFile(url: url, data: data, fileName: url.lastPathComponent, fileExtension: ext, mimeType: mime)
            }
            onPick(files)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel()
        }
    }
}
