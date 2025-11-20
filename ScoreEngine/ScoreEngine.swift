//
//  ScoreEngine.swift
//  TUUN
//
//  Created by Claude Code on 2025-11-20.
//  スコアリングエンジン: コア計算ロジック
//

import Foundation

/// スコアリングエンジン - 0-100スケールでメトリックをスコア化
struct ScoreEngine {

    // MARK: - Single Metric Scoring

    /// 単一メトリックをスコア化 (0-100スケール)
    ///
    /// - Parameters:
    ///   - value: 実測値
    ///   - config: メトリック設定
    /// - Returns: 0-100のスコア
    static func scoreMetric(value: Double, config: MetricConfig) -> Double {
        switch config.direction {
        case .higherIsBetter:
            return scoreHigherIsBetter(value: value, min: config.min, max: config.max)

        case .lowerIsBetter:
            return scoreLowerIsBetter(value: value, min: config.min, max: config.max)

        case .rangeIsBest:
            guard let idealLow = config.idealLow, let idealHigh = config.idealHigh else {
                print("⚠️ Warning: rangeIsBest requires idealLow and idealHigh for metric '\(config.id)'")
                return 50.0 // デフォルト値
            }
            return scoreRangeIsBest(
                value: value,
                min: config.min,
                max: config.max,
                idealLow: idealLow,
                idealHigh: idealHigh
            )
        }
    }

    // MARK: - Domain Score Computation

    /// ドメインスコアを計算 (複数メトリックの重み付け平均)
    ///
    /// - Parameters:
    ///   - valuesByMetricId: メトリックIDと実測値のマップ
    ///   - domainConfig: ドメイン設定
    ///   - metricConfigs: 全メトリック設定のリスト
    /// - Returns: 0-100のドメインスコア、データ不足の場合はnil
    static func computeDomainScore(
        valuesByMetricId: [String: Double],
        domainConfig: DomainScoreConfig,
        metricConfigs: [MetricConfig]
    ) -> Double? {
        // メトリック設定をIDでマップ化
        let configMap = Dictionary(uniqueKeysWithValues: metricConfigs.map { ($0.id, $0) })

        var weightedSum = 0.0
        var totalWeight = 0.0
        var availableMetrics = 0

        for weightedMetric in domainConfig.metrics {
            let metricId = weightedMetric.metricId

            // 実測値を取得
            guard let value = valuesByMetricId[metricId] else {
                print("⚠️ Missing value for metric '\(metricId)' in domain '\(domainConfig.id)'")
                continue
            }

            // メトリック設定を取得
            guard let config = configMap[metricId] else {
                print("⚠️ Missing config for metric '\(metricId)' in domain '\(domainConfig.id)'")
                continue
            }

            // メトリックをスコア化
            let score = scoreMetric(value: value, config: config)

            // 重み付けして加算
            weightedSum += score * weightedMetric.weight
            totalWeight += weightedMetric.weight
            availableMetrics += 1
        }

        // データ不足の場合はnilを返す
        guard availableMetrics > 0 else {
            print("⚠️ No available metrics for domain '\(domainConfig.id)'")
            return nil
        }

        // 正規化して返す (重みの合計で割る)
        let domainScore = totalWeight > 0 ? weightedSum / totalWeight : 0.0
        return clamp(domainScore, min: 0.0, max: 100.0)
    }

    // MARK: - Private Scoring Functions

    /// 高いほど良いメトリックのスコア計算
    private static func scoreHigherIsBetter(value: Double, min: Double, max: Double) -> Double {
        let normalized = (value - min) / (max - min)
        let score = normalized * 100.0
        return clamp(score, min: 0.0, max: 100.0)
    }

    /// 低いほど良いメトリックのスコア計算
    private static func scoreLowerIsBetter(value: Double, min: Double, max: Double) -> Double {
        let normalized = (max - value) / (max - min)
        let score = normalized * 100.0
        return clamp(score, min: 0.0, max: 100.0)
    }

    /// 範囲内が最適なメトリックのスコア計算
    private static func scoreRangeIsBest(
        value: Double,
        min: Double,
        max: Double,
        idealLow: Double,
        idealHigh: Double
    ) -> Double {
        if value >= idealLow && value <= idealHigh {
            // 理想範囲内 → 100点
            return 100.0
        } else if value < idealLow {
            // 理想範囲より低い → minからidealLowの間でスコア化
            let normalized = (value - min) / (idealLow - min)
            let score = normalized * 100.0
            return clamp(score, min: 0.0, max: 100.0)
        } else {
            // 理想範囲より高い → idealHighからmaxの間でスコア化
            let normalized = (max - value) / (max - idealHigh)
            let score = normalized * 100.0
            return clamp(score, min: 0.0, max: 100.0)
        }
    }

    /// 値を範囲内にクランプ
    private static func clamp(_ value: Double, min: Double, max: Double) -> Double {
        return Swift.min(Swift.max(value, min), max)
    }
}
