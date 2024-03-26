//
//  SettingView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/12.
//

import SwiftUI
import FirebaseAuth

struct SettingView: View {
    @ObservedObject var authVm: AuthViewModel
    @State var isShowingEditPasswordView = false
    @State var isShowingEditEmailView = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    NavigationLink(destination: EditProfileView(authVm: authVm), label: {
                        HStack(alignment: .top) {
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
                            .frame(width: 45, height: 45)
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 0))
                            VStack(alignment: .leading) {
                                Text(authVm.userProfile?.name ?? "no name")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Text(authVm.userProfile?.email ?? "no email" )
                            }
                        }
                    })
                }
                Section("Vocabulary") {
                    NavigationLink(destination: 
                                    NavigationStack {
                        ZStack {
                            Color.backgroundColor
                            VocabularyView(authVm: authVm)
                                .navigationTitle("YourVocabulary")
                                .navigationBarTitleDisplayMode(.inline)
                                .padding(.top, 100)
                        }
                        .ignoresSafeArea()
                    }
                    ) {
                        Text("My Vocabulary")
                    }
                }
                Section("Login Information") {
                    Button(action: {
                        isShowingEditPasswordView = true
                    }, label:  {
                        Text("Change My Password")
                    })
                    Button(action: {
                        isShowingEditEmailView = true
                    }, label: {
                        Text("Change My Email")
                    })
                }
            }
            .sheet(isPresented: $isShowingEditPasswordView) {
                EditPasswordView(authVm: authVm)
            }
            .sheet(isPresented: $isShowingEditEmailView) {
                EditEmailView(authVm: authVm)
            }
            .navigationTitle("Setting")
            .onAppear {
                Task {
                    do {
                        try await authVm.getUserProfile()
                    } catch {
                        print("cannnot get userProfile in SettingView/onAppear")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingView(authVm: AuthViewModel())
}
