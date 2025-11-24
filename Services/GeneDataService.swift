//
//  GeneDataService.swift
//  AWStest
//
//  遺伝子データ取得サービス
//

import Foundation

/// 遺伝子データ取得サービス
class GeneDataService: ObservableObject {
    static let shared = GeneDataService()
    
    // MARK: - Published Properties
    @Published var geneData: GeneData?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var rawResponseData: String = ""
    
    private init() {}
    
    // MARK: - Data Models
    
    /// 遺伝子データ全体のレスポンス
    struct GeneDataResponse: Codable {
        let success: Bool
        let data: GeneData?
        let error: String?
        let errorCode: String?
        let timestamp: String?
    }
    
    /// 遺伝子データ本体（新仕様 v6.0）
    struct GeneData: Codable, Identifiable {
        let id = UUID()

        // メタ情報
        let version: String
        let userId: String
        let timestamp: String
        let totalGenotypesProcessed: Double
        let dataQualityScore: Double
        let analysisType: String

        // 遺伝子マーカーデータ（6カテゴリー）
        // var に変更（事前計算後の更新を可能にするため）
        var geneticMarkersWithGenotypes: [String: [GeneticMarker]]

        // 統計情報（オプショナル）
        let chromosomePositionLines: Double?
        let invalidLines: Double?
        let headerLines: Double?
        let requestId: String?
        let verificationHash: String?
        let createdAt: String?
        let ttl: Double?

        private enum CodingKeys: String, CodingKey {
            case version, userId, timestamp
            case totalGenotypesProcessed, dataQualityScore, analysisType
            case geneticMarkersWithGenotypes
            case chromosomePositionLines, invalidLines, headerLines
            case requestId, verificationHash, createdAt, ttl
        }
    }

    /// 遺伝子マーカー（各カテゴリー内の個別項目）
    struct GeneticMarker: Codable, Identifiable {
        let id = UUID()
        let title: String              // 例: "テロメアの長さ（細胞老化の指標）"
        let genotypes: [String: String] // 例: {"rs4387287": "CC", "rs3027234": "AG"}

        /// 事前計算済みの影響スコア（パフォーマンス最適化のため）
        /// データ取得時にバックグラウンドで計算され、ビュー描画時の計算を不要にする
        var cachedImpact: SNPImpactCount?

        private enum CodingKeys: String, CodingKey {
            case title, genotypes
        }
    }


}

// MARK: - GeneData Extensions

extension GeneDataService.GeneData {
    /// カテゴリー名の配列を取得（ソート済み）
    var categories: [String] {
        Array(geneticMarkersWithGenotypes.keys).sorted()
    }

    /// 特定カテゴリーのマーカーを取得
    /// - Parameter category: カテゴリー名
    /// - Returns: 該当するマーカーの配列
    func markers(for category: String) -> [GeneDataService.GeneticMarker] {
        geneticMarkersWithGenotypes[category] ?? []
    }

    /// 全マーカー数を取得
    var totalMarkers: Int {
        geneticMarkersWithGenotypes.values.reduce(0) { $0 + $1.count }
    }

    /// フォーマットされた解析日時
    var formattedTimestamp: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            displayFormatter.locale = Locale(identifier: "ja_JP")
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}

// MARK: - GeneticMarker Extensions

extension GeneDataService.GeneticMarker {
    /// SNP（rs番号）の配列を取得（ソート済み）
    var snpIDs: [String] {
        Array(genotypes.keys).sorted()
    }

    /// 特定SNPの遺伝子型を取得
    /// - Parameter snpID: SNP ID（例: "rs4387287"）
    /// - Returns: 遺伝子型（例: "CC"）
    func genotype(for snpID: String) -> String? {
        genotypes[snpID]
    }

    /// SNP数を取得
    var snpCount: Int {
        genotypes.count
    }

