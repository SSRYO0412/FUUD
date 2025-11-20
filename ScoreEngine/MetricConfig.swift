//
//  MetricConfig.swift
//  TUUN
//
//  Created by Claude Code on 2025-11-20.
//  スコアリングエンジン: メトリック設定型定義
//

import Foundation

/// メトリックの方向性を定義
enum MetricDirection: String, Codable {
    case higherIsBetter  // 高いほど良い (例: HRV, VO2Max, HDL)
    case lowerIsBetter   // 低いほど良い (例: CRP, HbA1c, LDL, RHR)
    case rangeIsBest     // 範囲内が最適 (例: TP, ALB, BMI, 睡眠時間)
}

/// メトリックの設定情報
struct MetricConfig: Codable {
    let id: String                    // メトリックID (例: "HbA1c", "CRP", "hrv")
    let units: String                 // 単位 (例: "%", "mg/dL", "ms")
    let direction: MetricDirection    // スコアリング方向

    // スコアリング範囲
    let min: Double                   // 最小値 (スコア0に相当)
    let max: Double                   // 最大値 (スコア100に相当、方向により意味が異なる)

    // rangeIsBest用の理想範囲
    let idealLow: Double?             // 理想範囲の下限
    let idealHigh: Double?            // 理想範囲の上限

    init(
        id: String,
        units: String,
        direction: MetricDirection,
        min: Double,
        max: Double,
        idealLow: Double? = nil,
        idealHigh: Double? = nil
    ) {
        self.id = id
        self.units = units
        self.direction = direction
        self.min = min
        self.max = max
        self.idealLow = idealLow
        self.idealHigh = idealHigh
    }
}

/// ドメインスコアの設定情報 (複数メトリックの重み付け平均)
struct DomainScoreConfig: Codable {
    let id: String                           // ドメインID (例: "metabolic", "inflammation")
    let metrics: [WeightedMetric]            // メトリックと重みのリスト

    struct WeightedMetric: Codable {
        let metricId: String                 // メトリックID
        let weight: Double                   // 重み (合計が1.0になる)
    }

    init(id: String, metrics: [WeightedMetric]) {
        self.id = id
        self.metrics = metrics

        // デバッグ: 重みの合計を確認
        let totalWeight = metrics.reduce(0.0) { $0 + $1.weight }
        if abs(totalWeight - 1.0) > 0.001 {
            print("⚠️ Warning: Domain '\(id)' weights sum to \(totalWeight), not 1.0")
        }
    }
}
