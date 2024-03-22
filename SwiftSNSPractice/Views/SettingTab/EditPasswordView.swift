//
//  EditPasswordView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/13.
//

import SwiftUI

struct EditPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authVm: AuthViewModel
    @State private var password1: String = ""
    @State private var password2: String = ""
    @State private var isShowingDialog = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    private var isMatchPasswords: Bool {
        return password1 == password2
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("new password") {
                    SecureField("new password", text: $password1)
                        .textContentType(.password)
                    SecureField("confirm your password", text: $password2)
                        .textContentType(.password)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isShowingDialog = true
                        }
                    }
            }
            .confirmationDialog("Are you sure?", isPresented: $isShowingDialog) {
                Button("Change") {
                    if isMatchPasswords == true {
                        Task {
                            do {
                                try await authVm.changeUsersPassword(newPass: password1)
                                alertTitle = "Success"
                                alertMessage = "Your password has been changed."
                                isShowingAlert = true
                                dismiss()
                            } catch {
                                print("Debug:: error occurred while changing user password/Error: \(error.localizedDescription)")
                                alertTitle = "Failed"
                                alertMessage = "Error occurred: \(error.localizedDescription)"
                                isShowingAlert = true
                            }
                        }
                    } else {
                        alertTitle = "Failed"
                        alertMessage = "input password is not matched, please enter same password in input form"
                        isShowingAlert = true
                    }
                }
            } message: {
                Text("Are you sure you want to change your password?")
            }
            .alert(isPresented: $isShowingAlert, content: {
                Alert(
                    title: Text("Alert"),
                    message: Text("\(alertMessage)"),
                    dismissButton: .default(Text("OK"))
                )
            })
            .navigationTitle("Password Setting")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EditPasswordView(authVm: AuthViewModel())
}
