//
//  PickedFile.swift
//  UploadFilePhotoKit
//
//  Created by Toshiro
//

import Foundation
import UniformTypeIdentifiers

@frozen public struct PickedFile: Identifiable {
    public let id: UUID
    public let url: URL?
    public let data: Data
    public let fileName: String
    public let fileExtension: String
    public let mimeType: String
    public let fileSize: String
    public let base64String: String

    public init(url: URL? = nil, data: Data, fileName: String, fileExtension: String, mimeType: String) {
        self.id = UUID()
        self.url = url
        self.data = data
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.mimeType = mimeType
        self.fileSize = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        self.base64String = data.base64EncodedString()
    }
}
