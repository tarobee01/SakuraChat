//
//  EmptyView.swift
//  SwiftSNSPractice
//
//  Created by 武林慎太郎 on 2024/02/10.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("No Posts")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text("There aren’t any posts yet.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    EmptyView()
}
