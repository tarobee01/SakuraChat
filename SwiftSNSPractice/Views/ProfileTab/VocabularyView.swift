//
//  VocabularyView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/03/23.
//

import SwiftUI

struct VocabularyView: View {
    @ObservedObject var authVm: AuthViewModel
    var filteredVocabulary: [String]? {
        if let vocabulary = authVm.userProfile?.vocabulary {
            let filteredVocabulary = vocabulary.filter {
                !authVm.defaultVocabulary.contains($0)
            }
            return filteredVocabulary
        } else {
            return []
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor
            if !(filteredVocabulary?.isEmpty ?? false) {
                List {
                    ForEach(filteredVocabulary ?? [], id: \.self) { word in
                        HStack {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.gray)
                                .foregroundColor(Color.brownColor)
                            Text(word)
                                .foregroundColor(Color.brownColor)
                            Spacer()
                            Button(action: {
                                Task {
                                    await authVm.removeWordFromVocabulary(word: word)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                        }
                        .listRowBackground(Color.backgroundColor)
                    }
                }
                .listStyle(.plain)
            } else {
                VStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text("No Vocabulary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("There aren’t any vocabulary yet.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await authVm.getUserProfile()
                } catch {
                    print("Debug:: cannot get userProfile in VocabularyView/Onappear")
                }
            }
        }

    }
}

#Preview {
    VocabularyView(authVm: AuthViewModel())
}
