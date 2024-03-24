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
                Form {
                    Section("write a word") {
                        Button("ADD TO TABLE ↓") {
                            addedWordsList.append(inputText)
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .listRowBackground(Color.blue)
                        TextField("what you learned today", text: $inputText)
                    }

                    Section("Table") {
                        Button("Add Words To Your Vocabulary +") {
                            Task {
                                let result = await authVm.addWordsToVocabulary(words: addedWordsList)
                                if result == true {
                                    alertTitle = "Succeed"
                                    alertMessage = "new words was added to your vocabulary"
                                    isShowingAlert = true
                                } else {
                                    alertTitle = "Faild"
                                    alertMessage = "failed to add new words to your vocabulary"
                                    isShowingAlert = true
                                }
                            }
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 0)
                        .foregroundColor(.white)
                        .listRowBackground(Color.blue)
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
            }
            .navigationTitle("Add words to Vocabulary")
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
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {

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