    /// SNP影響因子をカウント
    /// - Parameter markerTitle: マーカータイトル（ルール検索用）
    /// - Returns: 影響因子カウント結果
    func calculateImpact(markerTitle: String) -> SNPImpactCount {
        var protective = 0
        var risk = 0
        var neutral = 0

        // マーカータイトルに対応するルールを取得
        let markerRules = SNPEffectRulesDatabase.shared.rules(for: markerTitle)

        for (snpID, genotype) in genotypes {
            // ルールを検索（マーカー特化ルール優先、なければ全体から検索）
            let rule: SNPEffectRule?
            if let markerRules = markerRules {
                rule = markerRules.first(where: { $0.snpID == snpID })
            } else {
                rule = SNPEffectRulesDatabase.shared.findRule(for: snpID)
            }

            // ルールがあれば影響を判定
            if let rule = rule {
                switch rule.impact(for: genotype) {
                case .protective:
                    protective += 1
                case .risk:
                    risk += 1
                case .neutral:
                    neutral += 1
                }
            } else {
                // ルールがない場合は中立としてカウント
                neutral += 1
            }
        }

        return SNPImpactCount(protective: protective, risk: risk, neutral: neutral)
    }
}

// MARK: - GeneDataService

extension GeneDataService {

    // MARK: - API Methods
    
    /// 遺伝子データを取得
    /// - Parameter userId: ユーザーID（メールアドレス）
    func fetchGeneData(for userId: String? = nil) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }
        
        do {
            let userEmail = userId ?? SimpleCognitoService.shared.currentUserEmail ?? ""
            guard !userEmail.isEmpty else {
                throw GeneDataError.userNotFound
            }
            
            let encodedEmail = userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? userEmail
            let endpoint = "https://kxuyul35l4.execute-api.ap-northeast-1.amazonaws.com/prod?userId=\(encodedEmail)"
            
            print("🧬 GeneData API Request: \(endpoint)")
            
            let requestConfig = NetworkManager.RequestConfig(
                url: endpoint,
                method: .GET,
                requiresAuth: true
            )
            
            // まず生のレスポンスをログ出力
            let rawResponse = try await NetworkManager.shared.sendRawRequest(config: requestConfig)
            let rawResponseString = String(data: rawResponse, encoding: .utf8) ?? "Unable to decode"
            print("🧬 GeneData Raw Response: \(rawResponseString)")
            
            // 生レスポンスを保存
            await MainActor.run {
                self.rawResponseData = rawResponseString
            }
            
            let decoder = JSONDecoder()
            let response: GeneDataResponse
            do {
                response = try decoder.decode(GeneDataResponse.self, from: rawResponse)
                print("🧬 GeneData Decoded Successfully: \(response)")
            } catch {
                print("🧬 GeneData Decode Error: \(error)")
                print("🧬 Decoding failed for data: \(String(data: rawResponse, encoding: .utf8) ?? "Unable to decode")")
                throw GeneDataError.invalidData
            }
            
            // データ取得成功後、バックグラウンドで影響スコアを事前計算
            if response.success, var data = response.data {
                print("🧬 GeneData received successfully - 影響スコアを事前計算中...")

                // バックグラウンドで事前計算を実行（UIブロックを防ぐ）
                data = await precalculateImpacts(for: data)

                await MainActor.run {
                    self.geneData = data
                    self.errorMessage = ""
                    self.isLoading = false
                    print("🧬 GeneData 事前計算完了 - ビュー描画準備完了")
                }
            } else {
                await MainActor.run {
                    print("🧬 GeneData failed: \(response.error ?? "Unknown error")")
                    self.errorMessage = response.error ?? "遺伝子データの取得に失敗しました"
                    self.isLoading = false
                }
            }
            
        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "GeneDataService.fetchGeneData")
            
            await MainActor.run {
                self.errorMessage = ErrorManager.shared.userFriendlyMessage(for: appError)
                self.isLoading = false
            }
        }
    }
    
    /// データをリフレッシュ
    func refreshData() async {
        // 強制的にデータをクリアしてから再取得
        await MainActor.run {
            self.geneData = nil
            self.errorMessage = ""
            self.rawResponseData = ""
        }
        await fetchGeneData()
    }

    /// 全マーカーの影響スコアを事前計算（バックグラウンド処理）
    /// - Parameter data: 遺伝子データ
    /// - Returns: 影響スコアが計算済みの遺伝子データ
    private func precalculateImpacts(for data: GeneData) async -> GeneData {
        var updatedData = data
        var updatedMarkers: [String: [GeneticMarker]] = [:]

        let startTime = Date()
        var totalMarkers = 0
        var totalSNPs = 0

        for (category, markers) in data.geneticMarkersWithGenotypes {
            let calculatedMarkers = markers.map { marker in
                var m = marker
                // calculateImpact() を呼び出して結果をキャッシュ
                m.cachedImpact = m.calculateImpact(markerTitle: marker.title)
                totalMarkers += 1
                totalSNPs += marker.genotypes.count
                return m
            }
            updatedMarkers[category] = calculatedMarkers
        }

        updatedData.geneticMarkersWithGenotypes = updatedMarkers

        let duration = Date().timeIntervalSince(startTime)
        print("🧬 事前計算完了: \(totalMarkers)マーカー, \(totalSNPs)SNP, 処理時間: \(String(format: "%.2f", duration))秒")

        return updatedData
    }


}

