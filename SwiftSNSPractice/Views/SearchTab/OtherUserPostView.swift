//
//  OtherUserPostView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/19.
//

import SwiftUI

struct OtherUserPostView: View {
    @ObservedObject var searchUsersVm: SearchUsersViewModel
    @ObservedObject var authVm: AuthViewModel
    @State private var isShowingDialog = false
    
    var body: some View {
        ZStack {
            Color.backgroundColor
            if !searchUsersVm.userPosts.isEmpty {
                List {
                    ForEach(searchUsersVm.userPosts) { userPost in
                        VStack(alignment: .leading, spacing: 10){
                            HStack(alignment: .top) {
                                HStack(spacing: 10) {
                                    AsyncImage(url: URL(string: userPost.userProfile.imageUrl)) { phase in
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
                                        Text(userPost.userProfile.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(userPost.userProfile.id)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                    }
                                }
                                Spacer()
                                Text(userPost.timestamp.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                            }
                            VStack(alignment: .leading) {
                                Text(userPost.content)
                            }
                        }
                        .listRowBackground(Color.backgroundColor)
                    }
                }
                .listStyle(.plain)
            } else {
                VStack {
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
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    OtherUserPostView(searchUsersVm: SearchUsersViewModel(), authVm: AuthViewModel())
}
