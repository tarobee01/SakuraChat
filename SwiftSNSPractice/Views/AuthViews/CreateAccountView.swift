//
//  CreateAccountView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/12.
//

import SwiftUI

struct CreateAccountView: View {
    @StateObject var authVm: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            switch(authVm.createAccountProcess) {
            case .working:
                ProgressView()
            default:
                Text("Create Account")
                    .font(.title.bold())
                Group {
                    TextField("name", text: $name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    TextField("email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("password", text: $password)
                        .textContentType(.password)
                }
                .padding()
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(10)
                Button("create") {
                    authVm.createAccountAndErrorHandling(name: name, email: email, password: password)
                }
                .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(10)

            }
        }
        .alert("Create Account Error", isPresented: $authVm.isCreateAccountError) {
            
        } message: {
            Text("\(authVm.createAccountError?.localizedDescription ?? "unknown error")")
        }
        .padding()
        .onSubmit {
            authVm.createAccountAndErrorHandling(name: name, email: email, password: password)
        }
    }
}

#Preview {
    CreateAccountView(authVm: AuthViewModel())
}
