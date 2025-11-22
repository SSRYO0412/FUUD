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
        let geneticMarkersWithGenotypes: [String: [GeneticMarker]]

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
