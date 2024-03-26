//
//  ProfileView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var postsVm: PostsViewModel
    @ObservedObject var authVm: AuthViewModel
    private let currentUser = Auth.auth().currentUser
    @State private var isShowingDialog = false
    @State private var selectedTab = "MyPosts"
    @State private var isShowingAddWordsView = false
    var filteredVocabularyCount: Int {
        if let vocabulary = authVm.userProfile?.vocabulary {
            let filteredVocabulary = vocabulary.filter {
                !authVm.defaultVocabulary.contains($0)
            }
            return filteredVocabulary.count
        } else {
            return 0
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                VStack(spacing: 10) {
                    ZStack {
                        //背景画像とユーザー情報
                        VStack {
                            //背景画像
                            Image("backgroundImage")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 130)
                                .background(Color.pinkColor)
                                .cornerRadius(5.0)
                            
                            VStack {
                                //nameとfollow
                                VStack {
                                    Text(authVm.userProfile?.name ?? "cannnot get name")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.brownColor)
                                        .padding(.top, 10)
                                    HStack(spacing: 10) {
                                        Text("\(authVm.userProfile?.following.count ?? 0 ) following")
                                            .font(.subheadline)
                                            .foregroundColor(Color.brownColor)
                                        Text("\(authVm.userProfile?.followedBy.count ?? 0 ) followers")
                                            .font(.subheadline)
                                            .foregroundColor(Color.brownColor)
                                        Text("\(filteredVocabularyCount) vocabulary")
                                            .font(.subheadline)
                                            .foregroundColor(Color.brownColor)
                                    }
                                }
                                
                            }
                            .padding(.top, 30)
                        }
                        //ユーザーのアイコン
                        AsyncImage(url: URL(string: authVm.userProfile?.imageUrl ?? "https://firebasestorage.googleapis.com/v0/b/swiftsnspractice.appspot.com/o/no_image_square.jpg?alt=media&token=f7256579-130a-4345-9882-e976f3fdf254")) { phase in
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
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .offset(y: 14)
                    }
                    
                    //descriptionとsignout
                    VStack {
                        HStack {
                            Text(authVm.userProfile?.description ?? "cannot get description")
                                .font(.subheadline)
                                .foregroundColor(Color.brownColor)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.horizontal)
                        VStack {
                            Button("Sign Out") {
                                authVm.signOutAndErrorHandling()
                            }
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color.pinkColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    //タブバー
                    VStack {
                        HStack {
                            TabButton(text: "MyPosts", selectedTab: $selectedTab)
                            TabButton(text: "MyLikes", selectedTab: $selectedTab)
                            TabButton(text: "Vocabulary", selectedTab: $selectedTab)
                        }
                        
                        VStack {
                            switch selectedTab {
                            case "MyPosts":
                                MyPostView(postsVm: postsVm, authVm: authVm)
                            case "MyLikes":
                                FavoritesView(postsVm: postsVm, authVm: authVm)
                            case "Vocabulary":
                                VocabularyView(authVm: authVm)
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 150)
                .navigationBarTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddWordsView = true
                        }) {
                            Text("ADD VOCAB")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(Color.brownColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                        }
                    }

                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("sakuraLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                    }
                }
                .sheet(isPresented: $isShowingAddWordsView) {
                    AddWordsView(authVm: authVm)
                }
                .onAppear {
                    postsVm.fetchMyPostsAndErrorHandling()
                    postsVm.fetchMyFavoritePostsAndErrorHandling()
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ProfileView(postsVm: PostsViewModel(), authVm: AuthViewModel())
}

struct TabButton: View {
    var text: String
    @Binding var selectedTab: String
    
    var body: some View {
        Button(action: {
            selectedTab = text
        }) {
            Text(text)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedTab == text ? Color.pinkColor : Color.pinkColor.opacity(0.2))
                .foregroundColor(selectedTab == text ? .white : .gray)
                .font(.caption)
                .fontWeight(.bold)
                .cornerRadius(5.0)
        }
    }
}
