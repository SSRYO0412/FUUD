//
//  SimpleCognitoService.swift
//  AWStest
//
//  AWS SDK を使わないシンプルなCognito認証サービス
//

import Foundation

class SimpleCognitoService: ObservableObject {
    static let shared = SimpleCognitoService()
    
    // MARK: - Configuration
    private var config: ConfigurationManager.CognitoConfig {
        ConfigurationManager.shared.cognitoConfig
    }
    
    private var apiGatewayUrl: String {
        ConfigurationManager.shared.apiEndpoints.createUser
    }
    
    // MARK: - Published Properties
    @Published var isSignedIn = false
    @Published var message = ""
    @Published var currentUserEmail: String?

    // MARK: - MFA Properties
    @Published var mfaRequired = false
    @Published var mfaSetupRequired = false
    @Published var mfaSecretCode: String?

    // MARK: - New Password Properties
    @Published var newPasswordRequired = false

    // MARK: - Private Properties
    private var accessToken: String?
    private var idToken: String?
    private var refreshToken: String?
    private var tokenExpirationDate: Date?
    private var mfaSession: String?
    private(set) var pendingUsername: String?
    
    private init() {
        // Previews環境ではKeychainアクセス等を行わず即戻る（Canvas安定化）
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            return
        }
        // アプリ起動時に保存済みトークンを読み込み
        loadStoredTokens()
    }
    
    // MARK: - Authentication Methods
    
    /// ユーザー新規登録（AWS Cognito SignUp API）
    func signUp(email: String, password: String) async {
        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "ClientId": config.clientId,
                "Username": email,
                "Password": password,
                "UserAttributes": [
                    [
                        "Name": "email",
                        "Value": email
                    ]
                ]
            ] as [String: Any]

            // Cognitoエラーを詳細に取得するため直接リクエスト
            guard let url = URL(string: cognitoUrl) else {
                await MainActor.run {
                    self.message = "URLが無効です"
                }
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
            request.setValue("AWSCognitoIdentityProviderService.SignUp", forHTTPHeaderField: "X-Amz-Target")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    self.message = "サーバーからの応答が無効です"
                }
                return
            }

            if httpResponse.statusCode == 200 {
                // 成功
                await MainActor.run {
                    self.message = "アカウントが作成されました。確認コードがメールに送信されました。"
                }
            } else {
                // エラーレスポンスを解析
                let errorMessage = parseCognitoError(data: data, statusCode: httpResponse.statusCode)
                await MainActor.run {
                    self.message = errorMessage
                }
            }

        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.signUp")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }

    /// Cognitoエラーレスポンスを解析してユーザーフレンドリーなメッセージを返す
    private func parseCognitoError(data: Data, statusCode: Int) -> String {
        // Cognitoエラーレスポンス形式: {"__type": "ErrorType", "message": "..."}
        struct CognitoErrorResponse: Codable {
            let type: String?
            let message: String?

            private enum CodingKeys: String, CodingKey {
                case type = "__type"
                case message
            }
        }

        if let errorResponse = try? JSONDecoder().decode(CognitoErrorResponse.self, from: data) {
            let errorType = errorResponse.type ?? ""

            switch errorType {
            case "UsernameExistsException":
                return "このメールアドレスは既に登録されています"
            case "InvalidPasswordException":
                return "パスワードが要件を満たしていません。8文字以上で大文字・小文字・数字・記号を含めてください"
            case "InvalidParameterException":
                return "入力内容に問題があります。メールアドレスとパスワードを確認してください"
            case "TooManyRequestsException":
                return "リクエストが多すぎます。しばらく待ってからお試しください"
            default:
                return errorResponse.message ?? "アカウントの作成に失敗しました（コード: \(statusCode)）"
            }
        }

        return "アカウントの作成に失敗しました（コード: \(statusCode)）"
    }
    
    /// ユーザーログイン（AWS Cognito InitiateAuth API）
    func signIn(email: String, password: String) async {
        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"
            
            let requestBody = [
                "ClientId": config.clientId,
                "AuthFlow": "USER_PASSWORD_AUTH",
                "AuthParameters": [
                    "USERNAME": email,
                    "PASSWORD": password
                ]
            ] as [String: Any]
            
            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )
            
            struct CognitoAuthResponse: Codable {
                let authenticationResult: CognitoAuthResult?
                let challengeName: String?
                let session: String?

                private enum CodingKeys: String, CodingKey {
                    case authenticationResult = "AuthenticationResult"
                    case challengeName = "ChallengeName"
                    case session = "Session"
                }
            }
            
            let response: CognitoAuthResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: CognitoAuthResponse.self
            )
            
            if let authResult = response.authenticationResult {
                // 認証成功
                await handleAuthenticationSuccess(authResult: authResult, email: email)
            } else if let challengeName = response.challengeName {
                // チャレンジが必要
                await handleAuthChallenge(
                    challengeName: challengeName,
                    session: response.session,
                    username: email
                )
            } else {
                await MainActor.run {
                    self.message = "認証に失敗しました"
                }
            }
            
        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.signIn")
            
            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }
    
    /// メール確認（AWS Cognito ConfirmSignUp API）
    func confirmSignUp(email: String, confirmationCode: String) async {
        print("🔵 [DEBUG] confirmSignUp called with email: \(email)")
        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "ClientId": config.clientId,
                "Username": email,
                "ConfirmationCode": confirmationCode
            ] as [String: Any]

            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.ConfirmSignUp",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )

            struct CognitoConfirmSignUpResponse: Codable {
                // ConfirmSignUpは成功時に空のレスポンスを返すことがある
            }

            print("🔵 [DEBUG] Calling Cognito ConfirmSignUp API...")
            let _: CognitoConfirmSignUpResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: CognitoConfirmSignUpResponse.self
            )
            print("🔵 [DEBUG] Cognito ConfirmSignUp succeeded")

            // メール確認成功後、DynamoDBにユーザープロファイルを作成
            print("📧 Email confirmed, creating user profile...")
            print("🔵 [DEBUG] Calling createUserProfile API...")
            try await createUserProfile(email: email)
            print("🔵 [DEBUG] createUserProfile succeeded")

            await MainActor.run {
                print("🔵 [DEBUG] Setting success message")
                self.message = "確認完了！ログインしてください"
            }

        } catch {
            print("🔴 [DEBUG] Error in confirmSignUp: \(error)")
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.confirmSignUp")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
                print("🔴 [DEBUG] Error message set to: \(self.message)")
            }
        }
    }

    /// DynamoDBにユーザープロファイルを作成（API Gateway /users 経由）
    private func createUserProfile(email: String) async throws {
        let requestConfig = NetworkManager.RequestConfig(
            url: apiGatewayUrl,
            method: .POST,
            body: ["email": email]
        )

        struct CreateUserResponse: Codable {
            let message: String
            let userId: String
            let profile: UserProfile?
            let s3Folders: [S3FolderResult]?

            struct UserProfile: Codable {
                let id: String
                let name: String
            }

            struct S3FolderResult: Codable {
                let path: String
                let status: String
                let description: String?
            }
        }

        let response: CreateUserResponse = try await NetworkManager.shared.sendRequest(
            config: requestConfig,
            responseType: CreateUserResponse.self
        )

        print("✅ User profile created in DynamoDB: \(response.userId)")
        if let folders = response.s3Folders {
            print("✅ S3 folders created: \(folders.count) folders")
        }
    }
    
    // MARK: - MFA Methods

    /// MFAチャレンジの処理
    private func handleAuthChallenge(challengeName: String, session: String?, username: String) async {
        await MainActor.run {
            self.mfaSession = session
            self.pendingUsername = username
        }

        switch challengeName {
        case "SOFTWARE_TOKEN_MFA":
            // TOTP MFA認証が必要
            print("🔐 MFA required: SOFTWARE_TOKEN_MFA")
            await MainActor.run {
                self.mfaRequired = true
                self.mfaSetupRequired = false
                self.message = "認証アプリのコードを入力してください"
            }

        case "MFA_SETUP":
            // MFAセットアップが必要（初回）
            print("🔐 MFA setup required")
            await setupMFA()

        case "NEW_PASSWORD_REQUIRED":
            print("🔐 New password required")
            await MainActor.run {
                self.message = ""  // アラートを表示せずシートのみ表示
                self.newPasswordRequired = true
            }

        default:
            await MainActor.run {
                self.message = "追加認証が必要です: \(challengeName)"
            }
        }
    }

    /// 認証成功時の処理
    private func handleAuthenticationSuccess(authResult: CognitoAuthResult, email: String) async {
        self.accessToken = authResult.accessToken
        self.idToken = authResult.idToken
        self.refreshToken = authResult.refreshToken

        // トークンの有効期限を設定（デフォルト1時間、少し余裕を持って50分後に期限切れとする）
        let expiresInSeconds = authResult.expiresIn ?? 3600
        self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresInSeconds - 600))

        // Keychainにトークンを保存
        KeychainHelper.shared.saveTokens(
            accessToken: authResult.accessToken,
            idToken: authResult.idToken,
            refreshToken: authResult.refreshToken,
            userEmail: email,
            expirationDate: self.tokenExpirationDate!
        )

        print("🔐 Tokens saved, expires at: \(self.tokenExpirationDate?.description ?? "unknown")")

        await MainActor.run {
            self.currentUserEmail = email
            self.isSignedIn = true
            self.mfaRequired = false
            self.mfaSetupRequired = false
            self.mfaSession = nil
            self.pendingUsername = nil
            self.message = "ログイン成功！"
        }
    }

    /// 新パスワード設定チャレンジに応答（RespondToAuthChallenge API）
    func respondToNewPasswordChallenge(newPassword: String) async {
        guard let session = mfaSession, let username = pendingUsername else {
            await MainActor.run {
                self.message = "セッションが無効です。再度ログインしてください。"
                self.newPasswordRequired = false
            }
            return
        }

        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "ClientId": config.clientId,
                "ChallengeName": "NEW_PASSWORD_REQUIRED",
                "Session": session,
                "ChallengeResponses": [
                    "USERNAME": username,
                    "NEW_PASSWORD": newPassword
                ]
            ] as [String: Any]

            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.RespondToAuthChallenge",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )

            struct RespondToAuthChallengeResponse: Codable {
                let authenticationResult: CognitoAuthResult?
                let challengeName: String?
                let session: String?

                private enum CodingKeys: String, CodingKey {
                    case authenticationResult = "AuthenticationResult"
                    case challengeName = "ChallengeName"
                    case session = "Session"
                }
            }

            let response: RespondToAuthChallengeResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: RespondToAuthChallengeResponse.self
            )

            if let authResult = response.authenticationResult {
                // 認証成功
                print("✅ New password set successfully")
                await handleAuthenticationSuccess(authResult: authResult, email: username)
                await MainActor.run {
                    self.newPasswordRequired = false
                }
            } else if let challengeName = response.challengeName {
                // 追加のチャレンジが必要（MFA等）
                await MainActor.run {
                    self.mfaSession = response.session
                    self.newPasswordRequired = false
                }
                await handleAuthChallenge(
                    challengeName: challengeName,
                    session: response.session,
                    username: username
                )
            } else {
                await MainActor.run {
                    self.message = "パスワード設定に失敗しました"
                    self.newPasswordRequired = false
                }
            }

        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.respondToNewPasswordChallenge")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }

    /// MFAセットアップ開始（AssociateSoftwareToken API）
    func setupMFA() async {
        guard let session = mfaSession else {
            await MainActor.run {
                self.message = "セッションが無効です。再度ログインしてください。"
            }
            return
        }

        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "Session": session
            ] as [String: Any]

            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.AssociateSoftwareToken",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )

            struct AssociateSoftwareTokenResponse: Codable {
                let secretCode: String
                let session: String?

                private enum CodingKeys: String, CodingKey {
                    case secretCode = "SecretCode"
                    case session = "Session"
                }
            }

            let response: AssociateSoftwareTokenResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: AssociateSoftwareTokenResponse.self
            )

            print("🔐 MFA secret code received")

            await MainActor.run {
                self.mfaSecretCode = response.secretCode
                self.mfaSession = response.session
                self.mfaSetupRequired = true
                self.mfaRequired = false
                self.message = "認証アプリでQRコードをスキャンしてください"
            }

        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.setupMFA")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }

    /// MFAセットアップ検証（VerifySoftwareToken API）
    func verifyMFASetup(totpCode: String) async {
        guard let session = mfaSession else {
            await MainActor.run {
                self.message = "セッションが無効です。再度ログインしてください。"
            }
            return
        }

        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "Session": session,
                "UserCode": totpCode,
                "FriendlyDeviceName": "TUUN iOS App"
            ] as [String: Any]

            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.VerifySoftwareToken",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )

            struct VerifySoftwareTokenResponse: Codable {
                let status: String
                let session: String?

                private enum CodingKeys: String, CodingKey {
                    case status = "Status"
                    case session = "Session"
                }
            }

            let response: VerifySoftwareTokenResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: VerifySoftwareTokenResponse.self
            )

            if response.status == "SUCCESS" {
                print("🔐 MFA setup verified successfully")

                // セッションを更新
                await MainActor.run {
                    self.mfaSession = response.session
                }

                // MFA設定完了後、再度ログイン処理（RespondToAuthChallenge）
                await respondToMFASetupChallenge()
            } else {
                await MainActor.run {
                    self.message = "MFAセットアップに失敗しました: \(response.status)"
                }
            }

        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.verifyMFASetup")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }

    /// MFAセットアップ完了後のチャレンジレスポンス
    private func respondToMFASetupChallenge() async {
        guard let session = mfaSession, let username = pendingUsername else {
            await MainActor.run {
                self.message = "セッションが無効です。再度ログインしてください。"
            }
            return
        }

        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "ClientId": config.clientId,
                "ChallengeName": "MFA_SETUP",
                "Session": session,
                "ChallengeResponses": [
                    "USERNAME": username
                ]
            ] as [String: Any]

            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.RespondToAuthChallenge",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )

            struct RespondToAuthChallengeResponse: Codable {
                let authenticationResult: CognitoAuthResult?
                let challengeName: String?
                let session: String?

                private enum CodingKeys: String, CodingKey {
                    case authenticationResult = "AuthenticationResult"
                    case challengeName = "ChallengeName"
                    case session = "Session"
                }
            }

            let response: RespondToAuthChallengeResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: RespondToAuthChallengeResponse.self
            )

            if let authResult = response.authenticationResult {
                await handleAuthenticationSuccess(authResult: authResult, email: username)
            } else if let challengeName = response.challengeName {
                await handleAuthChallenge(
                    challengeName: challengeName,
                    session: response.session,
                    username: username
                )
            } else {
                await MainActor.run {
                    self.message = "MFAセットアップ完了。再度ログインしてください。"
                    self.mfaSetupRequired = false
                    self.mfaRequired = false
                }
            }

        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.respondToMFASetupChallenge")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }

    /// MFA認証（RespondToAuthChallenge API - SOFTWARE_TOKEN_MFA）
    func verifyMFA(totpCode: String) async {
        guard let session = mfaSession, let username = pendingUsername else {
            await MainActor.run {
                self.message = "セッションが無効です。再度ログインしてください。"
            }
            return
        }

        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"

            let requestBody = [
                "ClientId": config.clientId,
                "ChallengeName": "SOFTWARE_TOKEN_MFA",
                "Session": session,
                "ChallengeResponses": [
                    "USERNAME": username,
                    "SOFTWARE_TOKEN_MFA_CODE": totpCode
                ]
            ] as [String: Any]

            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.RespondToAuthChallenge",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )

            struct RespondToAuthChallengeResponse: Codable {
                let authenticationResult: CognitoAuthResult?
                let challengeName: String?
                let session: String?

                private enum CodingKeys: String, CodingKey {
                    case authenticationResult = "AuthenticationResult"
                    case challengeName = "ChallengeName"
                    case session = "Session"
                }
            }

            let response: RespondToAuthChallengeResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: RespondToAuthChallengeResponse.self
            )

            if let authResult = response.authenticationResult {
                await handleAuthenticationSuccess(authResult: authResult, email: username)
            } else if let challengeName = response.challengeName {
                await handleAuthChallenge(
                    challengeName: challengeName,
                    session: response.session,
                    username: username
                )
            } else {
                await MainActor.run {
                    self.message = "MFA認証に失敗しました"
                }
            }

        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.verifyMFA")

            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
    }

    /// MFA状態をリセット
    func resetMFAState() {
        mfaRequired = false
        mfaSetupRequired = false
        mfaSecretCode = nil
        mfaSession = nil
        pendingUsername = nil
        message = ""
    }

    /// ログアウト
    func signOut() async {
        // トークンをクリア
        accessToken = nil
        idToken = nil
        refreshToken = nil
        tokenExpirationDate = nil
        
        // Keychainからもトークンを削除
        KeychainHelper.shared.clearAllTokens()
        
        print("🚪 User signed out, all tokens cleared")
        
        await MainActor.run {
            self.isSignedIn = false
            self.currentUserEmail = nil
            self.message = ""
        }
    }
    
    /// IDトークン取得（自動リフレッシュ対応）
    func getIdToken() async -> String? {
        // トークンの有効期限をチェック
        if let expiration = tokenExpirationDate, Date() >= expiration {
            print("🔄 Token expired, attempting refresh...")
            let success = await refreshTokens()
            if !success {
                print("❌ Token refresh failed")
                await signOut() // リフレッシュに失敗した場合はログアウト
                return nil
            }
            print("✅ Token refreshed successfully")
        }
        return idToken
    }
    
    /// アクセストークン取得
    func getAccessToken() async -> String? {
        return accessToken
    }
    
    /// トークン更新（AWS Cognito InitiateAuth API - REFRESH_TOKEN_AUTH）
    func refreshTokens() async -> Bool {
        guard let refreshToken = refreshToken else {
            return false
        }
        
        do {
            let cognitoUrl = "https://cognito-idp.\(config.region).amazonaws.com/"
            
            let requestBody = [
                "ClientId": config.clientId,
                "AuthFlow": "REFRESH_TOKEN_AUTH",
                "AuthParameters": [
                    "REFRESH_TOKEN": refreshToken
                ]
            ] as [String: Any]
            
            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )
            
            struct CognitoRefreshResponse: Codable {
                let authenticationResult: AuthenticationResult?
                
                struct AuthenticationResult: Codable {
                    let accessToken: String
                    let idToken: String
                    let expiresIn: Int?
                    let tokenType: String?
                    
                    private enum CodingKeys: String, CodingKey {
                        case accessToken = "AccessToken"
                        case idToken = "IdToken"
                        case expiresIn = "ExpiresIn"
                        case tokenType = "TokenType"
                    }
                }
                
                private enum CodingKeys: String, CodingKey {
                    case authenticationResult = "AuthenticationResult"
                }
            }
            
            let response: CognitoRefreshResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: CognitoRefreshResponse.self
            )
            
            if let authResult = response.authenticationResult {
                self.accessToken = authResult.accessToken
                self.idToken = authResult.idToken
                // refreshTokenは通常、リフレッシュ時には変更されないので既存のものを保持
                
                // リフレッシュ後の有効期限を更新
                let expiresInSeconds = authResult.expiresIn ?? 3600
                self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresInSeconds - 600))
                
                // Keychainの情報も更新
                if let userEmail = currentUserEmail {
                    KeychainHelper.shared.saveTokens(
                        accessToken: authResult.accessToken,
                        idToken: authResult.idToken,
                        refreshToken: self.refreshToken, // 既存のリフレッシュトークンを使用
                        userEmail: userEmail,
                        expirationDate: self.tokenExpirationDate!
                    )
                }
                
                print("🔄 Tokens refreshed, new expiration: \(self.tokenExpirationDate?.description ?? "unknown")")
                return true
            } else {
                return false
            }
            
        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.refreshTokens")
            return false
        }
    }
    
    // MARK: - Token Persistence
    
    /// Keychainから保存済みトークンを読み込み
    private func loadStoredTokens() {
        guard KeychainHelper.shared.hasValidTokens() else {
            print("🔍 No valid stored tokens found")
            return
        }
        
        accessToken = KeychainHelper.shared.getAccessToken()
        idToken = KeychainHelper.shared.getIdToken()
        refreshToken = KeychainHelper.shared.getRefreshToken()
        tokenExpirationDate = KeychainHelper.shared.getTokenExpirationDate()
        
        if let email = KeychainHelper.shared.getUserEmail() {
            DispatchQueue.main.async {
                self.currentUserEmail = email
                self.isSignedIn = true
                self.message = "自動ログインしました"
            }
            print("🔄 Auto-login successful for user: \(email)")
        }
    }
    
    /// 手動でトークンをリロード（デバッグ用）
    func reloadStoredTokens() {
        loadStoredTokens()
    }
}

// MARK: - Cognito Response Types

/// Cognito認証結果（共通型）
struct CognitoAuthResult: Codable {
    let accessToken: String
    let idToken: String
    let refreshToken: String?
    let expiresIn: Int?
    let tokenType: String?

    private enum CodingKeys: String, CodingKey {
        case accessToken = "AccessToken"
        case idToken = "IdToken"
        case refreshToken = "RefreshToken"
        case expiresIn = "ExpiresIn"
        case tokenType = "TokenType"
    }
}
