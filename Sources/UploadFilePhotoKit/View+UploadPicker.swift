//
//  View+UploadPicker.swift
//  UploadFilePhotoKit
//
//  Created by Toshiro
//

import SwiftUI
import UniformTypeIdentifiers

public extension View {
    func uploadPicker(
        isPresented: Binding<Bool>,
        source: UploadSource,
        selectionLimit: Int = 1,
        allowedDocumentTypes: [UTType] = [.pdf, .image, .spreadsheet, .presentation, .text],
        sizeLimit: Int? = nil,
        onPick: @escaping (PickResult) -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                UploadPickerView(
                    source: source,
                    selectionLimit: selectionLimit,
                    allowedDocumentTypes: allowedDocumentTypes,
                    onPick: { files in
                        isPresented.wrappedValue = false
                        let hasError = sizeLimit.map { limit in files.contains { $0.fileSize > limit } } ?? false
                        onPick(PickResult(files: files, hasError: hasError))
                    },
                    onCancel: {
                        isPresented.wrappedValue = false
                        onCancel()
                    }
                )
            }
        }
    }
}
