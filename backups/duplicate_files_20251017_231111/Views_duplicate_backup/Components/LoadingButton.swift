//
//  LoadingButton.swift
//  AWStest
//
//  ローディング状態に対応したボタンコンポーネント
//

import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let backgroundColor: Color
    let action: () -> Void
    
    init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        backgroundColor: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Preview
struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LoadingButton(title: "ログイン", action: {}) // [DUMMY] プレビュー用
            LoadingButton(title: "処理中...", isLoading: true, action: {}) // [DUMMY] プレビュー用
            LoadingButton(title: "無効", isDisabled: true, backgroundColor: .gray, action: {}) // [DUMMY] プレビュー用
        }
        .padding()
    }
}
