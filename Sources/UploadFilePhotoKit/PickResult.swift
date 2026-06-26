//
//  PickResult.swift
//  UploadFilePhotoKit
//
//  Created by Toshiro
//

import Foundation

@frozen public struct PickResult {
    public let files: [PickedFile]
    public let hasError: Bool
}
