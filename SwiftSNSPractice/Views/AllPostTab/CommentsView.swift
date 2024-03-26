//
//  AddNewCommentView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/16.
//

import SwiftUI
import FirebaseAuth
import NaturalLanguage

struct CommentsView: View {
    @State private var userCommentInfo: UserComment
    @ObservedObject var postsVm: PostsViewModel
    @ObservedObject var authVm: AuthViewModel
    @State private var unfamiliarWords:[String] = []
    @State private var isShowingAlert = false
    
    let currentUser = Auth.auth().currentUser
    var post: Post
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                VStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    //ポスト
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
                                    .foregroundColor(Color.brownColor)
                                Text(post.userProfile.id)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.brownColor)
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
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .background(Color.backgroundColor)
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
                                            .foregroundColor(Color.brownColor)
                                        Text(userComment.commentUser.id)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color.brownColor)
                                    }
                                    Spacer()
                                }
                                VStack(alignment: .leading) {
                                    Text(userComment.comment)
                                        .foregroundColor(Color.brownColor)
                                    HStack {
                                        Spacer()
                                        if currentUser?.uid == userComment.commentUser.id {
                                            Button(action: {
                                                postsVm.deleteCommentAndErrorHandling(post: post, userComment: userComment)
                                            }) {
                                                Label("Delete", systemImage: "trash")
                                                    .font(.title3)
                                                    .foregroundColor(.gray)
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
                            .listRowBackground(Color.backgroundColor)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.backgroundColor)
                    //コメント
                    HStack {
                        TextField("add your comment", text: $userCommentInfo.comment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            checkComment()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(Color.pinkColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea()
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert) {
                let message = unfamiliarWords.joined(separator: ", ")
                return Alert(
                    title: Text("Unfamiliar Words"),
                    message: Text(message),
                    dismissButton: .default(Text("OK")) {
                        unfamiliarWords.removeAll()
                    }
                )
            }
        }
    }
    
    init(postsVm: PostsViewModel, authVm: AuthViewModel, post: Post) {        
        let userProfileAlt = UserProfile(name: "no name", description: "no description", imageUrl: "https://firebasestorage.googleapis.com/v0/b/swiftsnspractice.appspot.com/o/no_image_square.jpg?alt=media&token=f7256579-130a-4345-9882-e976f3fdf254", email: "no email", id: "no id", following: [], followedBy: [], vocabulary: [])
        _userCommentInfo = State(initialValue: UserComment(id: UUID(), commentUser: authVm.userProfile ?? userProfileAlt, comment: ""))
        self.postsVm = postsVm
        self.authVm = authVm
        self.post = post
    }
    
    func checkComment() {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = userCommentInfo.comment
        //入力したワードを分解して、抽出
        var extractedWords: [String] = []
        tokenizer.enumerateTokens(in: userCommentInfo.comment.startIndex..<userCommentInfo.comment.endIndex) { tokenRange, _ in
            let word = String(userCommentInfo.comment[tokenRange])
            extractedWords.append(word)
            return true
        }
        //vocabularyの中に含まれていない単語がないかチェック
        for word in extractedWords {
            if let vocabulary = authVm.userProfile?.vocabulary {
                if !vocabulary.contains(word) {
                    unfamiliarWords.append(word)
                }
            }
        }
        //unfamilarWordがあれば、アラートを表示、そうでなければコメントを追加
        if !unfamiliarWords.isEmpty {
            isShowingAlert = true
        } else {
            userCommentInfo.id = UUID()
            postsVm.addCommentAndErrorHandling(post: post, userCommentInfo: userCommentInfo)
        }
    }
}

#Preview {
    CommentsView(postsVm: PostsViewModel(), authVm: AuthViewModel(), post: Post(userProfile: UserProfile(name: "no name", description: "no des", imageUrl: "no url", email: "no email", id: "no id", following: [], followedBy: [], vocabulary: []), title: "", content: "testContent", timestamp: Date(), id: UUID(), favoriteByUsers: [], comments: []))
}
