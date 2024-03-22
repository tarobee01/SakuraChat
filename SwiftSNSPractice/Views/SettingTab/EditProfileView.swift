//
//  EditProfileView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/13.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var authVm: AuthViewModel
    @StateObject private var imageLoader = ImageLoader()
    
    @State private var name: String
    @State private var description: String
    @State private var pickedImage: PhotosPickerItem?
    @State private var pickedUiImage: UIImage?
    private var loadedImage: UIImage?
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingDialog = false
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("プロフィール情報") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    PhotosPicker(selection: $pickedImage, matching: .images, label: {
                        if let pickedUiImage = pickedUiImage {
                            Image(uiImage: pickedUiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        } else if let loadedImage = imageLoader.image {
                            Image(uiImage: loadedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .opacity(0.3)
                                .frame(width: 50, height: 50)
                        }
                    })
                }
                
                Section {
                    VStack {
                        Button(action: {
                            //新しく画像が選択されているか、元の画像のままかで場合分け
                            if let uiImage = pickedUiImage {
                                authVm.setUserProfile(name: name, description: description, inputImage: uiImage)
                                alertTitle = "Succeed"
                                alertMessage = "Your profile data was updated"
                                isShowingAlert = true
                            } else if let loaderImage = imageLoader.image {
                                authVm.setUserProfile(name: name, description: description, inputImage: loaderImage)
                                alertTitle = "Succeed"
                                alertMessage = "Your profile data was updated"
                                isShowingAlert = true
                            }
                            //要らないかも
                            else {
                                alertTitle = "Failed"
                                alertMessage = "cannot update your profile"
                                isShowingAlert = true
                            }
                        }) {
                            Label("Change Profile", systemImage: "person.crop.circle.fill.badge.checkmark")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background(Color.blue)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            isShowingDialog = true
                        }) {
                            Label("Delete This Account", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background(Color.red)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Profile Setting")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("\(alertTitle)"),
                    message: Text("\(alertMessage)"),
                    dismissButton: .default(Text("OK"))
                    )
            }
            .confirmationDialog("Are you Sure?", isPresented: $isShowingDialog) {
                Button("delete", role: .destructive) {
                    authVm.deleteUser()
                }
                Button("cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this account?")
            }
            .onChange(of: pickedImage) {
                Task {
                    if let imageData = try? await pickedImage?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: imageData) {
                            pickedUiImage = uiImage
                        } else {
                            print("Failed to convert data to UIImage")
                        }
                    } else {
                        print("Failed to load image data")
                    }
                }
            }
            .onAppear {
                if let imageUrl = authVm.userProfile?.imageUrl {
                    imageLoader.loadImage(from: imageUrl)
                }
            }
        }
    }
    
    init(authVm: AuthViewModel) {
        _name = State(initialValue: authVm.userProfile?.name ?? "")
        _description = State(initialValue: authVm.userProfile?.description ?? "")
        self.authVm = authVm
    }
}

#Preview {
    EditProfileView(authVm: AuthViewModel())
}

//画像をロードする用のクラス
class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        Task {
            do {
                let data = try await URLSession.shared.data(from: url)
                if let loadedImage = UIImage(data: data.0) {
                    DispatchQueue.main.async {
                        self.image = loadedImage
                    }
                }
            } catch {
                print("Failed to load image from URL: \(urlString)")
            }
        }
    }
}
