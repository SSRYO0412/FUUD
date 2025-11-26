//
//  ChatView.swift
//  AWStest
//
//  AI相談チャット - iOS 26 Liquid Glass Design
//

import SwiftUI

struct ChatView: View {
    @State private var message = ""
    @State private var chatHistory: [ChatMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTopic = "general_health"
    @State private var requestedGeneRequests: [GeneRequest] = [] // AIが要求した遺伝子データ（2段階抽出対応）

    // キーボード制御
    @FocusState private var isInputFocused: Bool

    // データ選択ボタンの状態（永続化）
    @AppStorage("isBloodDataSelected") private var isBloodDataSelected = false
    @AppStorage("isGeneDataSelected") private var isGeneDataSelected = false
    @AppStorage("isVitalDataSelected") private var isVitalDataSelected = false

    // 遺伝子データ蓄積（会話全体で永続化）
    @State private var accumulatedGeneData: [String: Any] = [:]

    // データ可用性の状態
    @State private var bloodDataAvailability: DataAvailability = .unknown
    @State private var geneDataAvailability: DataAvailability = .unknown
    @State private var vitalDataAvailability: DataAvailability = .unknown

    // トースト表示
    @State private var showSendToast = false
    @State private var sendToastMessage = ""

    // デバッグ情報表示（TestFlight用）
    @State private var showDebugInfo = false  // デフォルトで折りたたみ
    @State private var debugInfo = ""

    // クイックリプライボタン
    @State private var quickReplyOptions: [String] = []

    let topics = [
        ("general_health", "一般的な健康"),
        ("nutrition", "栄養"),
        ("exercise", "運動"),
        ("lifestyle", "ライフスタイル")
    ]

    var body: some View {
        ZStack {
            // Background
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // トピック選択（カスタムタブ風）
                TopicSelector(topics: topics, selectedTopic: $selectedTopic)
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.sm)


                // チャット履歴
                ScrollView {
                    VStack(spacing: VirgilSpacing.md) {
                        ForEach(Array(chatHistory.enumerated()), id: \.offset) { index, chat in
                            if chat.role == "user" {
                                HStack {
                                    Spacer(minLength: 50)
                                    UserMessageBubble(content: chat.content)
                                }
                            } else {
                                HStack {
                                    // 選択式質問を検出してボタン表示
                                    if let questionMsg = ChatService.shared.extractQuestionMessage(from: chat.content) {
                                        QuestionButtons(question: questionMsg) { selectedText in
                                            message = selectedText
                                            sendMessage()
                                        }
                                    } else {
                                        AIMessageBubble(content: chat.content)
                                    }
                                    Spacer(minLength: 50)
                                }
                            }
                        }

                        // タイピングインジケーター
                        if isLoading {
                            HStack {
                                TypingIndicator()
                                Spacer(minLength: 50)
                            }
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.md)
                }

                // エラーメッセージ
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "ED1C24"))
                        .padding(VirgilSpacing.sm)
                        .liquidGlassCard()
                        .padding(.horizontal, VirgilSpacing.md)
                }

                // デバッグ情報パネル（TestFlight用）- 非表示
                // if !debugInfo.isEmpty { ... }

