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

    /// v8改善版: ユーザー選択式データ送信対応
    /// - Parameters:
    ///   - message: ユーザーのメッセージ
    ///   - topic: トピック
    ///   - conversationHistory: 会話履歴
    ///   - requestedGeneRequests: AIが要求した遺伝子データ（前回の応答から検出）
    ///   - bloodData: 血液データ（ユーザーが選択した場合のみ）
    ///   - vitalData: バイタルデータ/HealthKitデータ（ユーザーが選択した場合のみ）
    ///   - geneData: 遺伝子データ（ユーザーが選択した場合のみ）
    /// - Returns: AIからの応答（ChatResponse構造体、chunksを含む）
    func sendEnhancedMessage(
        _ message: String,
        topic: String = "general_health",
        conversationHistory: [ChatMessage] = [],
        requestedGeneRequests: [GeneRequest] = [],
        bloodData: [[String: Any]]? = nil,
        vitalData: HealthKitData? = nil,
        geneData: [String: Any]? = nil
    ) async throws -> ChatResponse {
        // [DUMMY] デモモード: 固定Q&Aチェック
        if DemoChatData.isEnabled {
            if let demoResponse = DemoChatData.demoQA[message] {
                try await Task.sleep(nanoseconds: 1_500_000_000)
                let sections = demoResponse.components(separatedBy: "\n\n").filter { !$0.isEmpty }
                let fullResponse = sections.joined(separator: "\n\n")
                // デモモードでも chunks 形式で返す（後方互換）
                return ChatResponse(
                    response: fullResponse,
                    chunks: nil,
                    chunked: false,
                    timestamp: ISO8601DateFormatter().string(from: Date()),
                    disclaimer: nil
                )
            }
        }

        // 現在のユーザーメールを取得
        guard let userEmail = SimpleCognitoService.shared.currentUserEmail else {
            throw AppError.userNotFound
        }

        // リクエストボディを構築
        var requestBody: [String: Any] = [
            "userId": userEmail,
            "message": message,
            "topic": topic
        ]

        // 会話履歴を追加
        if !conversationHistory.isEmpty {
            let historyData = conversationHistory.map { msg in
                return [
                    "role": msg.role,
                    "content": msg.content,
                    "timestamp": msg.timestamp
                ]
            }
            requestBody["conversationHistory"] = historyData
            print("💬 Sending conversation history: \(conversationHistory.count) messages")
        }

        // 血液データを送信（ユーザーが選択した場合）
        if let blood = bloodData {
            requestBody["bloodData"] = blood
            print("🩸 Sending blood data: \(blood.count) items")

            // デバッグ: 最初の項目を確認
            if let firstItem = blood.first {
                print("🩸 First blood item keys: \(firstItem.keys.joined(separator: ", "))")
                print("🩸 First blood item sample: \(firstItem)")
            }
        } else {
            print("⚠️ Blood data is nil (not selected or empty)")
        }

        // バイタルデータを送信（ユーザーが選択した場合）
        if let vital = vitalData {
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(vital)
                if let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    requestBody["vitalData"] = dict
                    print("💓 Sending vital data: \(dict.keys.count) keys")
                } else {
                    print("❌ Vital data: Failed to convert to dictionary")
                }
            } catch {
                print("❌ Vital data encoding failed: \(error)")
            }
        }

        // 遺伝子データを送信（ユーザーが選択した場合）
        if let gene = geneData {
            requestBody["geneData"] = gene
            print("🧬 Sending gene data: \(gene.keys.count) keys, type: \(type(of: gene))")
        } else if !requestedGeneRequests.isEmpty {
            // 遺伝子ボタンがOFFでも、AIが要求した遺伝子データがある場合は送信
            // （これは後方互換性のため）
        }

        // AIが要求した遺伝子データがある場合、そのデータを送信
        if !requestedGeneRequests.isEmpty {
            print("🔍 [DEBUG] Processing \(requestedGeneRequests.count) gene request(s)")
            var geneData: [String: Any] = [:]

            for request in requestedGeneRequests {
                print("🔍 [DEBUG] Request - Category: '\(request.category)', Subcategories: \(request.subcategories?.joined(separator: ", ") ?? "nil (list only)")")

                if let subcategories = request.subcategories {
                    // Pattern 1: 小カテゴリー指定 → SNPsデータを送信
                    if let categoryData = GeneDataService.shared.extractCategoryData(
                        categoryName: request.category,
                        subcategories: subcategories
                    ) {
                        geneData[request.category] = categoryData
                        print("✅ Extracted SNPs data for '\(request.category)': \(categoryData.count) subcategories")
                    } else {
                        print("❌ Failed to extract data for '\(request.category)'")
                    }
                } else {
                    // Pattern 2: 大カテゴリーのみ → 小カテゴリーリストのみを送信
                    if let metadata = GeneDataService.shared.extractCategoryMetadata(categoryName: request.category) {
                        geneData[request.category] = metadata
                        print("✅ Extracted metadata for '\(request.category)': \(metadata.count) subcategories")
                    } else {
                        print("❌ Failed to extract metadata for '\(request.category)'")
                    }
                }
            }

            if !geneData.isEmpty {
                requestBody["geneData"] = geneData
                print("🧬 Sending gene data: \(geneData.keys.joined(separator: ", "))")
            } else {
                print("🔍 [DEBUG] No gene data extracted")
            }
        } else {
            print("🔍 [DEBUG] No gene requests")
        }

        // リクエストボディのJSON変換テスト
        print("📦 [DEBUG] Testing JSON serialization...")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            let jsonSize = jsonData.count
            print("✅ JSON serialization successful: \(jsonSize) bytes")

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let preview = jsonString.prefix(200)
                print("📄 JSON preview: \(preview)...")
            }
        } catch {
            print("❌ JSON serialization failed: \(error)")
            print("❌ Request body keys: \(requestBody.keys.joined(separator: ", "))")
            throw error
        }

        // リクエスト設定
        let requestConfig = NetworkManager.RequestConfig(
            url: chatEndpoint,
            method: .POST,
            body: requestBody,
            requiresAuth: true
        )

        // リクエスト送信
        let response: ChatResponse = try await NetworkManager.shared.sendRequest(
            config: requestConfig,
            responseType: ChatResponse.self
        )

        return response
    }

    /// AI応答から遺伝子カテゴリー要求を検出（2段階抽出対応）
    /// - Parameter response: AIの応答メッセージ
    /// - Returns: 要求された遺伝子カテゴリーの配列（GeneRequest構造体）
    func extractRequestedGeneCategories(from response: String) -> [GeneRequest] {
        var requests: [GeneRequest] = []

        print("🔍 [DEBUG] Extracting gene requests from AI response:")
        print("🔍 [DEBUG] Response length: \(response.count) chars")
        print("🔍 [DEBUG] Full response: \(response)")

        // 🧬 マーカーでsplitして各セグメントを処理（同じ行に複数の🧬がある場合に対応）
        let segments = response.components(separatedBy: "🧬").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        print("🔍 [DEBUG] Total segments: \(segments.count)")

        for (index, segment) in segments.enumerated() {
            let trimmed = segment.trimmingCharacters(in: .whitespacesAndNewlines)
            print("🔍 [DEBUG] Processing segment \(index): '\(trimmed)'")

            // Pattern 1: "代謝力 >> インスリン抵抗性, 中性脂肪" （小カテゴリー指定）
            // Pattern 2: "代謝力（Metabolic Power）" （大カテゴリーのみ）
            if trimmed.contains(">>") {
                // Pattern 1: 小カテゴリー指定
                let parts = trimmed.components(separatedBy: ">>")
                guard parts.count >= 2 else {
                    print("⚠️ [WARN] Invalid format: '\(trimmed)'")
                    continue
                }

                let category = parts[0]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "に関する遺伝子情報", with: "")
                    .replacingOccurrences(of: "の遺伝子情報", with: "")
                    .replacingOccurrences(of: "遺伝子情報", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let subcategoriesStr = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let subcategories = subcategoriesStr
                    .replacingOccurrences(of: "、", with: ",")  // 全角カンマを半角カンマに変換
                    .components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                if !category.isEmpty && !subcategories.isEmpty {
                    let request = GeneRequest(category: category, subcategories: subcategories)
                    requests.append(request)
                    print("✅ [Pattern 1] Category: '\(category)', Subcategories: \(subcategories.joined(separator: ", "))")
                }

            } else {
                // Pattern 2: 大カテゴリーのみ（小カテゴリーリスト要求）
                // 最初の改行または文の終わりまでを抽出（複数行にまたがる場合に対応）
                let firstLine = trimmed.components(separatedBy: "\n").first ?? trimmed
                let category = firstLine
                    .replacingOccurrences(of: "に関する遺伝子情報", with: "")
                    .replacingOccurrences(of: "の遺伝子情報", with: "")
                    .replacingOccurrences(of: "遺伝子情報", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !category.isEmpty {
                    let request = GeneRequest(category: category, subcategories: nil)
                    requests.append(request)
                    print("✅ [Pattern 2] Category: '\(category)' (小カテゴリーリストのみ要求)")
                }
            }
        }

        if !requests.isEmpty {
            print("🧬 Detected \(requests.count) gene request(s)")
        } else {
            print("🔍 [DEBUG] No gene requests detected")
        }

        // 利用可能なカテゴリーも表示
        let availableCategories = GeneDataService.shared.availableCategories()
        print("🔍 [DEBUG] Available categories: \(availableCategories.joined(separator: ", "))")

        return requests
    }

    /// AI応答から選択式質問を検出（v8: 柔軟化版）
    /// 対応マーカー: 【選択】【選択肢】[選択][選択肢]
    /// 対応番号: 1️⃣ ① 1. １. 1) １)
    /// - Parameter response: AIの応答メッセージ
    /// - Returns: 選択式質問（検出できなかった場合はnil）
    func extractQuestionMessage(from response: String) -> QuestionMessage? {
        // 柔軟なマーカー検出
        let markers = ["【選択】", "【選択肢】", "[選択]", "[選択肢]"]
        guard markers.contains(where: { response.contains($0) }) else { return nil }

        print("🔍 [DEBUG] Extracting question message from response (flexible mode)")

        let lines = response.components(separatedBy: "\n")
        var question = ""
        var options: [QuestionOption] = []
        var inQuestionSection = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // マーカーを検出
            var foundMarker: String? = nil
            for marker in markers {
                if trimmed.hasPrefix(marker) {
                    foundMarker = marker
                    break
                }
            }

            if let marker = foundMarker {
                question = trimmed.replacingOccurrences(of: marker, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                inQuestionSection = true
                print("✅ Found question with marker '\(marker)': '\(question)'")
                continue
            }

            // 選択肢を検出（柔軟な番号形式対応）
            if inQuestionSection && !trimmed.isEmpty {
                // 柔軟な番号パターン: 1️⃣, ①, 1., １., 1), １) (1〜5対応)
                let pattern = #"^([1-5]️⃣|[①②③④⑤]|[1-5１-５][.．\)])\s*(.+)$"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed)) {

                    if let numberRange = Range(match.range(at: 1), in: trimmed),
                       let textRange = Range(match.range(at: 2), in: trimmed) {
                        let numberStr = String(trimmed[numberRange])
                        let text = String(trimmed[textRange])
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        // 番号を絵文字形式に統一
                        let emoji = normalizeNumberToEmoji(numberStr)
                        options.append(QuestionOption(emoji: emoji, text: text))
                        print("✅ Found option: \(emoji) \(text)")
                    }
                }
            }
        }

        guard !question.isEmpty, !options.isEmpty else {
            print("❌ Failed to extract question or options")
            return nil
        }

        print("✅ Successfully extracted question with \(options.count) options")
        return QuestionMessage(question: question, options: options)
    }

    /// 様々な番号形式を絵文字番号に統一
    /// - Parameter numberStr: 番号文字列（1️⃣, ①, 1., １., 1), １) など）
    /// - Returns: 絵文字番号（1️⃣, 2️⃣, 3️⃣, 4️⃣, 5️⃣）
    private func normalizeNumberToEmoji(_ numberStr: String) -> String {
        // 絵文字番号マッピング（1〜5対応）
        let emojiMap: [String: String] = [
            "1️⃣": "1️⃣", "2️⃣": "2️⃣", "3️⃣": "3️⃣", "4️⃣": "4️⃣", "5️⃣": "5️⃣",
            "①": "1️⃣", "②": "2️⃣", "③": "3️⃣", "④": "4️⃣", "⑤": "5️⃣",
            "1.": "1️⃣", "2.": "2️⃣", "3.": "3️⃣", "4.": "4️⃣", "5.": "5️⃣",
            "１.": "1️⃣", "２.": "2️⃣", "３.": "3️⃣", "４.": "4️⃣", "５.": "5️⃣",
            "１．": "1️⃣", "２．": "2️⃣", "３．": "3️⃣", "４．": "4️⃣", "５．": "5️⃣",
            "1)": "1️⃣", "2)": "2️⃣", "3)": "3️⃣", "4)": "4️⃣", "5)": "5️⃣",
            "１)": "1️⃣", "２)": "2️⃣", "３)": "3️⃣", "４)": "4️⃣", "５)": "5️⃣"
        ]

        return emojiMap[numberStr] ?? numberStr
    }
}

// NOTE: ChatError is now handled by the unified AppError system

// MARK: - レスポンスモデル
struct ChatResponse: Codable {
    let response: String
    let chunks: [String]?    // Phase 4: 【1/3】【2/3】【3/3】形式で分割されたチャンク
    let chunked: Bool?       // チャンク分割の有無
    let timestamp: String
    let disclaimer: String?
}

// MARK: - 会話履歴モデル
struct ChatMessage: Codable {
    let role: String      // "user" or "assistant"
    let content: String   // メッセージ内容
    let timestamp: String // ISO8601形式のタイムスタンプ
}

// MARK: - 遺伝子データ要求モデル（2段階抽出対応）
struct GeneRequest {
    let category: String           // 大カテゴリー名（例: "代謝力（Metabolic Power）"）
    let subcategories: [String]?   // 小カテゴリー名配列、nilの場合は小カテゴリーリストのみ要求
}