// MARK: - Error Types

enum GeneDataError: LocalizedError {
    case userNotFound
    case invalidData
    case networkError

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "ユーザー情報が見つかりません"
        case .invalidData:
            return "遺伝子データの形式が正しくありません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        }
    }
}

// MARK: - AI Chat Support Extensions

extension GeneDataService {

    /// 利用可能な遺伝子カテゴリーのリストを取得
    /// - Returns: カテゴリー名の配列（ソート済み）、データがない場合は空配列
    func availableCategories() -> [String] {
        guard let data = geneData else {
            return []
        }
        return data.categories
    }

    /// 特定カテゴリーの遺伝子データを抽出（AIチャット送信用、2段階抽出対応）
    /// - Parameters:
    ///   - categoryName: カテゴリー名（柔軟なマッチング対応）
    ///   - subcategories: 抽出する小カテゴリー名の配列（nilの場合は全て）
    /// - Returns: マーカーデータの配列（JSON形式）、カテゴリーが存在しない場合はnil
    func extractCategoryData(categoryName: String, subcategories: [String]? = nil) -> [[String: Any]]? {
        guard let data = geneData else {
            print("🧬 extractCategoryData: geneData is nil")
            return nil
        }

        // 柔軟なマッチングで実際のカテゴリーを探す
        let actualCategory = findMatchingCategory(requestedName: categoryName, availableCategories: data.categories)
        guard let matchedCategory = actualCategory else {
            print("❌ extractCategoryData: カテゴリー '\(categoryName)' が見つかりません")
            print("📋 利用可能なカテゴリー: \(data.categories.joined(separator: ", "))")
            return nil
        }

        print("✅ Category matched: '\(categoryName)' → '\(matchedCategory)'")

        // マーカーを取得
        var markers = data.markers(for: matchedCategory)
        guard !markers.isEmpty else {
            print("❌ extractCategoryData: カテゴリー '\(matchedCategory)' にマーカーが見つかりません")
            return nil
        }

        // 小カテゴリーフィルタリング（指定された場合のみ）
        if let subcategories = subcategories {
            print("🔍 Filtering subcategories: \(subcategories.joined(separator: ", "))")
            markers = markers.filter { marker in
                subcategories.contains { requestedSubcat in
                    // 完全一致 or 部分一致
                    marker.title == requestedSubcat ||
                    marker.title.contains(requestedSubcat) ||
                    requestedSubcat.contains(marker.title)
                }
            }
            print("✅ Filtered to \(markers.count) markers")
        }

        guard !markers.isEmpty else {
            print("❌ No markers found after filtering")
            if let subcategories = subcategories {
                print("🔍 [DEBUG] Requested subcategories: \(subcategories.joined(separator: " | "))")
                let allMarkers = data.markers(for: matchedCategory)
                print("🔍 [DEBUG] Available marker titles: \(allMarkers.map { $0.title }.joined(separator: " | "))")
            }
            return nil
        }

        // マーカーをJSON形式に変換
        let markersData: [[String: Any]] = markers.map { marker in
            var markerDict: [String: Any] = [
                "title": marker.title,
                "genotypes": marker.genotypes
            ]

            // 影響スコアがキャッシュされている場合は含める
            if let impact = marker.cachedImpact {
                markerDict["impact"] = [
                    "protective": impact.protective,
                    "risk": impact.risk,
                    "neutral": impact.neutral,
                    "score": impact.score
                ]
            }

            return markerDict
        }

        print("🧬 extractCategoryData: カテゴリー '\(matchedCategory)' から \(markersData.count) マーカーを抽出")
        return markersData
    }

