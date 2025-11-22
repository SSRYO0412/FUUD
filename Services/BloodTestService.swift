//
//  BloodTestService.swift
//  AWStest
//
//  血液検査データ取得サービス
//

import Foundation

/// 血液検査データ取得サービス
class BloodTestService: ObservableObject {
    static let shared = BloodTestService()
    
    // MARK: - Published Properties
    @Published var bloodHistory: [BloodTestData] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showCopySuccessToast = false

    /// 最新の血液検査データ（後方互換性のための計算プロパティ）
    var bloodData: BloodTestData? {
        bloodHistory.first
    }

    private init() {}
    
    // MARK: - Data Models

    /// 履歴データコンテナ
    struct HistoryContainer: Codable {
        let history: [BloodTestData]
    }

    /// 血液検査データ全体のレスポンス
    struct BloodTestResponse: Codable {
        let success: Bool
        let data: HistoryContainer?
        let error: String?
        let errorCode: String?
        let timestamp: String?
    }
    
    /// 血液検査データ本体
    struct BloodTestData: Codable, Identifiable {
        let id = UUID()
        let userId: String
        let timestamp: String
        let bloodItems: [BloodItem]
        
        private enum CodingKeys: String, CodingKey {
            case userId, timestamp, bloodItems
        }
    }
    
    /// 個別の血液検査項目
    struct BloodItem: Codable, Identifiable {
        let id = UUID()
        let key: String
        let nameJp: String
        let value: String
        let unit: String
        let status: String
        let reference: String
        
        private enum CodingKeys: String, CodingKey {
            case key
            case nameJp = "name_jp"
            case value, unit, status, reference
        }
        
        /// 状態のカラー
        var statusColor: String {
            switch status.lowercased() {
            case "正常", "normal":
                return "green"
            case "注意", "caution", "要注意":
                return "orange"
            case "異常", "abnormal", "高い", "低い":
                return "red"
            default:
                return "gray"
            }
        }
        
        /// 状態のアイコン
        var statusIcon: String {
            switch status.lowercased() {
            case "正常", "normal":
                return "checkmark.circle.fill"
            case "注意", "caution", "要注意":
                return "exclamationmark.triangle.fill"
            case "異常", "abnormal", "高い", "低い":
                return "xmark.circle.fill"
            default:
                return "info.circle.fill"
            }
        }
    }
    
    // MARK: - API Methods

