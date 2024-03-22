//
//  PostModel.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import Foundation
import FirebaseAuth

struct Post: Identifiable, Equatable, Codable {
    var userProfile: UserProfile
    var title: String
    var content: String
    var timestamp: Date
    var id: UUID
    var favoriteByUsers: [String]
    var comments: [UserComment]
}

struct User: Identifiable, Equatable, Codable {
    var id : String
    var name: String
}

struct UserProfile: Identifiable, Equatable, Codable {
    var name: String
    var description: String
    var imageUrl: String
    var email: String
    var id: String
    var following: [String]
    var followedBy: [String]
}

struct UserComment: Identifiable, Equatable, Codable {
    var id: UUID
    var commentUser: UserProfile
    var comment: String
}