    /// カテゴリーの小カテゴリーリストのみを抽出（メタデータのみ、SNPsなし）
    /// - Parameter categoryName: カテゴリー名
    /// - Returns: 小カテゴリー名の配列（JSON形式）、カテゴリーが存在しない場合はnil
    func extractCategoryMetadata(categoryName: String) -> [[String: Any]]? {
        guard let data = geneData else {
            print("🧬 extractCategoryMetadata: geneData is nil")
            return nil
        }

        // 柔軟なマッチングで実際のカテゴリーを探す
        let actualCategory = findMatchingCategory(requestedName: categoryName, availableCategories: data.categories)
        guard let matchedCategory = actualCategory else {
            print("❌ extractCategoryMetadata: カテゴリー '\(categoryName)' が見つかりません")
            return nil
        }

        print("✅ Category matched: '\(categoryName)' → '\(matchedCategory)'")

        let markers = data.markers(for: matchedCategory)
        guard !markers.isEmpty else {
            print("❌ extractCategoryMetadata: カテゴリー '\(matchedCategory)' にマーカーが見つかりません")
            return nil
        }

        // 小カテゴリー名のみを抽出（titleのみ）
        let metadata: [[String: Any]] = markers.map { marker in
            return ["title": marker.title]
        }

        print("🧬 extractCategoryMetadata: カテゴリー '\(matchedCategory)' から \(metadata.count) 小カテゴリーを抽出（メタデータのみ）")
        return metadata
    }

    /// カテゴリー名の柔軟なマッチング
    /// - Parameters:
    ///   - requestedName: 要求されたカテゴリー名
    ///   - availableCategories: 利用可能なカテゴリー名リスト
    /// - Returns: マッチしたカテゴリー名、見つからない場合はnil
    private func findMatchingCategory(requestedName: String, availableCategories: [String]) -> String? {
        // 1. 完全一致を試す
        if availableCategories.contains(requestedName) {
            return requestedName
        }

        // 2. 全角括弧を半角に変換して正規化
        let normalizedRequest = requestedName
            .replacingOccurrences(of: "（", with: "(")
            .replacingOccurrences(of: "）", with: ")")

        // 3. 利用可能なカテゴリーから部分一致を探す
        for availableCategory in availableCategories {
            // 番号とスペースを除去してマッチング
            let normalizedAvailable = availableCategory
                .replacingOccurrences(of: "^[0-9]+\\. ", with: "", options: .regularExpression)

            // 部分一致チェック（日本語部分または英語部分）
            if normalizedAvailable.contains(normalizedRequest) ||
               normalizedRequest.contains(normalizedAvailable) {
                return availableCategory
            }

            // 英語部分のみで再試行（括弧内の英語を抽出）
            if let range = normalizedRequest.range(of: "\\([^)]+\\)", options: .regularExpression) {
                let englishPart = String(normalizedRequest[range])
                    .trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                if normalizedAvailable.contains(englishPart) {
                    return availableCategory
                }
            }

            // 日本語部分のみで再試行（括弧より前の部分を抽出）
            if let range = normalizedRequest.range(of: "^[^(（]+", options: .regularExpression) {
                let japanesePart = String(normalizedRequest[range])
                    .trimmingCharacters(in: .whitespaces)
                if normalizedAvailable.contains(japanesePart) {
                    return availableCategory
                }
            }
        }

        return nil
    }

    /// 複数カテゴリーの遺伝子データを一度に抽出（AIチャット送信用）
    /// - Parameter categoryNames: カテゴリー名の配列
    /// - Returns: カテゴリー名をキーとしたマーカーデータの辞書
    func extractMultipleCategoriesData(categoryNames: [String]) -> [String: [[String: Any]]] {
        var result: [String: [[String: Any]]] = [:]

        for categoryName in categoryNames {
            if let categoryData = extractCategoryData(categoryName: categoryName) {
                result[categoryName] = categoryData
            }
        }

        print("🧬 extractMultipleCategoriesData: \(result.count)/\(categoryNames.count) カテゴリーを抽出")
        return result
    }
}