    /// 血液検査データを取得
    /// - Parameter userId: ユーザーID（メールアドレス）
    func fetchBloodTestData(for userId: String? = nil) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }

        // デモモードの場合、サンプルデータを返す
        if DemoModeManager.shared.isDemoMode {
            await MainActor.run {
                self.bloodHistory = [Self.createDemoData()]
                self.errorMessage = ""
                self.isLoading = false
            }
            return
        }

        do {
            let userEmail = userId ?? SimpleCognitoService.shared.currentUserEmail ?? ""
            guard !userEmail.isEmpty else {
                throw BloodTestError.userNotFound
            }
            
            let encodedEmail = userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? userEmail
            let endpoint = "https://7rk2qibxm6.execute-api.ap-northeast-1.amazonaws.com/prod?userId=\(encodedEmail)"
            
            let requestConfig = NetworkManager.RequestConfig(
                url: endpoint,
                method: .GET,
                requiresAuth: true
            )
            
            let response: BloodTestResponse = try await NetworkManager.shared.sendRequest(
                config: requestConfig,
                responseType: BloodTestResponse.self
            )
            
            await MainActor.run {
                if response.success, let container = response.data {
                    self.bloodHistory = container.history
                    print("🩸 BloodTest history received: \(self.bloodHistory.count) records")
                    if let latest = self.bloodHistory.first {
                        print("🩸 Latest test: \(latest.bloodItems.count) items, timestamp: \(latest.timestamp)")
                    }
                    self.errorMessage = ""
                } else {
                    print("🩸 BloodTest failed: \(response.error ?? "Unknown error")")
                    self.errorMessage = response.error ?? "血液検査データの取得に失敗しました"
                }
                self.isLoading = false
            }
            
        } catch {
            let appError = ErrorManager.shared.convertToAppError(error)
            ErrorManager.shared.logError(appError, context: "BloodTestService.fetchBloodTestData")
            
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
            self.bloodHistory = []
            self.errorMessage = ""
        }
        await fetchBloodTestData()
    }
    
    /// 特定の血液項目を検索
    /// - Parameter key: 検索したい項目のキー
    /// - Returns: マッチした血液項目
    func findBloodItem(by key: String) -> BloodItem? {
        return bloodData?.bloodItems.first { $0.key == key }
    }
    
    /// 異常値の項目のみ取得
    var abnormalItems: [BloodItem] {
        return bloodData?.bloodItems.filter { item in
            !["正常", "normal"].contains(item.status.lowercased())
        } ?? []
    }
    
    /// 正常値の項目のみ取得
    var normalItems: [BloodItem] {
        return bloodData?.bloodItems.filter { item in
            ["正常", "normal"].contains(item.status.lowercased())
        } ?? []
    }

    // MARK: - History Helper Methods

    /// 履歴データが複数あるか確認
    var hasHistory: Bool {
        bloodHistory.count > 1
    }

    /// 指定インデックスの履歴データから特定項目の値を取得
    /// - Parameters:
    ///   - key: 血液検査項目のキー
    ///   - index: 履歴のインデックス（0が最新）
    /// - Returns: 項目の値（見つからない場合はnil）
    func getHistoricalValue(for key: String, at index: Int) -> String? {
        guard index < bloodHistory.count else { return nil }
        return bloodHistory[index].bloodItems.first { $0.key == key }?.value
    }

    /// 前回の検査結果から特定項目の値を取得
    /// - Parameter key: 血液検査項目のキー
    /// - Returns: 前回の値（見つからない場合はnil）
    func getPreviousValue(for key: String) -> String? {
        guard bloodHistory.count > 1 else { return nil }
        return getHistoricalValue(for: key, at: 1)
    }

    /// 指定項目の履歴データ配列を取得
    /// - Parameter key: 血液検査項目のキー
    /// - Returns: 時系列順の値の配列
    func getValueHistory(for key: String) -> [(timestamp: String, value: String)] {
        return bloodHistory.compactMap { data in
            guard let item = data.bloodItems.first(where: { $0.key == key }) else {
                return nil
            }
            return (timestamp: data.timestamp, value: item.value)
        }
    }

    // MARK: - Demo Data

    /// デモモード用のサンプルデータを生成
    static func createDemoData() -> BloodTestData {
        let demoItems: [BloodItem] = [
            .init(key: "HbA1c", nameJp: "ヘモグロビンA1c", value: "5.6", unit: "%", status: "正常", reference: "4.6-6.2"),
            .init(key: "FPG", nameJp: "空腹時血糖", value: "95", unit: "mg/dL", status: "正常", reference: "70-109"),
            .init(key: "TG", nameJp: "中性脂肪", value: "120", unit: "mg/dL", status: "正常", reference: "30-149"),
            .init(key: "HDL", nameJp: "HDLコレステロール", value: "58", unit: "mg/dL", status: "正常", reference: "40-96"),
            .init(key: "LDL", nameJp: "LDLコレステロール", value: "105", unit: "mg/dL", status: "正常", reference: "70-139"),
            .init(key: "TC", nameJp: "総コレステロール", value: "195", unit: "mg/dL", status: "正常", reference: "150-219"),
            .init(key: "CRP", nameJp: "C反応性タンパク", value: "0.08", unit: "mg/dL", status: "正常", reference: "0.00-0.30"),
            .init(key: "AST", nameJp: "AST(GOT)", value: "25", unit: "U/L", status: "正常", reference: "10-40"),
            .init(key: "ALT", nameJp: "ALT(GPT)", value: "28", unit: "U/L", status: "正常", reference: "5-45"),
            .init(key: "GGT", nameJp: "γ-GTP", value: "32", unit: "U/L", status: "正常", reference: "0-70"),
            .init(key: "ALP", nameJp: "ALP", value: "215", unit: "U/L", status: "正常", reference: "100-325"),
            .init(key: "TP", nameJp: "総蛋白", value: "7.2", unit: "g/dL", status: "正常", reference: "6.7-8.3"),
            .init(key: "ALB", nameJp: "アルブミン", value: "4.5", unit: "g/dL", status: "正常", reference: "3.8-5.2"),
            .init(key: "BUN", nameJp: "尿素窒素", value: "15", unit: "mg/dL", status: "正常", reference: "8-20"),
            .init(key: "CRE", nameJp: "クレアチニン", value: "0.85", unit: "mg/dL", status: "正常", reference: "0.60-1.10"),
            .init(key: "UA", nameJp: "尿酸", value: "5.8", unit: "mg/dL", status: "正常", reference: "3.0-7.0"),
            .init(key: "WBC", nameJp: "白血球数", value: "6500", unit: "/μL", status: "正常", reference: "3500-9000"),
            .init(key: "RBC", nameJp: "赤血球数", value: "480", unit: "万/μL", status: "正常", reference: "400-550"),
            .init(key: "Hb", nameJp: "ヘモグロビン", value: "14.5", unit: "g/dL", status: "正常", reference: "13.5-17.5"),
            .init(key: "Ht", nameJp: "ヘマトクリット", value: "43.2", unit: "%", status: "正常", reference: "39.0-52.0"),
            .init(key: "PLT", nameJp: "血小板数", value: "25.5", unit: "万/μL", status: "正常", reference: "13.0-35.0"),
            .init(key: "NEU", nameJp: "好中球", value: "58.5", unit: "%", status: "正常", reference: "40.0-70.0"),
            .init(key: "LYM", nameJp: "リンパ球", value: "32.8", unit: "%", status: "正常", reference: "25.0-45.0"),
            .init(key: "MON", nameJp: "単球", value: "5.2", unit: "%", status: "正常", reference: "2.0-8.0"),
            .init(key: "EOS", nameJp: "好酸球", value: "2.8", unit: "%", status: "正常", reference: "0.0-6.0"),
            .init(key: "BAS", nameJp: "好塩基球", value: "0.7", unit: "%", status: "正常", reference: "0.0-2.0"),
            .init(key: "CK", nameJp: "クレアチンキナーゼ", value: "145", unit: "U/L", status: "正常", reference: "50-250"),
            .init(key: "LDH", nameJp: "乳酸脱水素酵素", value: "185", unit: "U/L", status: "正常", reference: "120-240"),
            .init(key: "Ferritin", nameJp: "フェリチン", value: "125", unit: "ng/mL", status: "正常", reference: "20-300"),
            .init(key: "INS", nameJp: "インスリン", value: "8.5", unit: "μU/mL", status: "正常", reference: "2.0-15.0")
        ]

        return BloodTestData(
            userId: "demo@example.com",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            bloodItems: demoItems
        )
    }
}

// MARK: - Error Types

enum BloodTestError: LocalizedError {
    case userNotFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "ユーザー情報が見つかりません"
        case .invalidData:
            return "血液検査データの形式が正しくありません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        }
    }
}