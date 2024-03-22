//
//  EditEmailView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/14.
//

import SwiftUI
import FirebaseAuth

struct EditEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authVm: AuthViewModel
    let currentEmail: String?
    @State private var email = ""
    @State private var isShowingDialog = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    init(authVm: AuthViewModel) {
        self.authVm = authVm
        self.currentEmail = Auth.auth().currentUser?.email
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("new email") {
                    SecureField("new email", text: $email)
                        .textContentType(.emailAddress)
                }
                Section("current email address") {
                    Text(currentEmail ?? "cannot get email")
                }
            }
            .navigationTitle("Email Setting")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isShowingDialog = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Are you sure", isPresented: $isShowingDialog) {
                Button("Change") {
                    Task {
                        do {
                            try await authVm.changeUsersEmail(newEmail: email)
                            alertTitle = "Succeed"
                            alertMessage = "We sent a verification message to your email address, please check and verify our letter"
                            isShowingAlert = true
                            dismiss()
                        } catch {
                            print("Debug:: Error occured while changing Users Email/Error:: \(error.localizedDescription)")
                            alertTitle = "Failed"
                            alertMessage = "Failed to change your pass Word/Error:: \(error.localizedDescription)"
                            isShowingAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text("\(alertMessage)"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    EditEmailView(authVm: AuthViewModel())
}
