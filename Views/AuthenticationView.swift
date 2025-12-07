//
//  AuthenticationView.swift
//  AWStest
//
//  認証画面（ログイン・新規登録・メール確認）
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmationCode = ""
    @State private var showConfirmation = false
    @State private var showMFASetup = false
    @State private var showMFAVerify = false

    // MARK: - Password Validation

    private var hasMinLength: Bool {
        password.count >= 8
    }

    private var hasUppercase: Bool {
        password.contains { $0.isUppercase }
    }

    private var hasLowercase: Bool {
        password.contains { $0.isLowercase }
    }

    private var hasDigit: Bool {
        password.contains { $0.isNumber }
    }

    private var hasSpecialChar: Bool {
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        return password.unicodeScalars.contains { specialChars.contains($0) }
    }

    private var isPasswordValid: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecialChar
    }

    var body: some View {
        NavigationView {
            if showConfirmation {
                confirmationView
            } else {
                loginView
            }
        }
        .onAppear {
            print("🟢 [TEST] AuthenticationView appeared - Console is working!")
        }
        .onChange(of: cognitoService.mfaSetupRequired) { isRequired in
            showMFASetup = isRequired
        }
        .onChange(of: cognitoService.mfaRequired) { isRequired in
            showMFAVerify = isRequired
        }
        .sheet(isPresented: $showMFASetup) {
            MFASetupView()
        }
        .sheet(isPresented: $showMFAVerify) {
            MFAVerifyView()
        }
        .alert("メッセージ", isPresented: .constant(!cognitoService.message.isEmpty && !cognitoService.mfaRequired && !cognitoService.mfaSetupRequired)) {
            Button("OK") {
                cognitoService.message = ""
            }
        } message: {
            Text(cognitoService.message)
        }
    }

    // MARK: - Login View

    @ViewBuilder
    private var loginView: some View {
        VStack(spacing: 32) {
            // アプリロゴとタイトル
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: 8) {
                    Text("TUUN")
                        .font(.largeTitle.bold())
                    Text("健康データ管理アプリ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // 入力フィールド
            VStack(spacing: 16) {
                TextField("メールアドレス", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("パスワード", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            // ログインボタン
            Button("ログイン") {
                Task {
                    await cognitoService.signIn(email: email, password: password)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .disabled(email.isEmpty || password.isEmpty)
            .padding(.horizontal)

            Spacer()

            // 新規登録へのリンク
            VStack(spacing: 8) {
                Text("アカウントをお持ちでない方")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NavigationLink(destination: signUpView) {
                    Text("新規登録はこちら")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.bottom)
        }
        .padding(.vertical)
        .navigationTitle("ログイン")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sign Up View

    @ViewBuilder
    private var signUpView: some View {
        VStack(spacing: 32) {
            // アプリロゴとタイトル
            VStack(spacing: 16) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: 8) {
                    Text("新規登録")
                        .font(.title.bold())
                    Text("アカウントを作成します")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // 入力フィールド
            VStack(spacing: 16) {
                TextField("メールアドレス", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("パスワード", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            // パスワード要件
            VStack(alignment: .leading, spacing: 8) {
                Text("パスワード要件")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    RequirementRow(text: "8文字以上", isMet: hasMinLength)
                    RequirementRow(text: "大文字を含む", isMet: hasUppercase)
                    RequirementRow(text: "小文字を含む", isMet: hasLowercase)
                    RequirementRow(text: "数字を含む", isMet: hasDigit)
                    RequirementRow(text: "記号を含む (!@#$%^&* など)", isMet: hasSpecialChar)
                }
                .font(.caption)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            // 登録ボタン
            Button("アカウント作成") {
                Task {
                    await cognitoService.signUp(email: email, password: password)
                    if cognitoService.message.contains("確認コード") {
                        showConfirmation = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .disabled(email.isEmpty || !isPasswordValid)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("新規登録")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Confirmation View

    @ViewBuilder
    private var confirmationView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: 8) {
                    Text("メール確認")
                        .font(.largeTitle.bold())
                    Text("メールに送信された6桁のコードを入力してください")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            TextField("確認コード", text: $confirmationCode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .frame(maxWidth: 200)
                .multilineTextAlignment(.center)
                .font(.title2.monospacedDigit())

            VStack(spacing: 12) {
                Button("確認") {
                    Task {
                        await cognitoService.confirmSignUp(
                            email: email,
                            confirmationCode: confirmationCode
                        )
                        if cognitoService.message.contains("完了") {
                            showConfirmation = false
                            confirmationCode = ""
                            // ログイン画面に戻る
                            email = ""
                            password = ""
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: 200)
                .disabled(confirmationCode.isEmpty)

                Button("戻る") {
                    showConfirmation = false
                    confirmationCode = ""
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("メール確認")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views

struct RequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption2)
                .foregroundStyle(isMet ? .green : .red)
            Text(text)
                .foregroundStyle(isMet ? .primary : .secondary)
        }
    }
}

#if DEBUG
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
