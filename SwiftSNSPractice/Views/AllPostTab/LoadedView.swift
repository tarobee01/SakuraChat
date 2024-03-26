//
//  LoadedView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI
import FirebaseAuth

struct LoadedView: View {
    @ObservedObject var postsVm: PostsViewModel
    @ObservedObject var authVm: AuthViewModel
    let currentUser = Auth.auth().currentUser
    @State private var isShowingDialog = false
    
    var body: some View {
        NavigationStack {
                List {
                    ForEach(postsVm.allPosts) { post in
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
                                                    .foregroundColor(Color.brownColor)
                                            @unknown default:
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .foregroundColor(Color.brownColor)
                                                    
                                            }
                                        }
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .background(Color.white)
                                        .foregroundColor(.gray)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 0))
                                        VStack(alignment: .leading) {
                                            Text(post.userProfile.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.brownColor)
                                                
                                            Text(post.userProfile.id)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.brownColor)
                                                
                                        }
                                    }
                                    Spacer()
                                    Text(post.timestamp.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(Color.brownColor)
                                        
                                }
                                VStack(alignment: .leading) {
                                    Text(post.content)
                                        .foregroundColor(Color.brownColor)
                                }
                                HStack {
                                    Button(action: {
                                        postsVm.toggleFavorite(post: post)
                                    }, label: {
                                        Image(systemName: post.favoriteByUsers.contains(where: {$0 == authVm.user?.id }) ? "heart.fill" : "heart")
                                            .font(.title2)
                                            .animation(.default, value: post.favoriteByUsers.contains(where: {$0 == authVm.user?.id }))
                                            .foregroundColor(Color.pinkColor)
                                    })
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.borderless)
                                    Spacer()
                                    if(post.userProfile.id == authVm.user?.id) {
                                        Button(action: {
                                            isShowingDialog = true
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                                .font(.title3)
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
                        .listRowBackground(Color.backgroundColor)

                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.backgroundColor)
        }
    }
}

#Preview {
    LoadedView(postsVm: PostsViewModel(), authVm: AuthViewModel())
}
