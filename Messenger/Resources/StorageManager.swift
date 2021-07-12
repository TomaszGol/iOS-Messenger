//
//  StorageManager.swift
//  Messenger
//
//  Created by TomaszGolkowski on 12/07/2021.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedTopUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to download url")
                    completion(.failure(StorageErrors.failedTogetrDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
        })
    }
    
    public enum StorageErrors: Error {
        case failedTopUpload
        case failedTogetrDownloadUrl
    }
}
