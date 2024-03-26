//
//  OtherUserLikesView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/19.
//

import SwiftUI

struct OtherUserLikesView: View {
    @ObservedObject var searchUsersVm: SearchUsersViewModel
    @ObservedObject var authVm: AuthViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundColor
            if !searchUsersVm.userFavoritePosts.isEmpty {
                List {
                    ForEach(searchUsersVm.userFavoritePosts) { favorite in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                HStack(spacing: 10) {
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
                                    .frame(width: 40, height: 40)
                                    .background(Color.white)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    VStack(alignment: .leading) {
                                        Text(favorite.userProfile.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(favorite.userProfile.id)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                    }
                                }
                                Spacer()
                                Text(favorite.timestamp.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                            }
                            VStack(alignment: .leading) {
                                Text(favorite.content)
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
                        Text("There aren’t any favorite posts yet.")
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
    OtherUserLikesView(searchUsersVm: SearchUsersViewModel(), authVm: AuthViewModel())
}
