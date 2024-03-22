//
//  ErrorView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI

struct ErrorView: View {
    @State var error: Error
    let retryfetch: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(error.localizedDescription)
            Button("retry") {
                retryfetch()
            }
        }
    }
}

#Preview {
    ErrorView(error: DummyError(message: "ここにエラーメッセージが表示されます"), retryfetch: {})
}

struct DummyError: Error {
    let message: String
    var localizedDescription: String {
        return message
    }
}
