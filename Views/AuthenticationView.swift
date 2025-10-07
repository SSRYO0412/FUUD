//
//  AuthenticationView.swift
//  AWStest
//
//  認証画面
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmationCode = ""
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            if showConfirmation {
                confirmationView
            } else {
                loginView
            }
        }
        .alert("メッセージ", isPresented: .constant(!cognitoService.message.isEmpty)) {
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
            
            // ボタン
            VStack(spacing: 12) {
                Button("ログイン") {
                    Task {
                        await cognitoService.signIn(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(email.isEmpty || password.isEmpty)
                
                Button("新規登録") {
                    Task {
                        await cognitoService.signUp(email: email, password: password)
                        if cognitoService.message.contains("確認コード") {
                            showConfirmation = true
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(email.isEmpty || password.isEmpty)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // パスワード要件
            Text("パスワード: 8文字以上、大文字・小文字・数字・記号を含む")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .navigationTitle("ログイン")
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

#if DEBUG
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