                // コンテキストバー（選択中のデータを表示）
                if isBloodDataSelected || isGeneDataSelected || isVitalDataSelected {
                    ContextBar(
                        isBloodDataSelected: isBloodDataSelected,
                        isGeneDataSelected: isGeneDataSelected,
                        isVitalDataSelected: isVitalDataSelected,
                        bloodDataCount: BloodTestService.shared.extractBloodDataForChat()?.count ?? 0,
                        geneDataStatus: GeneDataService.shared.geneData?.geneDataStatus.displayText
                    )
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.bottom, VirgilSpacing.xs)
                }

                // データ選択ボタン
                DataSelectionButtons(
                    isBloodDataSelected: $isBloodDataSelected,
                    isGeneDataSelected: $isGeneDataSelected,
                    isVitalDataSelected: $isVitalDataSelected,
                    bloodDataAvailability: bloodDataAvailability,
                    geneDataAvailability: geneDataAvailability,
                    vitalDataAvailability: vitalDataAvailability,
                    onBloodTapped: { handleBloodDataToggle() },
                    onGeneTapped: { handleGeneDataToggle() },
                    onVitalTapped: { handleVitalDataToggle() }
                )
                .padding(.horizontal, VirgilSpacing.md)
                .padding(.bottom, VirgilSpacing.xs)

                // クイックリプライボタン
                if !quickReplyOptions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: VirgilSpacing.xs) {
                            ForEach(Array(quickReplyOptions.enumerated()), id: \.offset) { index, option in
                                Button(action: {
                                    message = option
                                    sendMessage()
                                    quickReplyOptions = [] // 選択後はクリア
                                }) {
                                    HStack(spacing: 4) {
                                        Text("\(index + 1)️⃣")
                                            .font(.system(size: 14))
                                        Text(option)
                                            .font(.system(size: 13, weight: .medium))
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, VirgilSpacing.sm)
                                    .padding(.vertical, VirgilSpacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: VirgilSpacing.radiusSmall)
                                            .fill(Color(hex: "0088CC").opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: VirgilSpacing.radiusSmall)
                                            .stroke(Color(hex: "0088CC").opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, VirgilSpacing.md)
                    }
                    .padding(.bottom, VirgilSpacing.xs)
                }

                // 入力フィールド
                ChatInputField(
                    message: $message,
                    isLoading: isLoading,
                    onSend: sendMessage,
                    isFocused: $isInputFocused
                )
                .padding(.horizontal, VirgilSpacing.md)
                .padding(.bottom, VirgilSpacing.md)
            }
        }
        .navigationTitle("TUUN.ai")
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture {
            // キーボード外タップで非表示
            isInputFocused = false
        }
        .onAppear {
            // 遺伝子データを事前にロード
            Task {
                if GeneDataService.shared.geneData == nil {
                    await GeneDataService.shared.fetchGeneData()
                }
                // データ可用性をチェック
                checkDataAvailability()
            }
        }
        .overlay(
            // 送信トースト
            VStack {
                if showSendToast {
                    SendToast(message: sendToastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 60)
                }
                Spacer()
            }
        )
    }

    // MARK: - Data Availability Checking

    /// すべてのデータの可用性をチェック
    private func checkDataAvailability() {
        // 血液データ
        if let bloodData = BloodTestService.shared.extractBloodDataForChat(), !bloodData.isEmpty {
            bloodDataAvailability = .available
        } else {
            bloodDataAvailability = .unavailable
        }

        // 遺伝子データ
        let availableCategories = GeneDataService.shared.availableCategories()
        if !availableCategories.isEmpty || !accumulatedGeneData.isEmpty {
            geneDataAvailability = .available
        } else {
            geneDataAvailability = .unavailable
        }

        // バイタルデータ
        if HealthKitService.shared.healthData != nil {
            vitalDataAvailability = .available
        } else {
            vitalDataAvailability = .unavailable
        }

        print("📊 Data availability: Blood=\(bloodDataAvailability), Gene=\(geneDataAvailability), Vital=\(vitalDataAvailability)")
    }

    // MARK: - Data Toggle Handlers

    /// 血液データボタンのタップ処理
    private func handleBloodDataToggle() {
        // ボタンがOFFになる場合は何もしない
        if isBloodDataSelected {
            isBloodDataSelected = false
            return
        }

        // データが利用可能な場合はそのままON
        if bloodDataAvailability == .available {
            isBloodDataSelected = true
            return
        }

        // データが利用不可の場合は自動取得を試みる
        bloodDataAvailability = .loading
        Task {
            await BloodTestService.shared.fetchBloodTestData()
            await MainActor.run {
                checkDataAvailability()

                if bloodDataAvailability == .available {
                    isBloodDataSelected = true
                    print("✅ Blood data loaded successfully")
                } else {
                    errorMessage = "血液データが見つかりません。「データ」タブで血液検査結果を登録してください。"
                    print("❌ Blood data still unavailable after fetch")
                }
            }
        }
    }

    /// 遺伝子データボタンのタップ処理
    private func handleGeneDataToggle() {
        if isGeneDataSelected {
            isGeneDataSelected = false
            return
        }

        if geneDataAvailability == .available {
            // データの詳細ステータスを取得して警告を表示
            if let geneData = GeneDataService.shared.geneData {
                let status = geneData.geneDataStatus
                switch status {
                case .categoryOnly:
                    errorMessage = "⚠️ 遺伝子データ: カテゴリ情報のみ（SNPsなし）\nAIには利用可能なカテゴリーリストのみが送信されます。"
                    print("⚠️ Gene data: Category only (no SNPs)")
                case .partial(let count):
                    errorMessage = "⚠️ 遺伝子データ: 一部データのみ（\(count)個のSNP）\n品質スコア: \(String(format: "%.1f", geneData.dataQualityScore * 100))%"
                    print("⚠️ Gene data: Partial data (\(count) SNPs)")
                case .complete:
                    print("✅ Gene data: Complete")
                }
            }
            isGeneDataSelected = true
            return
        }

        // 遺伝子データの自動取得を試みる
        geneDataAvailability = .loading
        Task {
            await GeneDataService.shared.fetchGeneData()
            await MainActor.run {
                checkDataAvailability()

                if geneDataAvailability == .available {
                    // データの詳細ステータスを取得して警告を表示
                    if let geneData = GeneDataService.shared.geneData {
                        let status = geneData.geneDataStatus
                        switch status {
                        case .categoryOnly:
                            errorMessage = "⚠️ 遺伝子データ: カテゴリ情報のみ（SNPsなし）\nAIには利用可能なカテゴリーリストのみが送信されます。"
                        case .partial(let count):
                            errorMessage = "⚠️ 遺伝子データ: 一部データのみ（\(count)個のSNP）\n品質スコア: \(String(format: "%.1f", geneData.dataQualityScore * 100))%"
                        case .complete:
                            break
                        }
                    }
                    isGeneDataSelected = true
                    print("✅ Gene data loaded successfully")
                } else {
                    errorMessage = "遺伝子データが見つかりません。「データ」タブで遺伝子データを登録してください。"
                    print("❌ Gene data still unavailable after fetch")
                }
            }
        }
    }

    /// バイタルデータボタンのタップ処理
    private func handleVitalDataToggle() {
        if isVitalDataSelected {
            isVitalDataSelected = false
            return
        }

        if vitalDataAvailability == .available {
            isVitalDataSelected = true
            return
        }

        // バイタルデータの自動取得を試みる
        vitalDataAvailability = .loading
        Task {
            await HealthKitService.shared.fetchAllHealthData()
            await MainActor.run {
                checkDataAvailability()

                if vitalDataAvailability == .available {
                    isVitalDataSelected = true
                    print("✅ Vital data loaded successfully")
                } else {
                    errorMessage = "バイタルデータが見つかりません。HealthKitの許可を確認してください。"
                    print("❌ Vital data still unavailable after fetch")
                }
            }
        }
    }

    // MARK: - Quick Reply Extraction

    /// 最後のAIメッセージから選択肢を抽出
    private func extractQuickReplyOptions() {
        guard let lastMessage = chatHistory.last(where: { $0.role == "assistant" }) else {
            quickReplyOptions = []
            return
        }

        let content = lastMessage.content
        var options: [String] = []

        // 1️⃣ 2️⃣ 3️⃣ 4️⃣ パターンを検出
        let emojiPattern = "([1-4])️⃣\\s*(.+?)(?=\\n|[1-4]️⃣|$)"
        if let regex = try? NSRegularExpression(pattern: emojiPattern, options: []) {
            let nsString = content as NSString
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length))

            for match in matches {
                if match.numberOfRanges >= 3 {
                    let optionText = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !optionText.isEmpty {
                        options.append(optionText)
                    }
                }
            }
        }

        quickReplyOptions = options
        print("🔘 Quick reply options extracted: \(options.count) options")
    }

    private func sendMessage() {
        // キーボードを非表示
        isInputFocused = false

        let userMessage = message
        message = ""
        errorMessage = nil
        isLoading = true

        Task {
            do {
                // データを準備（ボタンの状態に基づいて）
                let bloodData: [[String: Any]]? = isBloodDataSelected ? BloodTestService.shared.extractBloodDataForChat() : nil
                let vitalData: HealthKitData? = isVitalDataSelected ? HealthKitService.shared.healthData : nil

                // デバッグ情報を構築
                var debugLines: [String] = []
                debugLines.append("📤 送信データ:")
                debugLines.append("血液: ボタン=\(isBloodDataSelected ? "ON" : "OFF"), データ=\(bloodData != nil ? "あり(\(bloodData?.count ?? 0)項目)" : "なし")")

                // 遺伝子データの詳細ステータスを表示
                if isGeneDataSelected {
                    if let geneData = GeneDataService.shared.geneData {
                        let status = geneData.geneDataStatus
                        debugLines.append("遺伝子: ボタン=ON, ステータス=\(status.displayText)")
                        debugLines.append("  カテゴリ数: \(geneData.categories.count)")
                        debugLines.append("  マーカー数: \(geneData.totalMarkers)")
                        debugLines.append("  総SNP数: \(geneData.totalSNPs)")
                        debugLines.append("  品質スコア: \(String(format: "%.1f", geneData.dataQualityScore * 100))%")
                    } else {
                        debugLines.append("遺伝子: ボタン=ON, データ=なし（カテゴリリストのみ送信）")
                    }
                } else {
                    debugLines.append("遺伝子: ボタン=OFF")
                }

                debugLines.append("バイタル: ボタン=\(isVitalDataSelected ? "ON" : "OFF"), データ=\(vitalData != nil ? "あり" : "なし")")

                if let blood = bloodData, let first = blood.first {
                    debugLines.append("\n血液データサンプル:")
                    debugLines.append("  key: \(first["key"] as? String ?? "?")")
                    debugLines.append("  nameJp: \(first["nameJp"] as? String ?? "?")")
                    debugLines.append("  value: \(first["value"] as? String ?? "?")")
                }

                debugInfo = debugLines.joined(separator: "\n")

                print("📤 [DEBUG] Preparing to send:")
                print("   - Blood button ON: \(isBloodDataSelected), Data available: \(bloodData != nil), Items: \(bloodData?.count ?? 0)")
                print("   - Gene button ON: \(isGeneDataSelected)")
                print("   - Vital button ON: \(isVitalDataSelected), Data available: \(vitalData != nil)")

                // 遺伝子データ: ボタンONの場合、蓄積データを送信
                var geneData: [String: Any]? = nil
                if isGeneDataSelected {
                    // 蓄積データがある場合は送信、なければ利用可能なカテゴリーリスト送信
                    if !accumulatedGeneData.isEmpty {
                        geneData = accumulatedGeneData
                    } else {
                        let availableCategories = GeneDataService.shared.availableCategories()
                        if !availableCategories.isEmpty {
                            geneData = ["availableCategories": availableCategories]
                        } else {
                            // 遺伝子データがロードされていない場合は警告のみ表示し、処理を続ける
                            print("⚠️ 遺伝子データがまだロードされていません。遺伝子データなしで送信します。")
                            // geneData = nil のまま（遺伝子データなしで送信）
                        }
                    }
                }

                // ✅ ユーザーメッセージを即座に表示（API呼び出し前）
                let userTimestamp = ISO8601DateFormatter().string(from: Date())
                let userChatMessage = ChatMessage(role: "user", content: userMessage, timestamp: userTimestamp)
                await MainActor.run {
                    chatHistory.append(userChatMessage)
                }

                // v8改善版APIを呼び出し
                let chatResponse = try await ChatService.shared.sendEnhancedMessage(
                    userMessage,
                    topic: selectedTopic,
                    conversationHistory: chatHistory,
                    requestedGeneRequests: requestedGeneRequests,
                    bloodData: bloodData,
                    vitalData: vitalData,
                    geneData: geneData
                )

                await MainActor.run {
                    // Phase 4: chunksがあれば順次表示、なければ従来通り
                    if let chunks = chatResponse.chunks, chunks.count > 1 {
                        // 複数チャンクを順次追加（アニメーション付き）
                        for (index, chunk) in chunks.enumerated() {
                            Task {
                                try? await Task.sleep(nanoseconds: UInt64(index) * 500_000_000) // 0.5秒間隔
                                await MainActor.run {
                                    let chunkTimestamp = ISO8601DateFormatter().string(from: Date())
                                    let chunkMessage = ChatMessage(role: "assistant", content: chunk, timestamp: chunkTimestamp)
                                    chatHistory.append(chunkMessage)
                                }
                            }
                        }
                    } else {
                        // 単一レスポンス（後方互換）
                        let aiTimestamp = ISO8601DateFormatter().string(from: Date())
                        let aiChatMessage = ChatMessage(role: "assistant", content: chatResponse.response, timestamp: aiTimestamp)
                        chatHistory.append(aiChatMessage)
                    }

                    // AI応答から遺伝子データ要求を検出（次回送信用）
                    requestedGeneRequests = ChatService.shared.extractRequestedGeneCategories(from: chatResponse.response)

                    // AI応答からクイックリプライ選択肢を抽出
                    extractQuickReplyOptions()

                    // 遺伝子データを蓄積（requestedGeneRequestsに基づいて）
                    if !requestedGeneRequests.isEmpty {
                        for request in requestedGeneRequests {
                            if let subcategories = request.subcategories {
                                // SNPsデータを抽出
                                if let categoryData = GeneDataService.shared.extractCategoryData(
                                    categoryName: request.category,
                                    subcategories: subcategories
                                ) {
                                    accumulatedGeneData[request.category] = categoryData
                                    print("✅ Accumulated gene data for '\(request.category)'")
                                }
                            }
                        }
                    }

                    // 送信成功トーストを表示
                    var sentDataParts: [String] = []
                    if bloodData != nil { sentDataParts.append("🩸 血液データ: \(bloodData?.count ?? 0)項目") }
                    if vitalData != nil { sentDataParts.append("💓 バイタルデータ") }
                    if geneData != nil { sentDataParts.append("🧬 遺伝子データ") }

                    if !sentDataParts.isEmpty {
                        sendToastMessage = "✅ 送信完了\n" + sentDataParts.joined(separator: "\n")
                        showSendToast = true

                        // トースト非表示とデバッグパネル自動折りたたみを同時実行
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            await MainActor.run {
                                showSendToast = false
                                showDebugInfo = false  // 3秒後に自動折りたたみ
                            }
                        }
                    }

                    // データ可用性を再チェック
                    checkDataAvailability()

                    isLoading = false
                }
            } catch {
                let appError = ErrorManager.shared.convertToAppError(error)
                ErrorManager.shared.logError(appError, context: "ChatView.sendMessage")

                await MainActor.run {
                    errorMessage = ErrorManager.shared.userFriendlyMessage(for: appError)

                    // デバッグ情報にエラー詳細を追加
                    var errorDebug = debugInfo
                    errorDebug += "\n\n❌ エラー発生:"
                    errorDebug += "\n\(error.localizedDescription)"
                    if let urlError = error as? URLError {
                        errorDebug += "\nURLError code: \(urlError.code.rawValue)"
                    }
                    debugInfo = errorDebug

                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Topic Selector

struct TopicSelector: View {
    let topics: [(String, String)]
    @Binding var selectedTopic: String

    var body: some View {
        HStack(spacing: VirgilSpacing.xs) {
            ForEach(topics, id: \.0) { topic in
                Button {
                    selectedTopic = topic.0
                } label: {
                    Text(topic.1)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(selectedTopic == topic.0 ? .white : .virgilTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VirgilSpacing.sm)
                        .background(selectedTopic == topic.0 ? Color.black : Color.clear)
                        .cornerRadius(VirgilSpacing.radiusMedium)
                }
            }
        }
        .padding(VirgilSpacing.xs)
        .background(Color.white.opacity(0.08))
        .cornerRadius(VirgilSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: VirgilSpacing.radiusLarge)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Message Bubbles

struct UserMessageBubble: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.white)
            .padding(VirgilSpacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "0088CC").opacity(0.6))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color.white.opacity(0.3),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }
}

struct AIMessageBubble: View {
    let content: String

    /// タイトル行かどうかを判定（絵文字+**タイトル** または 行頭**タイトル**）
    private func isTitleLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        // パターン1: 絵文字 + **タイトル** (例: 🍽️**今日からのクイックアクション**)
        // パターン2: 行頭が**で始まり**で終わる (例: **あなたの分析**)
        let emojiTitlePattern = "^[\\p{Emoji}]+\\*\\*.+\\*\\*$"
        let boldOnlyPattern = "^\\*\\*.+\\*\\*$"

        return trimmed.range(of: emojiTitlePattern, options: .regularExpression) != nil ||
               trimmed.range(of: boldOnlyPattern, options: .regularExpression) != nil
    }

    /// マークダウンをパースしてAttributedStringを生成
    private func parseMarkdown(_ text: String) -> AttributedString {
        var result = AttributedString()
        let lines = text.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            if isTitleLine(line) {
                // タイトル行: フォントサイズ大きめ + 太字
                let cleanedLine = line
                    .replacingOccurrences(of: "**", with: "")
                var attrLine = AttributedString(cleanedLine)
                attrLine.font = .system(size: 20, weight: .bold)
                result.append(attrLine)
            } else {
                // 通常行: マークダウンパース
                if let parsed = try? AttributedString(
                    markdown: line,
                    options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                ) {
                    result.append(parsed)
                } else {
                    result.append(AttributedString(line))
                }
            }

            // 改行を追加（最後の行以外）
            if index < lines.count - 1 {
                result.append(AttributedString("\n"))
            }
        }

        return result
    }

    var body: some View {
        Text(parseMarkdown(content))
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.virgilTextPrimary)
            .padding(VirgilSpacing.md)
            .liquidGlassCard()
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.virgilTextSecondary)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Chat Input Field

