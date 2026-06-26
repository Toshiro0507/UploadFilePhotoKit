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
        hasError: Binding<Bool> = .constant(false),
        onPick: @escaping ([PickedFile]) -> Void,
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
                        if let limit = sizeLimit, files.contains(where: { $0.fileSize > limit }) {
                            hasError.wrappedValue = true
                        } else {
                            hasError.wrappedValue = false
                            onPick(files)
                        }
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
