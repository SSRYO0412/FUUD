//
//  MealLogService.swift
//  FUUD
//
//  食事ログAPI連携サービス
//

import Foundation
import SwiftUI

// MARK: - Data Models

/// 日次摂取量
struct DailyIntake: Codable {
    let calories: Int
    let protein: Int
    let fat: Int
    let carbs: Int

    static let zero = DailyIntake(calories: 0, protein: 0, fat: 0, carbs: 0)
}

/// 日別カロリー（週次トレンド用）
struct DailyCalorie: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
    let target: Int
}

/// 食事エントリー
struct MealEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let date: String
    let timestamp: String
    let foodName: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let servingSize: Double?
    let servingUnit: String?
    let mealType: String?  // "breakfast", "lunch", "dinner", "snack"

    enum CodingKeys: String, CodingKey {
        case id = "log_id"
        case userId = "user_id"
        case date
        case timestamp
        case foodName = "food_name"
        case calories
        case protein
        case fat
        case carbs
        case servingSize = "serving_size"
        case servingUnit = "serving_unit"
        case mealType = "meal_type"
    }
}

/// API レスポンス
struct MealLogResponse: Codable {
    let meals: [MealEntry]
    let totals: DailyTotals?

    struct DailyTotals: Codable {
        let calories: Int
        let protein: Double
        let fat: Double
        let carbs: Double
    }
}

/// 週間カロリーAPIレスポンス
struct WeeklyCaloriesResponse: Codable {
    let days: [DayData]
    let summary: Summary

    struct DayData: Codable {
        let date: String
        let calories: Int
        let logged: Bool
    }

    struct Summary: Codable {
        let totalDays: Int
        let loggedDays: Int
        let averageCalories: Int

        enum CodingKeys: String, CodingKey {
            case totalDays = "total_days"
            case loggedDays = "logged_days"
            case averageCalories = "average_calories"
        }
    }
}

// MARK: - MealLogService

class MealLogService: ObservableObject {
    static let shared = MealLogService()

    // MARK: - Published Properties

    @Published var todayMeals: [MealEntry] = []
    @Published var todayTotals: DailyIntake = .zero
    @Published var weeklyCalories: [DailyCalorie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkManager = NetworkManager.shared

    private init() {}

    // MARK: - Date Formatting

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    // MARK: - Fetch Today's Meals

    /// 指定日の食事ログを取得
    @MainActor
    func fetchMeals(for date: Date) async {
        isLoading = true
        errorMessage = nil

        let dateString = dateFormatter.string(from: date)
        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudMealLog
        let url = "\(endpoint)?date=\(dateString)"

        let requestConfig = NetworkManager.RequestConfig(
            url: url,
            method: .GET,
            requiresAuth: true
        )

        do {
            let response: MealLogResponse = try await networkManager.sendRequest(
                config: requestConfig,
                responseType: MealLogResponse.self
            )

            self.todayMeals = response.meals

            if let totals = response.totals {
                self.todayTotals = DailyIntake(
                    calories: totals.calories,
                    protein: Int(totals.protein),
                    fat: Int(totals.fat),
                    carbs: Int(totals.carbs)
                )
            } else {
                // 合計を手動計算
                self.todayTotals = calculateTotals(from: response.meals)
            }

            self.isLoading = false
            print("✅ MealLogService: \(response.meals.count) meals loaded for \(dateString)")

        } catch {
            self.isLoading = false
            self.errorMessage = "食事ログの取得に失敗しました"
            print("❌ MealLogService error: \(error)")

            // エラー時はデモデータを使用
            self.todayMeals = []
            self.todayTotals = .zero
        }
    }

    /// 今日の食事ログを取得
    @MainActor
    func fetchTodayMeals() async {
        await fetchMeals(for: Date())
    }

    // MARK: - Fetch Weekly Calories

    /// 週間カロリーデータを取得
    @MainActor
    func fetchWeeklyCalories(targetCalories: Int = 1800) async {
        isLoading = true
        errorMessage = nil

        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudBase + "/api/v1/logs/calories"
        let url = "\(endpoint)?days=7"

        let requestConfig = NetworkManager.RequestConfig(
            url: url,
            method: .GET,
            requiresAuth: true
        )

        do {
            let response: WeeklyCaloriesResponse = try await networkManager.sendRequest(
                config: requestConfig,
                responseType: WeeklyCaloriesResponse.self
            )

            self.weeklyCalories = response.days.compactMap { day in
                guard let date = dateFormatter.date(from: day.date) else { return nil }
                return DailyCalorie(
                    date: date,
                    calories: day.calories,
                    target: targetCalories
                )
            }

            self.isLoading = false
            print("✅ MealLogService: Weekly calories loaded (\(response.summary.loggedDays)/\(response.summary.totalDays) days logged)")

        } catch {
            self.isLoading = false
            self.errorMessage = "週間データの取得に失敗しました"
            print("❌ MealLogService weekly error: \(error)")

            // エラー時はデモデータ
            self.weeklyCalories = generateDemoWeeklyData(targetCalories: targetCalories)
        }
    }

    // MARK: - Log Meal

    /// 食事を記録
    @MainActor
    func logMeal(
        foodName: String,
        calories: Int,
        protein: Double,
        fat: Double,
        carbs: Double,
        servingSize: Double? = nil,
        servingUnit: String? = nil,
        mealType: String? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudMealLog

        var body: [String: Any] = [
            "food_name": foodName,
            "calories": calories,
            "protein": protein,
            "fat": fat,
            "carbs": carbs,
            "date": dateFormatter.string(from: Date())
        ]

        if let servingSize = servingSize {
            body["serving_size"] = servingSize
        }
        if let servingUnit = servingUnit {
            body["serving_unit"] = servingUnit
        }
        if let mealType = mealType {
            body["meal_type"] = mealType
        }

        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .POST,
            body: body,
            requiresAuth: true
        )

        do {
            let _: EmptyResponse = try await networkManager.sendRequest(
                config: requestConfig,
                responseType: EmptyResponse.self
            )

            self.isLoading = false

            // リフレッシュ
            await fetchTodayMeals()

            print("✅ MealLogService: Meal logged - \(foodName)")
            return true

        } catch {
            self.isLoading = false
            self.errorMessage = "食事の記録に失敗しました"
            print("❌ MealLogService log error: \(error)")
            return false
        }
    }

    // MARK: - Helper Methods

    /// 食事リストから合計を計算
    private func calculateTotals(from meals: [MealEntry]) -> DailyIntake {
        let totalCalories = meals.reduce(0) { $0 + $1.calories }
        let totalProtein = meals.reduce(0.0) { $0 + $1.protein }
        let totalFat = meals.reduce(0.0) { $0 + $1.fat }
        let totalCarbs = meals.reduce(0.0) { $0 + $1.carbs }

        return DailyIntake(
            calories: totalCalories,
            protein: Int(totalProtein),
            fat: Int(totalFat),
            carbs: Int(totalCarbs)
        )
    }

    /// デモ用週間データ生成
    private func generateDemoWeeklyData(targetCalories: Int) -> [DailyCalorie] {
        let calendar = Calendar.current
        return (0..<7).map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            // ランダムなカロリー（目標の70%〜110%）
            let randomFactor = Double.random(in: 0.7...1.1)
            let calories = daysAgo == 0 ? 0 : Int(Double(targetCalories) * randomFactor)
            return DailyCalorie(date: date, calories: calories, target: targetCalories)
        }.reversed()
    }
}
