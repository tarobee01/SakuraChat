//
//  MyPostView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/12.
//

import SwiftUI
import FirebaseAuth

struct MyPostView: View {
    @ObservedObject var postsVm: PostsViewModel
    @ObservedObject var authVm: AuthViewModel
    let currentUser = Auth.auth().currentUser
    @State private var isShowingDialog = false
    
    var body: some View {
        NavigationStack {
            if !postsVm.myPosts.isEmpty {
                List {
                    ForEach(postsVm.myPosts) { post in
                        NavigationLink(destination: CommentsView(postsVm: postsVm, authVm: authVm, post: post), label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top) {
                                    HStack(spacing: 10) {
                                        AsyncImage(url: URL(string: post.userProfile.imageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable()
                                            case .failure:
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                            @unknown default:
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                            }
                                        }
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .foregroundColor(.gray)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        VStack(alignment: .leading) {
                                            Text(post.userProfile.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(post.userProfile.id)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                    }
                                    Spacer()
                                    Text(post.timestamp.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                }
                                VStack(alignment: .leading) {
                                    Text(post.title)
                                    Text(post.content)
                                }
                                HStack {
                                    Button(action: {
                                        postsVm.toggleFavorite(post: post)
                                    }, label: {
                                        Image(systemName: post.favoriteByUsers.contains(where: {$0 == authVm.user?.id }) ? "heart.fill" : "heart")
                                            .font(.title)
                                            .animation(.default, value: post.favoriteByUsers.contains(where: {$0 == authVm.user?.id }))
                                    })
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.borderless)
                                    Spacer()
                                    if(post.userProfile.id == authVm.user?.id) {
                                        Button(action: {
                                            isShowingDialog = true
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                                .font(.title2)
                                        }
                                        .labelStyle(.iconOnly)
                                        .buttonStyle(.borderless)
                                    }
                                }
                                .foregroundColor(.gray)
                                .confirmationDialog("Delete posts?", isPresented: $isShowingDialog) {
                                    Button("Delete", role: .destructive) {
                                        postsVm.deletePostAndErrorhandling(post: post)
                                    }
                                    Button("Cancel") { }
                                }
                            }
                        })
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                VStack(alignment: .center, spacing: 10) {
                    Text("No Posts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("There aren’t any posts yet.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .onAppear {
            postsVm.fetchMyPostsAndErrorHandling()
        }
    }
}

#Preview {
    MyPostView(postsVm: PostsViewModel(), authVm: AuthViewModel())
}
