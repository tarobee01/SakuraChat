//
//  CreatePostView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI
import FirebaseAuth
import NaturalLanguage

@MainActor
struct CreatePostView: View {
    @State var post = Post(userProfile: UserProfile(name: "no name", description: "no description", imageUrl: "no imageUrl", email: "no email", id: "no id", following: [], followedBy: [], vocabulary: []), title: "", content: "", timestamp: Date(), id: UUID(), favoriteByUsers: [], comments: [])
    @Environment(\.dismiss) private var dismiss
    @State var creatingState: CreatingState = .idle
    @State private var isShowingError = false
    @State private var isShowingAlert = false
    @ObservedObject var authVm: AuthViewModel
    var errorMessage: String? {
            switch(creatingState) {
            case .failed(let error):
                return error.localizedDescription
            default:
                return nil
            }
        }
    typealias CreatePost =  (Post) async throws -> Void
    let createPost: CreatePost
    @State private var unfamiliarWords:[String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                VStack {
                        TextEditor(text: $post.content)
                            .frame(height: 200)
                            .cornerRadius(5)
                            .shadow(radius: 2)
                            .padding()
                    Button(action: {
                        checkPost()
                    }) {
                        switch creatingState {
                        case .working:
                            ProgressView()
                        case .success:
                            Image(systemName: "checkmark.circle.fill") 
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .cornerRadius(10)
                        default:
                            Text("Post")
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.pinkColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()
                }
                .background(Color.backgroundColor)
                .padding(.top, 100)
            }
            .ignoresSafeArea()
            .navigationTitle("createPost")
            .alert(isPresented: $isShowingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        creatingState = .idle // アラートを閉じたら.idleにリセット
                    }
                )
            }
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
            .toolbar {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.pinkColor)
                        .font(.headline)
                }
            }
            .onAppear {
                if let currentUser = Auth.auth().currentUser {
                    post.userProfile.name = authVm.userProfile?.name ?? "cannnot get name"
                    post.userProfile.imageUrl = authVm.userProfile?.imageUrl ?? "cannnot get imageURl"
                    post.userProfile.email = authVm.userProfile?.email ?? "cannnot get email address"
                    post.userProfile.id = currentUser.uid
                } else {
                    print("Debug:: cannot get currentUser in CreatePostView")
                }
            }
        }
    }
    
    
    func postAndErrorHandling() {
        Task {
            DispatchQueue.main.async {
                creatingState = .working
            }
            do {
                try await createPost(post)
                DispatchQueue.main.async {
                    creatingState = .success
                }
                dismiss()
            } catch {
                print("Debug: error occured while creatingPost: \(error)")
                DispatchQueue.main.async {
                    creatingState = .failed(error)
                    isShowingError = true
                }
            }
        }
    }
    func checkPost() {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = post.content
        //入力したワードを分解して、抽出
        var extractedWords: [String] = []
        tokenizer.enumerateTokens(in: post.content.startIndex..<post.content.endIndex) { tokenRange, _ in
            let word = String(post.content[tokenRange])
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
        //unfamilarWordがあれば、アラートを表示、そうでなければポスト
        if !unfamiliarWords.isEmpty {
            isShowingAlert = true
        } else {
            postAndErrorHandling()
        }
    }
}

#Preview {
    CreatePostView(authVm: AuthViewModel(), createPost: { _ in })
}
