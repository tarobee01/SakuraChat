//
//  AddNewCommentView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/16.
//

import SwiftUI
import FirebaseAuth

struct CommentsView: View {
    @State private var userCommentOp: UserComment
    @ObservedObject var postsVm: PostsViewModel
    @ObservedObject var authVm: AuthViewModel
    
    let currentUser = Auth.auth().currentUser
    var post: Post
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
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
                    .overlay(Circle().stroke(Color.gray, lineWidth: 0))
                    VStack(alignment: .leading) {
                        Text(post.userProfile.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(post.userProfile.id)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text(post.timestamp.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                }
                VStack(alignment: .leading) {
                    Text(post.title)
                    Text(post.content)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top, 5)

            //コメントリスト
            List {
                ForEach(post.comments) { userComment in
                    VStack {
                        HStack {
                            AsyncImage(url: URL(string: userComment.commentUser.imageUrl)) { phase in
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
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            VStack(alignment: .leading) {
                                Text(userComment.commentUser.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(userComment.commentUser.email)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                            Text(userComment.comment)
                            HStack {
                                Spacer()
                                if currentUser?.uid == userComment.commentUser.id {
                                    Button(action: {
                                        postsVm.deleteCommentAndErrorHandling(post: post, userComment: userComment)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                            .font(.title2)
                                    }
                                    .labelStyle(.iconOnly)
                                    .buttonStyle(.borderless)
                                } else {
                                    Button("") {
                                        
                                    }
                                }
                            }
                        }
                        .padding(2)
                    }
                }
            }.listStyle(PlainListStyle())
        }
        HStack {
            TextField("add your comment", text: $userCommentOp.comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                userCommentOp.id = UUID()
                postsVm.addCommentAndErrorHandling(post: post, userComment: userCommentOp)
            }) {
                Image(systemName: "paperplane.fill")
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], 20)
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    init(postsVm: PostsViewModel, authVm: AuthViewModel, post: Post) {
        let userProfileAl = UserProfile(name: "no name", description: "no description", imageUrl: "https://firebasestorage.googleapis.com/v0/b/swiftsnspractice.appspot.com/o/no_image_square.jpg?alt=media&token=f7256579-130a-4345-9882-e976f3fdf254", email: "no email", id: "no id", following: [], followedBy: [])
        _userCommentOp = State(initialValue: UserComment(id: UUID(), commentUser: authVm.userProfile ?? userProfileAl, comment: ""))
        self.postsVm = postsVm
        self.authVm = authVm
        self.post = post
    }
}

#Preview {
    CommentsView(postsVm: PostsViewModel(), authVm: AuthViewModel(), post: Post(userProfile: UserProfile(name: "no name", description: "no des", imageUrl: "no url", email: "no email", id: "no id", following: [], followedBy: []), title: "testTitle", content: "testContent", timestamp: Date(), id: UUID(), favoriteByUsers: [], comments: []))
}
