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
    @Published var bloodData: BloodTestData?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private init() {}
    
    // MARK: - Data Models
    
    /// 血液検査データ全体のレスポンス
    struct BloodTestResponse: Codable {
        let success: Bool
        let data: BloodTestData?
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
                if response.success, let data = response.data {
                    print("🩸 BloodTest data received: \(data.bloodItems.count) items")
                    self.bloodData = data
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
            self.bloodData = nil
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