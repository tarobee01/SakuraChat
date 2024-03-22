//
//  CreatePostView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI
import FirebaseAuth

@MainActor
struct CreatePostView: View {
    @State var post = Post(userProfile: UserProfile(name: "no name", description: "no description", imageUrl: "no imageUrl", email: "no email", id: "no id", following: [], followedBy: []), title: "", content: "", timestamp: Date(), id: UUID(), favoriteByUsers: [], comments: [])
    @Environment(\.dismiss) private var dismiss
    @State var creatingState: CreatingState = .idle
    @State var isShowingError = false
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
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("title", text: $post.title)
                    TextEditor(text: $post.content)
                        .multilineTextAlignment(.leading)
                }
                Button(action: { postAndErrorHandling() }) {
                    switch creatingState {
                    case .working:
                        ProgressView()
                    case .success:
                        Image(systemName: "checkmark.circle.fill") // 成功マーク
                    default:
                        Text("post")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .listRowBackground(Color.accentColor)
            }
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
            .toolbar {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.blue)
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
}

#Preview {
    CreatePostView(authVm: AuthViewModel(), createPost: { _ in })
}
