//
//  AllPostsViewModel.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class PostsViewModel: ObservableObject {
    @Published var allPosts: [Post] = [] {
        didSet {
            fetchingState = allPosts.isEmpty ? .empty : .loaded
        }
    }
    @Published var myPosts: [Post] = []
    @Published var myFavorites: [Post] = []
    
    let postRepository = PostRepository()
    @Published var fetchingState: FetchingProcessState = .loading
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default.publisher(for: .authStateChanged)
            .sink { [weak self] _ in
                self?.reset()
                print("PostsViewModelData was cleared")
            }
            .store(in: &cancellables)
        Task {
            self.allPosts = await fetchAllPostsAndErrorHandling()
        }
    }
    
    func reset() {
            allPosts = []
            myPosts = []
            myFavorites = []
            fetchingState = .loading
        print("PostsViewModelData was cleared")
        }
    
    func fetchAllPostsAndErrorHandling() async -> [Post] {
            do {
                fetchingState = .loading
                let allPosts = try await postRepository.fetchAllPosts()
                if allPosts.isEmpty {
                    fetchingState = .empty
                } else {
                    fetchingState = .loaded
                }
                return allPosts
            } catch {
                print("Debug: error occured while fetching all posts: \(error)")
                fetchingState = .error(error)
                return []
            }
    }
    
    func fetchMyPostsAndErrorHandling() {
        Task {
            do {
                self.myPosts = try await postRepository.fetchMyPosts()
            } catch {
                print("Debug:: Error in PostViewModel/fetchMyPostsAndErrorHandling/Error:: \(error.localizedDescription)")
            }
            
        }
    }
    
    func fetchMyFavoritePostsAndErrorHandling() {
        Task {
            do {
                self.myFavorites = try await postRepository.fetchMyFavoritePosts()
            } catch {
                print("Debug:: Error in PostViewModel/fetchMyFavoritePostsAndErrorHandling/Error:: \(error.localizedDescription)")
            }
        }
    }
    
    func makeCreatePostfunc() -> CreatePostView.CreatePost{
        return {
            [weak self] post in
            try await self?.postRepository.createPost(post)
            self?.allPosts.insert(post, at: 0)
        }
    }
    
    func deletePostAndErrorhandling(post: Post) {
        Task {
            do {
                try await postRepository.delete(post: post)
                DispatchQueue.main.async {
                    self.allPosts.removeAll{ $0.id == post.id }
                }
            } catch {
                print("Debug: error occured while deleting post/Error:\(error)")
            }
        }
    }
    
    func addCommentAndErrorHandling(post: Post, userComment: UserComment) {
        Task {
            do {
                try await postRepository.addComment(post: post, userComment: userComment)
                guard let index = self.allPosts.firstIndex(where: { $0.id == post.id }) else { return }
                DispatchQueue.main.async {
                    self.allPosts[index].comments.append(userComment)
                }
            } catch {
                print("Debug: error occured while adding a comment/Error: \(error)")
            }
        }
    }
    
    func deleteCommentAndErrorHandling(post: Post, userComment: UserComment) {
        Task {
            do {
                try await postRepository.deleteComment(post: post, userComment: userComment)
                guard let index = self.allPosts.firstIndex(where: {$0.id == post.id}) else { return }
                DispatchQueue.main.async {
                    self.allPosts[index].comments.removeAll {$0.id == userComment.id}
                }
            } catch {
                print("Debug: error occured while deleting comment/Error: \(error)")
            }
        }
    }
    
    func toggleFavorite(post: Post) {
        Task {
            do {
                try await postRepository.toggleFavorite(post: post)
                guard let currentUserId = Auth.auth().currentUser?.uid else { return }
                let index:Int? = self.allPosts.firstIndex(where: { $0.id == post.id })
                guard let checkedIndex = index else {
                    return
                }
                if self.allPosts[checkedIndex].favoriteByUsers.contains(where: { $0 == currentUserId }) {
                    self.allPosts[checkedIndex].favoriteByUsers.removeAll { $0 == currentUserId }
                } else {
                    self.allPosts[checkedIndex].favoriteByUsers.append(currentUserId)
                }
            } catch {
                print("Debug: error occured while toggleFavorite/Error: \(error)")
            }
        }
    }
}
