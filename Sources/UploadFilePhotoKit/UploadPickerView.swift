//
//  UploadPickerView.swift
//  UploadFilePhotoKit
//
//  Created by Toshiro
//

import SwiftUI
import UniformTypeIdentifiers

public struct UploadPickerView: View {
    let source: UploadSource
    let selectionLimit: Int
    let allowedDocumentTypes: [UTType]
    let onPick: ([PickedFile]) -> Void
    let onCancel: () -> Void

    @State private var activeSheet: ActiveSheet?

    public init(
        source: UploadSource,
        selectionLimit: Int = 1,
        allowedDocumentTypes: [UTType] = [.pdf, .image, .spreadsheet, .presentation, .text],
        onPick: @escaping ([PickedFile]) -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        self.source = source
        self.selectionLimit = selectionLimit
        self.allowedDocumentTypes = allowedDocumentTypes
        self.onPick = onPick
        self.onCancel = onCancel
    }

    public var body: some View {
        PickerPresentationHost(
            activeSheet: $activeSheet,
            selectionLimit: selectionLimit,
            allowedDocumentTypes: allowedDocumentTypes,
            onPick: onPick,
            onCancel: onCancel
        )
        .frame(width: 0, height: 0)
        .onAppear { launch() }
        .confirmationDialog("Choose Upload Source", isPresented: confirmationBinding, titleVisibility: .visible) {
            Button("Gallery") { activeSheet = .gallery }
            Button("File Manager") { activeSheet = .fileManager }
            Button("Cancel", role: .cancel) { onCancel() }
        }
    }

    private var confirmationBinding: Binding<Bool> {
        Binding(
            get: { source == .both && activeSheet == nil },
            set: { _ in }
        )
    }

    private func launch() {
        switch source {
        case .gallery:     activeSheet = .gallery
        case .fileManager: activeSheet = .fileManager
        case .both:        break
        }
    }
}
