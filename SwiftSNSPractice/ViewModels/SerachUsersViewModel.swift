//
//  SerachUsersViewModel.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/17.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class SearchUsersViewModel: ObservableObject {
    //serachView用のデータ
    @Published var filteredUsers: [UserProfile] = []
    //searchUserProfileView用のデータ
    @Published var userPosts: [Post] = []
    @Published var userFavoritePosts: [Post] = []
    @Published var searchUserProfile: UserProfile?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default.publisher(for: .authStateChanged)
            .sink { [weak self] _ in
                self?.reset()
            }
            .store(in: &cancellables)
        Task {
            await fetchUsers(searchText: "")
        }
    }
    
    func reset() {
            filteredUsers = []
            userPosts = []
            userFavoritePosts = []
        print("searchUsersViewModelData was cleared")
        }

    //ユーザーを検索する
    func fetchUsers(searchText: String) async {
        let currentUserUid = Auth.auth().currentUser?.uid ?? "no id"
        //searchTextが空の時
        if searchText.isEmpty {
            let db = Firestore.firestore()
            do {
                let querySnapshot = try await db.collection("users").getDocuments()
                var allUsers: [UserProfile] = []
                for document in querySnapshot.documents {
                    let user = try document.data(as: UserProfile.self)
                    if user.id == currentUserUid {
                        continue
                    }
                    allUsers.append(user)
                  }
                self.filteredUsers = allUsers
            } catch {
                print("Debug:: Error occured in SerachUsersViewModel/fetchUsers/Error::\(error.localizedDescription)")
            }
        } else { //テキストが入って居る時
            let db = Firestore.firestore()
            var combinedUsers: [UserProfile] = []
            
            // nameで検索
            do {
                let nameQuerySnapshot = try await db.collection("users").whereField("name", isEqualTo: searchText).getDocuments()
                for document in nameQuerySnapshot.documents {
                    let user = try document.data(as: UserProfile.self)
                    if user.id == currentUserUid {
                        continue
                    }
                    combinedUsers.append(user)
                }
            } catch {
                print("Debug:: Error occured in SerachUsersViewModel/fetchUsers/Error::\(error.localizedDescription)")
            }
            
            // uidで検索
            do {
                let uidQuerySnapshot = try await db.collection("users").whereField("id", isEqualTo: searchText).getDocuments()
                for document in uidQuerySnapshot.documents {
                    let user = try document.data(as: UserProfile.self)
                    if user.id == currentUserUid {
                        continue
                    }
                    combinedUsers.append(user)
                }
            } catch {
                print("Debug:: Error occured in SerachUsersViewModel/fetchUsers/Error::\(error.localizedDescription)")
            }
            // 重複を除去して結果を設定
            self.filteredUsers = combinedUsers
        }
    }
    
    // ユーザーのポストをフェッチする関数
    func fetchUserPosts(userId: String) async {
        if userId == "no id" {
            return
        }
        let db = Firestore.firestore()
        do {
            let querySnapshot = try await db.collection("Posts_v6").whereField("userProfile.id", isEqualTo: userId).getDocuments()

            self.userPosts = querySnapshot.documents.compactMap { document in
                return try? document.data(as: Post.self)
            }
        } catch {
            print("Error fetching user posts: \(error.localizedDescription)")
        }
    }

    // ユーザーがお気に入りしたポストをフェッチする関数
    func fetchUserFavoritePosts(userId: String) async {
        if userId == "no id" {
            return 
        }
        let db = Firestore.firestore()
        do {
            let querySnapshot = try await db.collection("Posts_v6").whereField("favoriteByUsers", arrayContains: userId).getDocuments()
            self.userFavoritePosts = querySnapshot.documents.compactMap { document in
                return try? document.data(as: Post.self)
            }
        } catch {
            print("Error fetching favorite posts: \(error.localizedDescription)")
        }
    }
    
    func getSearchUsersProfile(userUid: String) async {
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("users").document(userUid).getDocument()
            self.searchUserProfile = try? snapshot.data(as: UserProfile.self)
        } catch {
            print("something went wrong in SearchUserViewModel/getSearchUsersProfile")
        }

    }
    
}
