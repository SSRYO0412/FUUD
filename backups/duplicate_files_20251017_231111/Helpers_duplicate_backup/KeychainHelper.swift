//
//  KeychainHelper.swift
//  AWStest
//
//  Keychainを使った安全なデータ保存ヘルパー
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let service = "com.tuun.awstest"
    
    private init() {}
    
    // MARK: - Save Methods
    
    /// データをKeychainに保存
    /// - Parameters:
    ///   - data: 保存するデータ
    ///   - account: アカウント識別子
    /// - Returns: 保存成功時はtrue
    @discardableResult
    func save(data: Data, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // 既存のアイテムを削除
        SecItemDelete(query as CFDictionary)
        
        // 新しいアイテムを追加
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 文字列をKeychainに保存
    /// - Parameters:
    ///   - string: 保存する文字列
    ///   - account: アカウント識別子
    /// - Returns: 保存成功時はtrue
    @discardableResult
    func save(string: String, account: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data: data, account: account)
    }
    
    // MARK: - Read Methods
    
    /// Keychainからデータを取得
    /// - Parameter account: アカウント識別子
    /// - Returns: 取得したデータ
    func read(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    /// Keychainから文字列を取得
    /// - Parameter account: アカウント識別子
    /// - Returns: 取得した文字列
    func readString(account: String) -> String? {
        guard let data = read(account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Delete Methods
    
    /// Keychainからデータを削除
    /// - Parameter account: アカウント識別子
    /// - Returns: 削除成功時はtrue
    @discardableResult
    func delete(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// 全てのKeychainデータを削除
    @discardableResult
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Token Management

extension KeychainHelper {
    private enum TokenKey {
        static let accessToken = "access_token"
        static let idToken = "id_token"
        static let refreshToken = "refresh_token"
        static let userEmail = "user_email"
        static let tokenExpiration = "token_expiration"
    }
    
    // MARK: - Token Save Methods
    
    func saveTokens(accessToken: String, idToken: String, refreshToken: String?, userEmail: String, expirationDate: Date) {
        save(string: accessToken, account: TokenKey.accessToken)
        save(string: idToken, account: TokenKey.idToken)
        save(string: userEmail, account: TokenKey.userEmail)
        
        if let refreshToken = refreshToken {
            save(string: refreshToken, account: TokenKey.refreshToken)
        }
        
        let expirationTimestamp = String(expirationDate.timeIntervalSince1970)
        save(string: expirationTimestamp, account: TokenKey.tokenExpiration)
        
        print("🔐 Tokens saved to Keychain for user: \(userEmail)")
    }
    
    // MARK: - Token Read Methods
    
    func getAccessToken() -> String? {
        return readString(account: TokenKey.accessToken)
    }
    
    func getIdToken() -> String? {
        return readString(account: TokenKey.idToken)
    }
    
    func getRefreshToken() -> String? {
        return readString(account: TokenKey.refreshToken)
    }
    
    func getUserEmail() -> String? {
        return readString(account: TokenKey.userEmail)
    }
    
    func getTokenExpirationDate() -> Date? {
        guard let timestampString = readString(account: TokenKey.tokenExpiration),
              let timestamp = Double(timestampString) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    // MARK: - Token Delete Methods
    
    func clearAllTokens() {
        delete(account: TokenKey.accessToken)
        delete(account: TokenKey.idToken)
        delete(account: TokenKey.refreshToken)
        delete(account: TokenKey.userEmail)
        delete(account: TokenKey.tokenExpiration)
        
        print("🗑️ All tokens cleared from Keychain")
    }
    
    // MARK: - Token Validation
    
    func hasValidTokens() -> Bool {
        guard let _ = getAccessToken(),
              let _ = getIdToken(),
              let _ = getRefreshToken(),
              let _ = getUserEmail() else {
            return false
        }
        return true
    }
}