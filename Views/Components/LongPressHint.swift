//
//  LongPressHint.swift
//  AWStest
//
//  "?" ロングプレスヒントコンポーネント
//

import SwiftUI

struct LongPressHint: View {
    let helpText: String
    @State private var isShowingHelp = false

    var body: some View {
        Button {
            isShowingHelp = true
        } label: {
            Text("?")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.virgilGray400)
                .frame(width: 20, height: 20)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        .alert("詳細情報", isPresented: $isShowingHelp) {
            Button("閉じる", role: .cancel) {}
        } message: {
            Text(helpText)
        }
    }
}
