//
//  HealthScoreService.swift
//  TUUN
//
//  Created by Claude Code on 2025-11-20.
//  スコアリングエンジン: 統合サービス
//

import Foundation

/// 健康スコア計算サービス - BloodTestとHealthKitを統合
class HealthScoreService: ObservableObject {
    static let shared = HealthScoreService()

    // MARK: - Published Properties

    /// 計算済みドメインスコア
    @Published var metabolicScore: Double?
    @Published var inflammationScore: Double?
    @Published var recoveryScore: Double?
    @Published var agingPaceScore: Double?

    /// スコア計算の状態
    @Published var isCalculating = false
    @Published var lastCalculatedAt: Date?

    private init() {}

    // MARK: - Score Calculation Result

    /// スコア計算結果
    struct ScoreResult {
        let metabolic: Double?
        let inflammation: Double?
        let recovery: Double?
        let agingPace: Double?
        let timestamp: Date

        var allAvailable: Bool {
            return metabolic != nil && inflammation != nil &&
                   recovery != nil && agingPace != nil
        }
    }

    // MARK: - Main Calculation Method

    /// 全スコアを計算
    ///
    /// BloodTestServiceとHealthKitServiceからデータを取得し、
    /// 4つのドメインスコアを計算します。
    ///
    /// - Returns: 計算結果
    @discardableResult
    func calculateAllScores() async -> ScoreResult {
        await MainActor.run {
            self.isCalculating = true
        }

        // 1. データソースからメトリック値を収集
        let allMetricValues = collectAllMetricValues()

        // デバッグ出力
        printMetricValuesSummary(allMetricValues)

        // 2. 各ドメインスコアを計算
        let metabolic = ScoreEngine.computeDomainScore(
            valuesByMetricId: allMetricValues,
            domainConfig: MetricConfigs.metabolicDomain,
            metricConfigs: MetricConfigs.all
        )

        let inflammation = ScoreEngine.computeDomainScore(
            valuesByMetricId: allMetricValues,
            domainConfig: MetricConfigs.inflammationDomain,
            metricConfigs: MetricConfigs.all
        )

        let recovery = ScoreEngine.computeDomainScore(
            valuesByMetricId: allMetricValues,
            domainConfig: MetricConfigs.recoveryDomain,
            metricConfigs: MetricConfigs.all
        )

        let agingPace = ScoreEngine.computeDomainScore(
            valuesByMetricId: allMetricValues,
            domainConfig: MetricConfigs.agingPaceDomain,
            metricConfigs: MetricConfigs.all
        )

        // 3. 結果を保存
        let result = ScoreResult(
            metabolic: metabolic,
            inflammation: inflammation,
            recovery: recovery,
            agingPace: agingPace,
            timestamp: Date()
        )

        await MainActor.run {
            self.metabolicScore = metabolic
            self.inflammationScore = inflammation
            self.recoveryScore = recovery
            self.agingPaceScore = agingPace
            self.lastCalculatedAt = result.timestamp
            self.isCalculating = false
        }

        // 4. デバッグ出力
        printScoresSummary(result)

        return result
    }

    // MARK: - Data Collection

    /// 全メトリック値を収集 (BloodTest + HealthKit)
    private func collectAllMetricValues() -> [String: Double] {
        var values: [String: Double] = [:]

        // 1. 血液検査データを収集
        let bloodTestValues = collectBloodTestValues()
        values.merge(bloodTestValues) { _, new in new }

        // 2. HealthKitデータを収集
        let healthKitValues = collectHealthKitValues()
        values.merge(healthKitValues) { _, new in new }

        return values
    }

    /// 血液検査データを収集
    private func collectBloodTestValues() -> [String: Double] {
        guard let bloodData = BloodTestService.shared.bloodData else {
            print("⚠️ No blood test data available")
            return [:]
        }

        var values: [String: Double] = [:]

        for item in bloodData.bloodItems {
            // value文字列をDoubleに変換
            if let doubleValue = parseBloodItemValue(item.value) {
                values[item.key] = doubleValue
            } else {
                print("⚠️ Could not parse blood item '\(item.key)' value: '\(item.value)'")
            }
        }

        return values
    }

    /// HealthKitデータを収集
    private func collectHealthKitValues() -> [String: Double] {
        let healthKitData = HealthKitService.shared.healthData
        return HealthKitBridge.convertToMetricValues(from: healthKitData)
    }

    // MARK: - Value Parsing

    /// 血液検査項目の値をDoubleに変換
    ///
    /// - Parameter valueString: "5.6" や "120" などの文字列
    /// - Returns: Double値、パース失敗時はnil
    private func parseBloodItemValue(_ valueString: String) -> Double? {
        // 文字列をトリム
        let trimmed = valueString.trimmingCharacters(in: .whitespaces)

        // "<" や ">" などの記号を除去
        let cleaned = trimmed.replacingOccurrences(of: "<", with: "")
                             .replacingOccurrences(of: ">", with: "")
                             .replacingOccurrences(of: "未満", with: "")
                             .replacingOccurrences(of: "以上", with: "")
                             .trimmingCharacters(in: .whitespaces)

        // Doubleに変換
        return Double(cleaned)
    }

    // MARK: - Debug Helpers

    /// メトリック値のサマリーを出力
    private func printMetricValuesSummary(_ values: [String: Double]) {
        print("📊 Collected Metric Values:")
        print("================================")

        if values.isEmpty {
            print("⚠️ No metric values collected")
            return
        }

        // カテゴリ別に表示
        print("\n🩸 Blood Test Metrics:")
        for (key, value) in values.sorted(by: { $0.key < $1.key }) {
            // HealthKitメトリックはスキップ
            if ["bmi", "hrv", "rhr", "vo2max", "dailySteps", "activeCalories", "sleepHours"].contains(key) {
                continue
            }
            print("  \(key): \(String(format: "%.2f", value))")
        }

        print("\n💓 HealthKit Metrics:")
        for (key, value) in values.sorted(by: { $0.key < $1.key }) {
            if ["bmi", "hrv", "rhr", "vo2max", "dailySteps", "activeCalories", "sleepHours"].contains(key) {
                print("  \(key): \(String(format: "%.2f", value))")
            }
        }

        print("================================")
    }

    /// スコアのサマリーを出力
    private func printScoresSummary(_ result: ScoreResult) {
        print("\n🎯 Health Scores Summary:")
        print("================================")

        if let metabolic = result.metabolic {
            print("  代謝力: \(String(format: "%.1f", metabolic))/100")
        } else {
            print("  代謝力: データ不足")
        }

        if let inflammation = result.inflammation {
            print("  炎症レベル: \(String(format: "%.1f", inflammation))/100")
        } else {
            print("  炎症レベル: データ不足")
        }

        if let recovery = result.recovery {
            print("  回復スピード: \(String(format: "%.1f", recovery))/100")
        } else {
            print("  回復スピード: データ不足")
        }

        if let agingPace = result.agingPace {
            print("  老化速度: \(String(format: "%.1f", agingPace))/100")
        } else {
            print("  老化速度: データ不足")
        }

        print("================================\n")
    }
}
