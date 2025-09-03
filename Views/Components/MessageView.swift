//
//  MessageView.swift
//  AWStest
//
//  統一されたメッセージ表示コンポーネント
//

import SwiftUI

struct MessageView: View {
    let message: String
    var isError: Bool {
        message.contains("エラー") || message.contains("失敗") || message.contains("Error")
    }
    
    var body: some View {
        Text(message)
            .foregroundColor(isError ? .red : .green)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

// MARK: - Preview
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MessageView(message: "ログイン成功！")
            MessageView(message: "エラーが発生しました")
        }
        .padding()
    }
}