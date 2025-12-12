//
//  OnboardingAuthView.swift
//  FUUD
//
//  Lifesum風 アカウント作成画面
//

import SwiftUI
import AuthenticationServices

struct OnboardingAuthView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var cognitoService: SimpleCognitoService

    @State private var authMode: AuthMode = .options
    @State private var firstName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmationCode: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    enum AuthMode {
        case options
        case email
        case confirmation
    }

    private let primaryColor = Color(hex: "4CD964")

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                OnboardingBackButton {
                    if authMode == .email {
                        authMode = .options
                    } else if authMode == .confirmation {
                        authMode = .email
                    } else {
                        viewModel.previousStep()
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer().frame(height: 40)

            // Content based on mode
            switch authMode {
            case .options:
                authOptionsView
            case .email:
                emailSignUpView
            case .confirmation:
                confirmationView
            }

            Spacer()
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Auth Options View

    private var authOptionsView: some View {
        VStack(spacing: 24) {
            // Title
            Text("アカウントを作成")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("データを安全に保存し、\n複数のデバイスで同期できます")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)

            Spacer().frame(height: 20)

            // Sign in with Apple
            SignInWithAppleButton(.signUp) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(12)

            // Email option
            Button(action: { authMode = .email }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16))
                    Text("メールアドレスで登録")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "E8E8E8"), lineWidth: 1)
                )
            }

            // Terms
            Text("続けることで、")
                .foregroundColor(Color(hex: "6B7280"))
            + Text("利用規約")
                .foregroundColor(primaryColor)
                .underline()
            + Text("と")
                .foregroundColor(Color(hex: "6B7280"))
            + Text("プライバシーポリシー")
                .foregroundColor(primaryColor)
                .underline()
            + Text("に同意したものとみなされます")
                .foregroundColor(Color(hex: "6B7280"))
        }
        .font(.system(size: 12))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }

    // MARK: - Email Sign Up View

    private var emailSignUpView: some View {
        VStack(spacing: 24) {
            // Title
            Text("アカウントを作成")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 16) {
                // First name
                VStack(alignment: .leading, spacing: 8) {
                    Text("お名前")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B7280"))
                    TextField("", text: $firstName)
                        .textFieldStyle(OnboardingTextFieldStyle())
                }

                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("メールアドレス")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B7280"))
                    TextField("", text: $email)
                        .textFieldStyle(OnboardingTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("パスワード")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B7280"))
                    SecureField("", text: $password)
                        .textFieldStyle(OnboardingTextFieldStyle())

                    Text("8文字以上、大文字・小文字・数字・記号を含む")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "9CA3AF"))
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 20)

            // Create button
            if isLoading {
                ProgressView()
                    .frame(height: 50)
            } else {
                OnboardingPrimaryButton("CREATE", isEnabled: isEmailFormValid) {
                    signUpWithEmail()
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Confirmation View

    private var confirmationView: some View {
        VStack(spacing: 24) {
            // Title
            Text("確認コードを入力")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text("\(email)に送信された\n6桁のコードを入力してください")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)

            // Code input
            TextField("000000", text: $confirmationCode)
                .textFieldStyle(OnboardingTextFieldStyle())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .padding(.horizontal, 24)

            // Confirm button
            if isLoading {
                ProgressView()
                    .frame(height: 50)
            } else {
                OnboardingPrimaryButton("確認", isEnabled: confirmationCode.count == 6) {
                    confirmSignUp()
                }
                .padding(.horizontal, 24)
            }

            // Resend code
            Button(action: resendCode) {
                Text("コードを再送信")
                    .font(.system(size: 14))
                    .foregroundColor(primaryColor)
            }
        }
    }

    // MARK: - Form Validation

    private var isEmailFormValid: Bool {
        !firstName.isEmpty &&
        email.contains("@") &&
        password.count >= 8
    }

    // MARK: - Auth Methods

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        // Apple Sign In handling (simplified - would need full implementation)
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                if let email = credential.email {
                    viewModel.userData.email = email
                }
                if let fullName = credential.fullName {
                    viewModel.userData.firstName = fullName.givenName
                }
            }
            // For now, proceed to next step (would need actual Apple auth integration)
            viewModel.handleAuthSuccess()
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func signUpWithEmail() {
        isLoading = true

        Task {
            await cognitoService.signUp(email: email, password: password)
            viewModel.userData.email = email
            viewModel.userData.firstName = firstName
            await MainActor.run {
                isLoading = false
                if cognitoService.message.contains("error") || cognitoService.message.contains("Error") {
                    errorMessage = cognitoService.message
                    showError = true
                } else {
                    authMode = .confirmation
                }
            }
        }
    }

    private func confirmSignUp() {
        isLoading = true

        Task {
            await cognitoService.confirmSignUp(email: email, confirmationCode: confirmationCode)
            await MainActor.run {
                if cognitoService.message.contains("error") || cognitoService.message.contains("Error") {
                    isLoading = false
                    errorMessage = cognitoService.message
                    showError = true
                } else {
                    // Auto sign in after confirmation
                    Task {
                        await cognitoService.signIn(email: email, password: password)
                        await MainActor.run {
                            isLoading = false
                            if cognitoService.isSignedIn {
                                viewModel.handleAuthSuccess()
                            }
                        }
                    }
                }
            }
        }
    }

    private func resendCode() {
        // SimpleCognitoService doesn't have resendConfirmationCode
        // User needs to wait or try signing up again
        errorMessage = "確認コードはメールで送信されています。見つからない場合は迷惑メールフォルダをご確認ください。"
        showError = true
    }
}

// MARK: - Text Field Style

struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "E8E8E8"), lineWidth: 1)
            )
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingAuthView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingAuthView(viewModel: OnboardingViewModel())
            .environmentObject(SimpleCognitoService.shared)
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
