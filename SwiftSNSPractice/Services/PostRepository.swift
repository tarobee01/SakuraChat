//
//  PostRepository.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class PostRepository {
    //Firebaseプロジェクトのコレクションへの参照を取得する
    let postsReference = Firestore.firestore().collection("Posts_v6")
    
    func fetchAllPosts() async throws -> [Post]{
        let snapshot = try await postsReference
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Post.self)
        }
    }
    
    func fetchMyPosts() async throws -> [Post] {
        guard let currentUserUid = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "No current user", code: 0, userInfo: nil)
            }

            let snapshot = try await postsReference
                .whereField("userProfile.id", isEqualTo: currentUserUid)
                .order(by: "timestamp", descending: true)
                .getDocuments()

            return snapshot.documents.compactMap { document in
                try? document.data(as: Post.self)
            }
    }
    
    func fetchMyFavoritePosts() async throws -> [Post] {
        guard let currentUserUid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "no current user", code: 0, userInfo: nil)
        }
        
        let snapshot = try await postsReference
            .whereField("favoriteByUsers", arrayContains: currentUserUid)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Post.self)
        }
        
    }
    
    func createPost(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(from: post)
    }
    
    func delete(post: Post) async throws -> Void {
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
    
    func addComment(post: Post, userComment: UserComment) async throws -> Void {
        let document = postsReference.document(post.id.uuidString)
        // UserCommentを辞書型に変換
        let commentDict: [String: Any] = [
            "id": userComment.id.uuidString, // UUIDをStringに変換
            "commentUser": [
                "name": userComment.commentUser.name,
                "email": userComment.commentUser.email,
                "imageUrl": userComment.commentUser.imageUrl,
                "id": userComment.commentUser.id,
                "description": userComment.commentUser.description
            ],
            "comment": userComment.comment
        ]
        // コメントを更新
        try await document.updateData([
            "comments": FieldValue.arrayUnion([commentDict])
        ])
    }
    
    func deleteComment(post: Post, userComment: UserComment) async throws -> Void {
        let document = postsReference.document(post.id.uuidString)
           let snapshot = try await document.getDocument()
           
           if let data = snapshot.data(), var comments = data["comments"] as? [[String: Any]] {
               // 辞書の配列として扱われるcommentsをフィルタリング
               comments = comments.filter { dict in
                   guard let idString = dict["id"] as? String, let id = UUID(uuidString: idString) else { return true }
                   return id != userComment.id
               }
               // 更新されたcommentsでドキュメントを更新
               try await document.updateData(["comments": comments])
           }
    }
    
    func toggleFavorite(post: Post) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { throw NSError(domain: "No current user", code: 0, userInfo: nil) }
        //コレクションの中でpostIdに一致するドキュメントのパスを取得
        let document = postsReference.document(post.id.uuidString)
        
        // ドキュメントの現在の状態(スナップショット)を取得
        let snapshot = try await document.getDocument()
        //ドキュメントから特定のフィールドの値をキャストして取得
        if let favoriteByUsers = snapshot.data()?["favoriteByUsers"] as? [String] {
            // ユーザーの認証IDが含まれているかどうかで場合分け
            if favoriteByUsers.contains(currentUserId) {
                // ユーザーの認証IDが含まれている場合、削除
                try await document.updateData([
                    "favoriteByUsers": FieldValue.arrayRemove([currentUserId])
                ])
            } else {
                // ユーザーの認証IDが含まれていない場合、追加
                try await document.updateData([
                    "favoriteByUsers": FieldValue.arrayUnion([currentUserId])
                ])
            }
        }
    }
}


//setData関数を非同期関数に変換
private extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Method only throws if there’s an encoding error, which indicates a problem with our model.
            // We handled this with a force try, while all other errors are passed to the completion handler.
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

