//
//  MFAVerifyView.swift
//  TUUN
//
//  MFA認証UI（TOTPコード入力）
//

import SwiftUI

struct MFAVerifyView: View {
    @ObservedObject var cognitoService = SimpleCognitoService.shared
    @State private var totpCode = ""
    @State private var isVerifying = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // ヘッダー
                headerSection

                // TOTPコード入力
                totpInputSection

                // 確認ボタン
                verifyButton

                // メッセージ表示
                if !cognitoService.message.isEmpty {
                    messageSection
                }

                Spacer()

                // ヘルプテキスト
                helpSection
            }
            .padding()
            .navigationTitle("二段階認証")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        cognitoService.resetMFAState()
                        dismiss()
                    }
                }
            }
            .onChange(of: cognitoService.isSignedIn) { isSignedIn in
                if isSignedIn {
                    dismiss()
                }
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("認証コードを入力")
                .font(.title2)
                .fontWeight(.bold)

            Text("認証アプリに表示されている6桁のコードを入力してください。")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private var totpInputSection: some View {
        VStack(spacing: 16) {
            // 6桁入力フィールド
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    digitBox(at: index)
                }
            }

            // 隠し入力フィールド
            TextField("", text: $totpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: totpCode) { newValue in
                    // 6桁に制限
                    if newValue.count > 6 {
                        totpCode = String(newValue.prefix(6))
                    }
                    // 数字のみに制限
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        totpCode = filtered
                    }
                }
        }
        .onTapGesture {
            // タップで入力フィールドにフォーカス（実装上の制約により完全には動作しない場合あり）
        }
    }

    private func digitBox(at index: Int) -> some View {
        let digit = index < totpCode.count ? String(Array(totpCode)[index]) : ""
        let isFilled = !digit.isEmpty

        return Text(digit)
            .font(.system(size: 28, weight: .medium, design: .monospaced))
            .frame(width: 48, height: 56)
            .background(isFilled ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFilled ? Color.blue : Color(.systemGray4), lineWidth: 1.5)
            )
    }

    private var verifyButton: some View {
        Button(action: {
            Task {
                isVerifying = true
                await cognitoService.verifyMFA(totpCode: totpCode)
                isVerifying = false
            }
        }) {
            HStack {
                if isVerifying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("認証する")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(totpCode.count == 6 ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(totpCode.count != 6 || isVerifying)
    }

    private var messageSection: some View {
        HStack {
            Image(systemName: cognitoService.message.contains("失敗") || cognitoService.message.contains("エラー") ? "exclamationmark.triangle" : "checkmark.circle")
            Text(cognitoService.message)
        }
        .font(.subheadline)
        .foregroundColor(cognitoService.message.contains("失敗") || cognitoService.message.contains("エラー") ? .red : .green)
        .padding()
        .background(
            (cognitoService.message.contains("失敗") || cognitoService.message.contains("エラー") ? Color.red : Color.green)
                .opacity(0.1)
        )
        .cornerRadius(8)
    }

    private var helpSection: some View {
        VStack(spacing: 8) {
            Text("認証アプリが必要ですか？")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Google Authenticator または Microsoft Authenticator をお使いください。")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }
}

#Preview {
    MFAVerifyView()
}
