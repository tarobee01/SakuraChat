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
                    ZStack {
                        Color.backgroundColor
                        VStack {
                            switch(authVm.signInProcess) {
                            case .working:
                                ProgressView()
                            default:
                                Image("sakuraLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 130)
                                SignInView(authVm: authVm)
                                NavigationLink( destination: CreateAccountView(authVm: authVm)) {
                                    Text("create account")
                                        .foregroundColor(.pinkColor)
                                        .padding(.top, 10)
                                }
                                Spacer()
                            }
                        }
                        .padding(.top, 130)
                    }
                    .ignoresSafeArea()
                }
            }
    }
}

#Preview {
    AuthView()
}

extension Color {
    static let backgroundColor = Color(red: 255 / 255, green: 250 / 255, blue: 253 / 255)
    static let brownColor = Color(red: 39 / 255, green: 15 / 255, blue: 3 / 255)
    static let pinkColor = Color(red: 221 / 255, green: 102 / 255, blue: 133 / 255)
}
