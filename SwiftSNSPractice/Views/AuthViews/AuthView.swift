//
//  AuthView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/12.
//

import SwiftUI

struct AuthView: View {
    @StateObject var authVm = AuthViewModel()
    
    var body: some View {
        if authVm.isAuthenticated == true {
            MainTabView(authVm: authVm)
        } else {
            NavigationStack {
                switch(authVm.signInProcess) {
                case .working:
                    ProgressView()
                default:
                    SignInView(authVm: authVm)
                    NavigationLink("create account", destination: CreateAccountView(authVm: authVm))
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
