//
//  StorageManager.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let container = Storage.storage()
    
    private init() {}
    
    public func uploadUserProfilePicture(
        email: String,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        guard let jpgData = UIImage.resizeImage(
            image: image!,
            targetSize: CGSize(width: 150, height: 150)
        )?.jpegData(compressionQuality: 1) else {
            return
        }
        container
            .reference(withPath: "profile_pictures/\(path)/photo.png")
            .putData(jpgData, metadata: nil) { result in
                switch result {
                case .success(_): completion(true)
                case .failure(_): completion(false)
                }
            }
    }
    
    public func downloadUrlForProfilePicture(
        path: String,
        completion: @escaping (Result<URL?, Error>) -> Void
    ) {
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(.success(url))
            }
    }
    
    public func uploadBlogHeaderImage(
        email: String,
        image: UIImage,
        postId: String,
        completion: @escaping (Bool) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        guard let jpgData = UIImage.resizeImage(
            image: image,
            targetSize: CGSize(width: 450, height: 450)
        )?.jpegData(compressionQuality: 1) else {
            return
        }
        container
            .reference(withPath: "post_headers/\(path)/\(postId).png")
            .putData(jpgData, metadata: nil) { result in
                switch result {
                case .success(_): completion(true)
                case .failure(_): completion(false)
                }
            }
    }
    
    public func downloadUrlForPostHeader(
        email: String,
        postId: String,
        completion: @escaping (Result<URL?, Error>) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        
        container
            .reference(withPath: "post_headers/\(path)/\(postId).png")
            .downloadURL { url, _ in
                completion(.success(url))
            }
    }
}
