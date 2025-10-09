//
//  ChatService.swift
//  AWStest
//
//  Created by nao omiya on 2025/08/18.
//

import Foundation

/// デモモード用チャットデータ
struct DemoChatData {
    // [DUMMY] デモ撮影用の固定Q&A。本番では実際のAI APIを使用
    static let demoQA: [String: String] = [
        "ベンチプレスの数値がここ3か月伸び悩んでいてどうすればいい？": """
原因：
ALBとFeの数値が低くなっています。体内のタンパク質合成効率が悪くなっている可能性があります。

アドバイス：
食材：赤身肉、牡蠣
サプリ：Fe（鉄分）

追加の調査：
また、オーバーワークトレーニングの可能性を探るためにCRPの数値も調べますか？
""", // [DUMMY] デモ用固定回答：筋トレ停滞

        "昨日飲みすぎてしまってリカバリー案を考えてほしい。": """
原因：
TGの数値が高めで、さらに空腹時インスリンも高くインスリン抵抗性がある状態です。昨夜の飲酒とラーメンによって、一時的に血糖値とインスリンが強く上がり、中性脂肪がさらに増えていると考えられます。
対処法としては、まず今日から48時間は肝臓と代謝をリセットすることを意識してください。

アドバイス：
可溶性食物繊維を10〜15g/日（オート麦、大麦、サイリウムなど）摂って血糖や中性脂肪の上昇を抑えましょう。
炭水化物は運動前後に寄せて、夜は控えることでインスリンのピークを避けてください。
EPA/DHAを1〜2g/日摂取するとTGを下げやすくなります。
運動はZone2（会話できる強度の有酸素）を40〜60分、2日連続で行ってください。
アルコールは最低72時間控えるのが必須です。
まずは食前ファイバー＋主食は運動前後に限定＋Zone2有酸素＋禁酒72時間これを徹底することが昨夜のダメージを立て直す最優先の行動です。

追加の調査：
また、肝臓への影響をみるためにAST/ALT/γ-GTPを確認しておくと安心です。新規検査を注文しますか？
""", // [DUMMY] デモ用固定回答：飲酒後リカバリー

        "私の遺伝子リスクは何ですか？": "あなたの遺伝子解析の結果、認知機能関連のAPOE遺伝子はε3/ε3型で、アルツハイマー病リスクは低く保護的です。また、運動能力関連のACTN3遺伝子はRR型で、パワー系の運動に適した体質です。", // [DUMMY] デモ用固定回答：遺伝子リスク
    ]

    /// UserDefaultsキー
    private static let demoModeKey = "demo_mode_enabled" // [DUMMY] デモモード設定の保存キー

    /// デモモードが有効かどうか
    static var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: demoModeKey) // [DUMMY] デモモード状態を取得
        }
        set {
            UserDefaults.standard.set(newValue, forKey: demoModeKey) // [DUMMY] デモモード状態を保存
        }
    }
}

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
    /// - Returns: AIからの応答（複数の場合あり）
    func sendMessage(_ message: String, topic: String = "general_health") async throws -> [String] {
        // [DUMMY] デモモード: 固定Q&Aチェック。デモ撮影用の機能
        if DemoChatData.isEnabled {
            if let demoResponse = DemoChatData.demoQA[message] { // [DUMMY] 質問が固定リストに存在するかチェック
                // 実際のAPIっぽく見せるため少し遅延
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒 [DUMMY] API応答を模倣

                // [DUMMY] デモ応答を「原因」「アドバイス」「追加の調査」に分割
                let sections = demoResponse.components(separatedBy: "\n\n").filter { !$0.isEmpty }
                return sections // [DUMMY] 分割した固定回答を返す
            }
        }

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

        return [response.response] // 通常のAPIレスポンスは単一のメッセージとして返す
    }
}

// NOTE: ChatError is now handled by the unified AppError system

// MARK: - レスポンスモデル
struct ChatResponse: Codable {
    let response: String
    let timestamp: String
    let disclaimer: String?
}
