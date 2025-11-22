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
    
    // MARK: - Private Properties
    private var accessToken: String?
    private var idToken: String?
    private var refreshToken: String?
    private var tokenExpirationDate: Date?
    
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
            
            let requestConfig = NetworkManager.RequestConfig(
                url: cognitoUrl,
                method: .POST,
                body: requestBody,
                requiresAWSSignature: true,
                customHeaders: [
                    "X-Amz-Target": "AWSCognitoIdentityProviderService.SignUp",
                    "Content-Type": "application/x-amz-json-1.1"
                ]
            )
            
            struct CognitoSignUpResponse: Codable {
                let userSub: String
                let codeDeliveryDetails: CodeDeliveryDetails?
                
                struct CodeDeliveryDetails: Codable {
                    let destination: String
                    let deliveryMedium: String
                    let attributeName: String
                    
                    private enum CodingKeys: String, CodingKey {
                        case destination = "Destination"
                        case deliveryMedium = "DeliveryMedium"
                        case attributeName = "AttributeName"
                    }
                }
                
                private enum CodingKeys: String, CodingKey {
                    case userSub = "UserSub"
                    case codeDeliveryDetails = "CodeDeliveryDetails"
                }
            }
            
            let response: CognitoSignUpResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: CognitoSignUpResponse.self
            )
            
            await MainActor.run {
                self.message = "アカウントが作成されました。確認コードがメールに送信されました。"
            }
            
        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "SimpleCognitoService.signUp")
            
            await MainActor.run {
                self.message = ErrorManager.shared.userFriendlyMessage(for: appError)
            }
        }
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
                let authenticationResult: AuthenticationResult?
                let challengeName: String?
                let session: String?
                
                struct AuthenticationResult: Codable {
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
                    self.message = "ログイン成功！"
                }
            } else if let challengeName = response.challengeName {
                // チャレンジが必要
                await MainActor.run {
                    self.message = "追加認証が必要です: \(challengeName)"
                }
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
