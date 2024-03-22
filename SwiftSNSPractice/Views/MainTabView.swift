//
//  MainTabView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authVm: AuthViewModel
    @StateObject var postsVm = PostsViewModel()
    
    var body: some View {
        TabView {
            AllPostsView(postsVm: postsVm, authVm: authVm)
             .tabItem {
                 Label("Posts", systemImage: "list.dash")
             }
            ProfileView(postsVm: postsVm, authVm: authVm)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            SettingView(authVm: authVm)
                .tabItem {
                    Label("Setting", systemImage: "gearshape.fill")
                }
            MainSearchTabView(authVm: authVm)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    MainTabView(authVm: AuthViewModel())
}
