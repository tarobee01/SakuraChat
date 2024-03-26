//
//  SearchView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/17.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var searchUsersVm: SearchUsersViewModel
    @ObservedObject var authVm: AuthViewModel
    @State private var searchText = ""
    var body: some View {
        List(searchUsersVm.filteredUsers) { user in
            NavigationLink(destination: 
                            SearchUserProfileView(authVm: authVm, searchUsersVm: searchUsersVm, thisProfileUser: user)) {
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
            .listRowBackground(Color.backgroundColor)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search by name or ID")
        .onChange(of: searchText) {
            Task {
                await searchUsersVm.fetchUsers(searchText: searchText)
            }
        }
    }
}

#Preview {
    SearchView(searchUsersVm: SearchUsersViewModel(), authVm: AuthViewModel())
}