struct ChatInputField: View {
    @Binding var message: String
    let isLoading: Bool
    let onSend: () -> Void
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: VirgilSpacing.sm) {
            inputField
                .padding(VirgilSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.4))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .disabled(isLoading)

            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(message.isEmpty ? Color.gray : Color(hex: "0088CC"))
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(message.isEmpty || isLoading)
        }
    }

    @ViewBuilder
    private var inputField: some View {
        if #available(iOS 16.0, *) {
            TextField("メッセージを入力...", text: $message, axis: .vertical)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .lineLimit(1...10)
                .focused(isFocused)
        } else {
            TextField("メッセージを入力...", text: $message)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .focused(isFocused)
        }
    }
}

// MARK: - Question Buttons

struct QuestionButtons: View {
    let question: QuestionMessage
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // 質問テキスト
            Text(question.question)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.virgilTextPrimary)
                .padding(.bottom, VirgilSpacing.xs)

            // 選択肢ボタン
            ForEach(question.options) { option in
                Button {
                    onSelect(option.text)
                } label: {
                    HStack(spacing: VirgilSpacing.sm) {
                        Text(option.emoji)
                            .font(.system(size: 16))
                        Text(option.text)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.virgilTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11))
                            .foregroundColor(.virgilTextSecondary)
                    }
                    .padding(VirgilSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Data Selection Buttons

struct DataSelectionButtons: View {
    @Binding var isBloodDataSelected: Bool
    @Binding var isGeneDataSelected: Bool
    @Binding var isVitalDataSelected: Bool
    let bloodDataAvailability: DataAvailability
    let geneDataAvailability: DataAvailability
    let vitalDataAvailability: DataAvailability
    let onBloodTapped: () -> Void
    let onGeneTapped: () -> Void
    let onVitalTapped: () -> Void

    var body: some View {
        HStack(spacing: VirgilSpacing.sm) {
            DataButton(
                title: "血液",
                icon: "drop.fill",
                isSelected: isBloodDataSelected,
                availability: bloodDataAvailability,
                onTapped: onBloodTapped
            )

            DataButton(
                title: "遺伝子",
                icon: "dna",
                isSelected: isGeneDataSelected,
                availability: geneDataAvailability,
                onTapped: onGeneTapped
            )

            DataButton(
                title: "バイタル",
                icon: "heart.fill",
                isSelected: isVitalDataSelected,
                availability: vitalDataAvailability,
                onTapped: onVitalTapped
            )
        }
    }
}

struct DataButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let availability: DataAvailability
    let onTapped: () -> Void

    /// 可用性に基づくインジケーターアイコン
    private var statusIcon: String {
        switch availability {
        case .available:
            return "checkmark.circle.fill"
        case .unavailable:
            return "exclamationmark.triangle.fill"
        case .loading:
            return "arrow.clockwise"
        case .unknown:
            return ""
        }
    }

    /// 可用性に基づくインジケーターカラー
    private var statusColor: Color {
        switch availability {
        case .available:
            return Color.green
        case .unavailable:
            return Color.orange
        case .loading:
            return Color.blue
        case .unknown:
            return Color.clear
        }
    }

    var body: some View {
        Button {
            onTapped()
        } label: {
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))

                // ステータスインジケーター
                if availability != .unknown {
                    Image(systemName: statusIcon)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(statusColor)
                }
            }
            .foregroundColor(isSelected ? .white : Color.virgilTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VirgilSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                    .fill(isSelected ? Color(hex: "0088CC") : Color.white.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                    .strokeBorder(
                        isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1),
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "0088CC").opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(availability == .loading)
    }
}

