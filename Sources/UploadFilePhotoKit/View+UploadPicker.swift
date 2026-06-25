//
//  View+UploadPicker.swift
//  UploadFilePhotoKit
//
//  Created by Philip Lance Martinez
//

import SwiftUI
import UniformTypeIdentifiers

public extension View {
    func uploadPicker(
        isPresented: Binding<Bool>,
        source: UploadSource,
        selectionLimit: Int = 1,
        allowedDocumentTypes: [UTType] = [.pdf, .image, .spreadsheet, .presentation, .text],
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
                        onPick(files)
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
