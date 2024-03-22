//
//  FollowingView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FollowingView: View {
    @ObservedObject var authVm: AuthViewModel
    @ObservedObject var searchUsersVm: SearchUsersViewModel
    @State private var followingUsers: [UserProfile] = []
    
    var body: some View {

        List(followingUsers) { user in
            NavigationLink(destination: SearchUserProfileView(authVm: authVm, searchUsersVm: searchUsersVm, thisProfileUser: user)) {
                HStack {
                    AsyncImage(url: URL(string: user.imageUrl)) { phase in
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
                    .overlay(Circle().stroke(Color.white, lineWidth: 0))
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(user.id)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }

        }
        .listStyle(.plain)
        .onAppear {
            Task {
                await fetchFollowingUsers()
            }
        }
        
    }
    
    private func fetchFollowingUsers() async{
        if let currentUserUid = authVm.userProfile?.id {
            let db = Firestore.firestore()
            do {
                let querySnapshot = try await db.collection("users").whereField("followedBy", arrayContains: currentUserUid).getDocuments()
                DispatchQueue.main.async {
                    self.followingUsers = querySnapshot.documents.compactMap { document in
                        try? document.data(as: UserProfile.self)
                    }
                }
            } catch {
                print("Debug:: cannot get snapshot in FollowingView/fetchFollowingUsers")
            }
        }
    }
}

#Preview {
    FollowingView(authVm: AuthViewModel(), searchUsersVm: SearchUsersViewModel())
}