// MARK: - Data Availability

/// データ可用性の状態
enum DataAvailability {
    case unknown      // 未確認
    case available    // 利用可能
    case unavailable  // 利用不可
    case loading      // ロード中
}

// MARK: - Send Toast

/// 送信完了トースト
struct SendToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(VirgilSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
            .padding(.horizontal, VirgilSpacing.md)
    }
}

// MARK: - Context Bar

/// 選択中のデータを表示するコンテキストバー
struct ContextBar: View {
    let isBloodDataSelected: Bool
    let isGeneDataSelected: Bool
    let isVitalDataSelected: Bool
    let bloodDataCount: Int
    let geneDataStatus: String?

    var body: some View {
        HStack(spacing: VirgilSpacing.sm) {
            // アイコン
            Image(systemName: "paperclip")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // 選択中のデータバッジ
            HStack(spacing: VirgilSpacing.xs) {
                if isBloodDataSelected {
                    ContextBadge(
                        icon: "drop.fill",
                        text: "血液 \(bloodDataCount)項目",
                        color: Color(hex: "ED1C24")
                    )
                }

                if isGeneDataSelected {
                    ContextBadge(
                        icon: "dna",
                        text: geneDataStatus ?? "遺伝子",
                        color: Color(hex: "0088CC")
                    )
                }

                if isVitalDataSelected {
                    ContextBadge(
                        icon: "heart.fill",
                        text: "バイタル",
                        color: Color(hex: "FF6B35")
                    )
                }
            }

            Spacer()
        }
        .padding(.horizontal, VirgilSpacing.md)
        .padding(.vertical, VirgilSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}

/// コンテキストバーのバッジ
struct ContextBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .semibold))
            Text(text)
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, VirgilSpacing.xs)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: VirgilSpacing.radiusSmall)
                .fill(color.opacity(0.1))
        )
    }
}
