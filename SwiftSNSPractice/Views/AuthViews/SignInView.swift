//
//  SignInView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/12.
//

import SwiftUI

struct SignInView: View {
    @StateObject var authVm: AuthViewModel
    @State var email = ""
    @State var password = ""

    var body: some View {
        VStack {
            Text("SakuraChat")
                .font(.title.bold())
                .foregroundColor(Color.brownColor)
            Group {
                TextField("email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("password", text: $password)
                    .textContentType(.password)
            }
            .padding()
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(10)
            Button("sign in") {
                authVm.signInAndErrorHandling(email: email, password: password)
            }
            .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.pinkColor)
                .cornerRadius(10)
        }
        .alert("SignIn Error", isPresented: $authVm.isSignInError) {
            
        } message: {
            Text("\(authVm.signInError?.localizedDescription ?? "unknown error")")
        }
        .onSubmit {
            authVm.signInAndErrorHandling(email: email, password: password)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SignInView(authVm: AuthViewModel())
}


