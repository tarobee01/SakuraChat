//
//  SearchUserProfileView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/18.
//

import SwiftUI

struct SearchUserProfileView: View {
    @ObservedObject var authVm: AuthViewModel
    @ObservedObject var searchUsersVm: SearchUsersViewModel
    @State private var selectedTab = "UserPosts"
    @State private var isFollowing: Bool
    private let thisProfileUser: UserProfile
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    //背景
                    Image("backgroundImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: .infinity, height: 130)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(5.0)
                    //ユーザーのアイコン
                    AsyncImage(url: URL(string: searchUsersVm.searchUserProfile?.imageUrl ?? "https://firebasestorage.googleapis.com/v0/b/swiftsnspractice.appspot.com/o/no_image_square.jpg?alt=media&token=f7256579-130a-4345-9882-e976f3fdf254")) { phase in
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
                    .offset(y: 67)

                }
                //nameとfollowers
                VStack {
                    Text(searchUsersVm.searchUserProfile?.name ?? thisProfileUser.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    HStack {
                        Text("\(searchUsersVm.searchUserProfile?.following.count ?? thisProfileUser.following.count) following")
                        Text("\(searchUsersVm.searchUserProfile?.followedBy.count ?? thisProfileUser.followedBy.count) followers")
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                //descriptionとfollowbutton
                VStack {
                    HStack {
                        Text(searchUsersVm.searchUserProfile?.description ?? thisProfileUser.description)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    VStack {
                        if isFollowing {
                            Button(action: {
                                Task {
                                    await authVm.toggleFollow(currentUserId: authVm.userProfile?.id ?? "no id", targetUserId: searchUsersVm.searchUserProfile?.id ?? thisProfileUser.id)
                                    toggleIsFollowing()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "person.fill.checkmark")
                                        .foregroundColor(.white)
                                    Text("Unfollow")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(20)
                                .font(.subheadline)
                            }
                        } else {
                            Button(action: {
                                Task {
                                    await authVm.toggleFollow(currentUserId: authVm.userProfile?.id ?? "no id", targetUserId: searchUsersVm.searchUserProfile?.id ?? thisProfileUser.id)
                                    toggleIsFollowing()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "person.fill.badge.plus")
                                        .foregroundColor(.white)
                                    Text("Follow")
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(20)
                                .font(.subheadline)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                //タブバー
                VStack {
                    HStack {
                        TabButton(text: "UserPosts", selectedTab: $selectedTab)
                        TabButton(text: "UserLikes", selectedTab: $selectedTab)
                    }
                    VStack {
                        switch selectedTab {
                        case "UserPosts":
                            OtherUserPostView(searchUsersVm: searchUsersVm, authVm: authVm)
                        case "UserLikes":
                            OtherUserLikesView(searchUsersVm: searchUsersVm, authVm: authVm)
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)
                Spacer()
            }
            .onAppear {
                Task {
                    await searchUsersVm.fetchUserPosts(userId: thisProfileUser.id)
                    await searchUsersVm.fetchUserFavoritePosts(userId: thisProfileUser.id)
                    await searchUsersVm.getSearchUsersProfile(userUid: thisProfileUser.id)
                }
            }
            .navigationBarTitle("OtherUser")
        }
    }
    
    init(authVm: AuthViewModel, searchUsersVm: SearchUsersViewModel, selectedTab: String = "UserPosts", thisProfileUser: UserProfile) {
        self.authVm = authVm
        self.searchUsersVm = searchUsersVm
        self.thisProfileUser = thisProfileUser
        let isFollowingBool = authVm.userProfile?.following.contains(thisProfileUser.id)
        _isFollowing = State(initialValue: isFollowingBool ?? false)
    }
    
    func toggleIsFollowing() {
        let isFollowingBool = authVm.userProfile?.following.contains(thisProfileUser.id)
        self.isFollowing = isFollowingBool ?? false
    }
}

#Preview {
    SearchUserProfileView(authVm: AuthViewModel(), searchUsersVm: SearchUsersViewModel(), thisProfileUser: UserProfile(name: "no name", description: "no desc", imageUrl: "no image", email: "no email", id: "no id", following: [], followedBy: [], vocabulary: []))
}
