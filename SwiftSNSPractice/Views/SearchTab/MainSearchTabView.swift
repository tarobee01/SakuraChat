//
//  MainSearchTabView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/19.
//

import SwiftUI

struct MainSearchTabView: View {
    @State private var selectedTab = "SearchView"
    @ObservedObject var authVm: AuthViewModel
    @StateObject var searchUsersVm = SearchUsersViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("View", selection: $selectedTab) {
                    Text("Search").tag("SearchView")
                    Text("Following").tag("FollowingView")
                    Text("FollowedBy").tag("FollowedByView")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                switch selectedTab {
                case "SearchView":
                    SearchView(searchUsersVm: searchUsersVm, authVm: authVm)
                case "FollowingView":
                    FollowingView(authVm: authVm, searchUsersVm: searchUsersVm)
                case "FollowedByView":
                    FollowedByView(authVm: authVm, searchUsersVm: searchUsersVm)
                default:
                    Text("Unknown View")
                }
                Spacer()
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    MainSearchTabView(authVm: AuthViewModel())
}
