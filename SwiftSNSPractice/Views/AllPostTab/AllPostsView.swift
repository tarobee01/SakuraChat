//
//  ListView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI
import FirebaseAuth

struct AllPostsView: View {
    @ObservedObject var postsVm: PostsViewModel
    @State var isCreatePostViewShowing = false
    @ObservedObject var authVm: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                switch(postsVm.fetchingState) {
                case .loading:
                    ProgressView()
                case .loaded:
                    LoadedView(postsVm: postsVm, authVm: authVm)
                case .empty:
                    EmptyView()
                case .error(let error):
                    ErrorView(error: error, retryfetch: {
                        Task {
                            await postsVm.fetchAllPostsAndErrorHandling()
                        }
                    })
                }
            }
            .navigationTitle("AllPosts")
            .toolbar {
                Button(action: {isCreatePostViewShowing = true}) {
                    Image(systemName: "square.and.pencil")
                        .font(.headline)
                }
            }
            .sheet(isPresented: $isCreatePostViewShowing) {
                CreatePostView(authVm: authVm, createPost: postsVm.makeCreatePostfunc())
            }
            .onAppear {
                Task {
                    await postsVm.fetchAllPostsAndErrorHandling()
                }
            }
        }
    }
}

#Preview {
    AllPostsView(postsVm: PostsViewModel(), authVm: AuthViewModel())
}
