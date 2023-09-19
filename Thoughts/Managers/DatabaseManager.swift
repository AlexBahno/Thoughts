//
//  DatabaseManager.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
    private init() {}
    
    public func insert(
        blogPost: BlogPost,
        email: String,
        completion: @escaping (Bool) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data : [String : Any] = [
            "id": blogPost.identifier,
            "title": blogPost.title,
            "body": blogPost.text,
            "created": blogPost.timestamp,
            "headerImageUrl": blogPost.headerImageUrl?.absoluteString ?? "",
            "emailOfOwner": blogPost.emailOfOwner
        ]
        
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(blogPost.identifier)
            .setData(data, completion: { error in
                completion(error == nil)
            })
    }
    
    public func getAllPosts(
        completion: @escaping (Result<[BlogPost], Error>) -> Void
    ) {
        database
            .collection("users")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }
                let emails: [String] = documents.compactMap({ return $0["email"] as? String })
                
                guard !emails.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                let group = DispatchGroup()
                
                var posts: [BlogPost] = []
                
                for email in emails {
                    group.enter()
                    self?.getPosts(for: email) { result in
                        defer {
                            group.leave()
                        }
                        switch result {
                        case .success(let userPosts):
                            posts.append(contentsOf: userPosts)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                group.notify(queue: .global()) {
                    print("Feed posts: \(posts.count)")
                    completion(.success(posts))
                }
            }
    }
    
    public func getPosts(
        for email: String,
        completion: @escaping (Result<[BlogPost], Error>) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }), error == nil else {
                    return
                }
                
                let posts: [BlogPost] = documents.compactMap { dictionary in
                    guard let id = dictionary["id"] as? String,
                          let title = dictionary["title"] as? String,
                          let text = dictionary["body"] as? String,
                          let timestamp = dictionary["created"] as? TimeInterval,
                          let url = dictionary["headerImageUrl"] as? String,
                          let email = dictionary["emailOfOwner"] as? String
                    else {
                        print("Invalid post fetch conversion")
                        return nil
                    }
                    
                    let post = BlogPost(
                        identifier: id,
                        title: title,
                        timestamp: timestamp,
                        headerImageUrl: URL(string: url),
                        text: text,
                        emailOfOwner: email
                    )
                    return post
                }
                completion(.success(posts.sorted(by: { $0.timestamp > $1.timestamp })))
            }
    }
    
    public func insert(
        user: User,
        completion: @escaping (Bool) -> Void
    ) {
        let documentID = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data = [
            "email": user.email,
            "name": user.name
        ]
        
        database
            .collection("users")
            .document(documentID)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    public func getUser(email: String, completion: @escaping (User?) -> Void) {
        let documentID = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(documentID)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String:String],
                      let name = data["name"],
                      error == nil else {
                    print("Failed to get user from db")
                    return
                }
                
                let ref: String? = data["profile_photo"]
                let user = User(name: name, email: email, profilePictureRef: ref)
                completion(user)
            }
    }
    
    public func updateProfilePhoto(email: String, completion: @escaping (Bool) -> Void) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        
        let photoReference = "profile_pictures/\(path)/photo.png"
        
        let dbRef = database
            .collection("users")
            .document(path)
        
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            data["profile_photo"] = photoReference
            
            dbRef.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
