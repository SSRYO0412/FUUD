//
//  WeightLogService.swift
//  FUUD
//
//  体重ログAPI連携サービス
//

import Foundation
import SwiftUI

// MARK: - Data Models

/// 体重エントリー
struct WeightEntry: Identifiable, Codable {
    let id: String
    let date: Date
    let weight: Double
    let source: String?  // "manual" or "healthkit"

    enum CodingKeys: String, CodingKey {
        case id = "log_id"
        case date
        case weight
        case source
    }

    init(id: String = UUID().uuidString, date: Date, weight: Double, source: String? = "manual") {
        self.id = id
        self.date = date
        self.weight = weight
        self.source = source
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.weight = try container.decode(Double.self, forKey: .weight)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)

        // 日付のパース（文字列からDate）
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.date = formatter.date(from: dateString) ?? Date()
        } else {
            self.date = Date()
        }
    }
}

/// ユーザー目標
struct UserGoal: Codable {
    let goalType: String        // "lose", "maintain", "gain"
    let targetWeight: Double
    let weeklyRate: Double      // kg/week
    let startWeight: Double
    let targetCalories: Int

    enum CodingKeys: String, CodingKey {
        case goalType = "goal_type"
        case targetWeight = "target_weight"
        case weeklyRate = "weekly_rate"
        case startWeight = "start_weight"
        case targetCalories = "target_calories"
    }
}

/// 体重ログAPIレスポンス
struct WeightLogResponse: Codable {
    let weights: [WeightAPIEntry]
    let summary: Summary?

    struct WeightAPIEntry: Codable {
        let date: String
        let weight: Double?
        let source: String?
    }

    struct Summary: Codable {
        let currentWeight: Double?
        let trendWeight: Double?
        let changeFromStart: Double?

        enum CodingKeys: String, CodingKey {
            case currentWeight = "current_weight"
            case trendWeight = "trend_weight"
            case changeFromStart = "change_from_start"
        }
    }
}

// MARK: - WeightLogService

class WeightLogService: ObservableObject {
    static let shared = WeightLogService()

    // MARK: - Published Properties

    @Published var weightHistory: [WeightEntry] = []
    @Published var currentWeight: Double?
    @Published var trendWeight: Double?
    @Published var userGoal: UserGoal?
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

    // MARK: - Fetch Weight History

    /// 体重履歴を取得
    @MainActor
    func fetchWeightHistory(days: Int = 30) async {
        isLoading = true
        errorMessage = nil

        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudWeightLog
        let url = "\(endpoint)?days=\(days)"

        let requestConfig = NetworkManager.RequestConfig(
            url: url,
            method: .GET,
            requiresAuth: true
        )

        do {
            let response: WeightLogResponse = try await networkManager.sendRequest(
                config: requestConfig,
                responseType: WeightLogResponse.self
            )

            self.weightHistory = response.weights.compactMap { entry in
                guard let weight = entry.weight,
                      let date = dateFormatter.date(from: entry.date) else {
                    return nil
                }
                return WeightEntry(
                    id: entry.date,
                    date: date,
                    weight: weight,
                    source: entry.source
                )
            }

            if let summary = response.summary {
                self.currentWeight = summary.currentWeight
                self.trendWeight = summary.trendWeight
            } else if let lastWeight = weightHistory.first {
                self.currentWeight = lastWeight.weight
            }

            self.isLoading = false
            print("✅ WeightLogService: \(self.weightHistory.count) weight entries loaded")

        } catch {
            self.isLoading = false
            self.errorMessage = "体重履歴の取得に失敗しました"
            print("❌ WeightLogService error: \(error)")

            // エラー時はデモデータ
            self.weightHistory = generateDemoWeightData(days: days)
            self.currentWeight = weightHistory.first?.weight
        }
    }

    // MARK: - Fetch User Goal

    /// ユーザー目標を取得
    @MainActor
    func fetchUserGoal() async {
        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudBase + "/api/v1/goal"

        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .GET,
            requiresAuth: true
        )

        do {
            let response: UserGoal = try await networkManager.sendRequest(
                config: requestConfig,
                responseType: UserGoal.self
            )

            self.userGoal = response
            print("✅ WeightLogService: User goal loaded - target: \(response.targetWeight)kg")

        } catch {
            print("❌ WeightLogService goal error: \(error)")
            // 目標がない場合はデフォルト値
            self.userGoal = UserGoal(
                goalType: "lose",
                targetWeight: 70.0,
                weeklyRate: -0.5,
                startWeight: 75.0,
                targetCalories: 1800
            )
        }
    }

    // MARK: - Log Weight

    /// 体重を記録
    @MainActor
    func logWeight(_ weight: Double, date: Date = Date()) async -> Bool {
        isLoading = true
        errorMessage = nil

        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudWeightLog

        let body: [String: Any] = [
            "weight": weight,
            "date": dateFormatter.string(from: date),
            "source": "manual"
        ]

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
            self.currentWeight = weight

            // リフレッシュ
            await fetchWeightHistory()

            print("✅ WeightLogService: Weight logged - \(weight)kg")
            return true

        } catch {
            self.isLoading = false
            self.errorMessage = "体重の記録に失敗しました"
            print("❌ WeightLogService log error: \(error)")
            return false
        }
    }

    // MARK: - Computed Properties

    /// 体重変化（開始からの差分）
    var weightChange: Double? {
        guard let current = currentWeight,
              let goal = userGoal else { return nil }
        return current - goal.startWeight
    }

    /// 目標までの残り
    var remainingToGoal: Double? {
        guard let current = currentWeight,
              let goal = userGoal else { return nil }
        return current - goal.targetWeight
    }

    /// 目標達成率（%）
    var goalProgress: Double? {
        guard let goal = userGoal,
              let current = currentWeight else { return nil }

        let totalChange = goal.startWeight - goal.targetWeight
        guard totalChange != 0 else { return 100 }

        let currentChange = goal.startWeight - current
        return min(100, max(0, (currentChange / totalChange) * 100))
    }

    // MARK: - Helper Methods

    /// デモ用体重データ生成
    private func generateDemoWeightData(days: Int) -> [WeightEntry] {
        let calendar = Calendar.current
        var entries: [WeightEntry] = []

        let startWeight = 75.0
        var currentWeight = startWeight

        for daysAgo in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { continue }

            // 緩やかな減少トレンド + ランダムな変動
            let dailyChange = Double.random(in: -0.3...0.1)
            currentWeight = max(70.0, currentWeight + dailyChange)

            // 週末は記録なしの確率を上げる（リアリティのため）
            let weekday = calendar.component(.weekday, from: date)
            let skipProbability = (weekday == 1 || weekday == 7) ? 0.5 : 0.2

            if Double.random(in: 0...1) > skipProbability {
                entries.append(WeightEntry(
                    id: "\(daysAgo)",
                    date: date,
                    weight: round(currentWeight * 10) / 10,
                    source: "demo"
                ))
            }
        }

        return entries.sorted { $0.date > $1.date }
    }

    /// トレンド体重を計算（7日間移動平均）
    func calculateTrendWeight() -> Double? {
        let recentWeights = weightHistory.prefix(7).map { $0.weight }
        guard !recentWeights.isEmpty else { return nil }
        return recentWeights.reduce(0, +) / Double(recentWeights.count)
    }
}
