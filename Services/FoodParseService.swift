//
//  FoodParseService.swift
//  FUUD
//
//  食品解析API連携サービス
//  自然文テキストを栄養データに変換する
//

import Foundation

// MARK: - Response Models

/// API レスポンス全体
struct FoodParseResponse: Codable {
    let success: Bool
    let data: FoodParseData?
    let error: String?
    let message: String?
}

/// 解析結果データ
struct FoodParseData: Codable {
    let items: [ParsedFoodItem]
    let totals: NutritionTotals
    let confidence: String
    let source: String
    let originalText: String
    let mealType: String?
}

/// 解析された食品アイテム
struct ParsedFoodItem: Codable {
    let name: String
    let nameEn: String?
    let foodId: String?
    let brandName: String?
    let foodType: String?
    let quantity: Int
    let grams: Double
    let servingDescription: String?
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let fiber: Double?
    let sodium: Double?
    let source: String
    let confidence: String
}

/// 栄養素合計
struct NutritionTotals: Codable {
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let fiber: Double?
    let sodium: Double?
}

// MARK: - Error Types

enum FoodParseError: LocalizedError {
    case parseFailed(String)
    case networkError(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .parseFailed(let message):
            return message
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .invalidResponse:
            return "サーバーからの応答が不正です"
        }
    }
}

// MARK: - FoodParseService

/// 食品解析APIサービス
class FoodParseService {
    static let shared = FoodParseService()
    private let networkManager = NetworkManager.shared

    private init() {}

    /// 自然文テキストを食品データに変換
    /// - Parameters:
    ///   - text: ユーザーが入力した食事のテキスト（例: "サラダチキンとおにぎり2個"）
    ///   - mealType: 食事タイプ（breakfast, lunch, dinner, snack）
    /// - Returns: 解析結果
    @MainActor
    func parseFood(text: String, mealType: String? = nil) async throws -> FoodParseData {
        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudFoodParse

        var body: [String: Any] = ["text": text]
        if let mealType = mealType {
            body["mealType"] = mealType
        }

        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .POST,
            body: body,
            requiresAuth: true
        )

        print("📝 FoodParseService: Parsing food text: \(text)")

        do {
            let response: FoodParseResponse = try await networkManager.sendRequest(
                config: requestConfig,
                responseType: FoodParseResponse.self
            )

            guard response.success, let data = response.data else {
                let errorMessage = response.message ?? "解析に失敗しました"
                print("❌ FoodParseService: Parse failed - \(errorMessage)")
                throw FoodParseError.parseFailed(errorMessage)
            }

            print("✅ FoodParseService: Parsed \(data.items.count) items (source: \(data.source))")
            return data

        } catch let error as FoodParseError {
            throw error
        } catch {
            print("❌ FoodParseService: Network error - \(error)")
            throw FoodParseError.networkError(error)
        }
    }
}
