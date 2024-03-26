//
//  AddWordsView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/23.
//

import SwiftUI

struct AddWordsView: View {
    @ObservedObject var authVm: AuthViewModel
    @State var inputText: String
    @State var addedWordsList: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        TextField("What you learned today", text: $inputText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .background(Color(.systemGray6))

                        Button("ADD TO TABLE ↓") {
                            addedWordsList.append(inputText)
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color.pinkColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        Button(action: {
                            Task {
                                let result = await authVm.addWordsToVocabulary(words: addedWordsList)
                                if result == true {
                                    alertTitle = "Succeed"
                                    alertMessage = "New words were added to your vocabulary"
                                    isShowingAlert = true
                                } else {
                                    alertTitle = "Failed"
                                    alertMessage = "Failed to add new words to your vocabulary"
                                    isShowingAlert = true
                                }
                            }
                        }) {
                            Text("Add to My Vocabulary +")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color.pinkColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        VStack {
                            Text("TABLE")
                            List {
                                ForEach(addedWordsList, id: \.self) { word in
                                    Text(word)
                                }
                                .onDelete { indices in
                                    addedWordsList.remove(atOffsets: indices)
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .padding(.top, 50)
                }
                .padding(.top)
            }
            .navigationTitle("Add Words to Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert) {
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        alertTitle = ""
                        alertMessage = ""
                        dismiss()
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.pinkColor)
                            .font(.headline)
                    }
                }
            }
        }

    }
    
    init(authVm: AuthViewModel) {
        self.authVm = authVm
        _inputText = State(initialValue: "")
        _addedWordsList = State(initialValue: [])
    }
}

#Preview {
    AddWordsView(authVm: AuthViewModel())
}

