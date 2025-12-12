//
//  NewPasswordView.swift
//  TUUN
//
//  新パスワード設定UI（仮パスワードからの変更）
//

import SwiftUI

struct NewPasswordView: View {
    @ObservedObject var cognitoService = SimpleCognitoService.shared
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss

    // MARK: - Password Validation

    private var hasMinLength: Bool {
        newPassword.count >= 8
    }

    private var hasUppercase: Bool {
        newPassword.contains { $0.isUppercase }
    }

    private var hasLowercase: Bool {
        newPassword.contains { $0.isLowercase }
    }

    private var hasDigit: Bool {
        newPassword.contains { $0.isNumber }
    }

    private var hasSpecialChar: Bool {
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        return newPassword.unicodeScalars.contains { specialChars.contains($0) }
    }

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    private var isPasswordValid: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecialChar && passwordsMatch
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // ヘッダー
                    headerSection

                    // パスワード入力
                    passwordInputSection

                    // パスワード要件
                    requirementsSection

                    // 設定ボタン
                    submitButton

                    // メッセージ表示
                    if !cognitoService.message.isEmpty {
                        messageSection
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("パスワード設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        cognitoService.newPasswordRequired = false
                        dismiss()
                    }
                }
            }
            .onChange(of: cognitoService.isSignedIn) { isSignedIn in
                if isSignedIn {
                    dismiss()
                }
            }
            .onChange(of: cognitoService.newPasswordRequired) { isRequired in
                if !isRequired && !cognitoService.isSignedIn {
                    // パスワード設定完了後、画面を閉じる
                    dismiss()
                }
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)

            Text("新しいパスワードを設定")
                .font(.title2)
                .fontWeight(.bold)

            Text("初回ログインのため、新しいパスワードを設定してください。")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var passwordInputSection: some View {
        VStack(spacing: 16) {
            SecureField("新しいパスワード", text: $newPassword)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)

            SecureField("パスワード確認", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)
        }
    }

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("パスワード要件")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                RequirementRow(text: "8文字以上", isMet: hasMinLength)
                RequirementRow(text: "大文字を含む", isMet: hasUppercase)
                RequirementRow(text: "小文字を含む", isMet: hasLowercase)
                RequirementRow(text: "数字を含む", isMet: hasDigit)
                RequirementRow(text: "記号を含む (!@#$%^&* など)", isMet: hasSpecialChar)
                RequirementRow(text: "パスワードが一致", isMet: passwordsMatch)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var submitButton: some View {
        Button(action: {
            Task {
                isSubmitting = true
                await cognitoService.respondToNewPasswordChallenge(newPassword: newPassword)
                isSubmitting = false
            }
        }) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("パスワードを設定")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isPasswordValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isPasswordValid || isSubmitting)
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
}

#Preview {
    NewPasswordView()
}
