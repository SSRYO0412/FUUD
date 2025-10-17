//
//  ChatService.swift
//  AWStest
//
//  Created by nao omiya on 2025/08/18.
//

import Foundation

/// AIチャットサービス
class ChatService {
    static let shared = ChatService()
    
    // API Gateway のエンドポイント（Cognitoオーソライザー付き）
    private var chatEndpoint: String {
        ConfigurationManager.shared.apiEndpoints.chat
    }
    
    private init() {}
    
    /// チャットメッセージを送信
    /// - Parameters:
    ///   - message: ユーザーのメッセージ
    ///   - topic: トピック（nutrition, exercise, lifestyle, general_health）
    /// - Returns: AIからの応答
    func sendMessage(_ message: String, topic: String = "general_health") async throws -> String {
        // 現在のユーザーメールを取得
        guard let userEmail = SimpleCognitoService.shared.currentUserEmail else {
            throw AppError.userNotFound
        }
        
        // リクエスト設定
        let requestConfig = NetworkManager.RequestConfig(
            url: chatEndpoint,
            method: .POST,
            body: [
                "userId": userEmail,
                "message": message,
                "topic": topic
            ],
            requiresAuth: true
        )
        
        // リクエスト送信
        let response: ChatResponse = try await NetworkManager.shared.sendRequest(
            config: requestConfig,
            responseType: ChatResponse.self
        )
        
        return response.response
    }
}

// NOTE: ChatError is now handled by the unified AppError system

// MARK: - レスポンスモデル
struct ChatResponse: Codable {
    let response: String
    let timestamp: String
    let disclaimer: String?
}
