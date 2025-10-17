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
    
    /// 遺伝子データ本体
    struct GeneData: Codable, Identifiable {
        let id = UUID()
        let userId: String?
        let timestamp: String?
        let diabetesRiskCategory: String?
        let hypertensionRiskCategory: String?
        let alcoholMetabolismCategory: String?
        let recommendations: [String]?
        let analysisVersion: String?
        
        private enum CodingKeys: String, CodingKey {
            case userId, timestamp, diabetesRiskCategory, hypertensionRiskCategory
            case alcoholMetabolismCategory, recommendations, analysisVersion
        }
        
        // デフォルト値を提供するcomputed properties
        var displayDiabetesRisk: String { diabetesRiskCategory ?? "データなし" }
        var displayHypertensionRisk: String { hypertensionRiskCategory ?? "データなし" }
        var displayAlcoholMetabolism: String { alcoholMetabolismCategory ?? "データなし" }
        var displayRecommendations: [String] { recommendations ?? [] }
        
        
    }
    
    
    
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
            
            await MainActor.run {
                if response.success, let data = response.data {
                    print("🧬 GeneData received successfully")
                    self.geneData = data
                    self.errorMessage = ""
                } else {
                    print("🧬 GeneData failed: \(response.error ?? "Unknown error")")
                    self.errorMessage = response.error ?? "遺伝子データの取得に失敗しました"
                }
                self.isLoading = false
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
