//
//  MetricConfigs.swift
//  TUUN
//
//  Created by Claude Code on 2025-11-20.
//  スコアリングエンジン: 全メトリック範囲定義
//

import Foundation

/// 全メトリックの設定定義
struct MetricConfigs {

    // MARK: - All Metric Configs

    /// 全メトリック設定のリスト (27血液検査 + 7 HealthKit)
    static let all: [MetricConfig] = bloodTestMetrics + healthKitMetrics

    // MARK: - Blood Test Metrics (27種類)

    static let bloodTestMetrics: [MetricConfig] = [
        // 糖代謝 (3種類)
        MetricConfig(
            id: "HbA1c",
            units: "%",
            direction: .lowerIsBetter,
            min: 4.0,
            max: 10.0
        ),
        MetricConfig(
            id: "FBG",
            units: "mg/dL",
            direction: .lowerIsBetter,
            min: 70.0,
            max: 200.0
        ),
        MetricConfig(
            id: "insulin",
            units: "μU/mL",
            direction: .rangeIsBest,
            min: 2.0,
            max: 30.0,
            idealLow: 3.0,
            idealHigh: 15.0
        ),

        // 脂質代謝 (6種類)
        MetricConfig(
            id: "TG",
            units: "mg/dL",
            direction: .lowerIsBetter,
            min: 30.0,
            max: 300.0
        ),
        MetricConfig(
            id: "TC",
            units: "mg/dL",
            direction: .rangeIsBest,
            min: 120.0,
            max: 280.0,
            idealLow: 150.0,
            idealHigh: 220.0
        ),
        MetricConfig(
            id: "HDL",
            units: "mg/dL",
            direction: .higherIsBetter,
            min: 20.0,
            max: 100.0
        ),
        MetricConfig(
            id: "LDL",
            units: "mg/dL",
            direction: .lowerIsBetter,
            min: 40.0,
            max: 200.0
        ),
        MetricConfig(
            id: "nonHDL",
            units: "mg/dL",
            direction: .lowerIsBetter,
            min: 50.0,
            max: 220.0
        ),
        MetricConfig(
            id: "LH_ratio",
            units: "",
            direction: .lowerIsBetter,
            min: 1.0,
            max: 5.0
        ),

        // 炎症マーカー (1種類)
        MetricConfig(
            id: "CRP",
            units: "mg/dL",
            direction: .lowerIsBetter,
            min: 0.0,
            max: 2.0
        ),

        // 腎機能 (3種類)
        MetricConfig(
            id: "CRE",
            units: "mg/dL",
            direction: .rangeIsBest,
            min: 0.4,
            max: 2.0,
            idealLow: 0.6,
            idealHigh: 1.2
        ),
        MetricConfig(
            id: "eGFR",
            units: "mL/min/1.73m²",
            direction: .higherIsBetter,
            min: 15.0,
            max: 120.0
        ),
        MetricConfig(
            id: "UA",
            units: "mg/dL",
            direction: .rangeIsBest,
            min: 2.0,
            max: 10.0,
            idealLow: 3.0,
            idealHigh: 7.0
        ),

        // 肝機能 (5種類)
        MetricConfig(
            id: "AST",
            units: "U/L",
            direction: .lowerIsBetter,
            min: 10.0,
            max: 100.0
        ),
        MetricConfig(
            id: "ALT",
            units: "U/L",
            direction: .lowerIsBetter,
            min: 5.0,
            max: 100.0
        ),
        MetricConfig(
            id: "GGT",
            units: "U/L",
            direction: .lowerIsBetter,
            min: 10.0,
            max: 150.0
        ),
        MetricConfig(
            id: "ALP",
            units: "U/L",
            direction: .rangeIsBest,
            min: 50.0,
            max: 400.0,
            idealLow: 100.0,
            idealHigh: 330.0
        ),
        MetricConfig(
            id: "TBIL",
            units: "mg/dL",
            direction: .rangeIsBest,
            min: 0.2,
            max: 3.0,
            idealLow: 0.3,
            idealHigh: 1.2
        ),

        // タンパク質 (3種類)
        MetricConfig(
            id: "TP",
            units: "g/dL",
            direction: .rangeIsBest,
            min: 5.0,
            max: 9.0,
            idealLow: 6.5,
            idealHigh: 8.2
        ),
        MetricConfig(
            id: "ALB",
            units: "g/dL",
            direction: .rangeIsBest,
            min: 2.5,
            max: 5.5,
            idealLow: 4.0,
            idealHigh: 5.0
        ),
        MetricConfig(
            id: "AG_ratio",
            units: "",
            direction: .rangeIsBest,
            min: 0.8,
            max: 2.5,
            idealLow: 1.2,
            idealHigh: 2.0
        ),

        // 電解質 (3種類)
        MetricConfig(
            id: "Na",
            units: "mEq/L",
            direction: .rangeIsBest,
            min: 130.0,
            max: 150.0,
            idealLow: 136.0,
            idealHigh: 145.0
        ),
        MetricConfig(
            id: "K",
            units: "mEq/L",
            direction: .rangeIsBest,
            min: 2.5,
            max: 6.0,
            idealLow: 3.5,
            idealHigh: 5.0
        ),
        MetricConfig(
            id: "Cl",
            units: "mEq/L",
            direction: .rangeIsBest,
            min: 90.0,
            max: 115.0,
            idealLow: 98.0,
            idealHigh: 108.0
        ),

        // 筋肉・エネルギー (3種類)
        MetricConfig(
            id: "CK",
            units: "U/L",
            direction: .rangeIsBest,
            min: 20.0,
            max: 500.0,
            idealLow: 50.0,
            idealHigh: 250.0
        ),
        MetricConfig(
            id: "LDH",
            units: "U/L",
            direction: .rangeIsBest,
            min: 100.0,
            max: 500.0,
            idealLow: 120.0,
            idealHigh: 240.0
        ),
        MetricConfig(
            id: "ferritin",
            units: "ng/mL",
            direction: .rangeIsBest,
            min: 10.0,
            max: 500.0,
            idealLow: 30.0,
            idealHigh: 250.0
        )
    ]

    // MARK: - HealthKit Metrics (7種類)

    static let healthKitMetrics: [MetricConfig] = [
        // 体組成
        MetricConfig(
            id: "bmi",
            units: "",
            direction: .rangeIsBest,
            min: 15.0,
            max: 40.0,
            idealLow: 18.5,
            idealHigh: 24.9
        ),

        // 心臓・循環器
        MetricConfig(
            id: "hrv",
            units: "ms",
            direction: .higherIsBetter,
            min: 20.0,
            max: 200.0
        ),
        MetricConfig(
            id: "rhr",
            units: "bpm",
            direction: .lowerIsBetter,
            min: 40.0,
            max: 100.0
        ),
        MetricConfig(
            id: "vo2max",
            units: "ml/kg/min",
            direction: .higherIsBetter,
            min: 20.0,
            max: 70.0
        ),

        // 活動量
        MetricConfig(
            id: "dailySteps",
            units: "steps",
            direction: .higherIsBetter,
            min: 0.0,
            max: 20000.0
        ),
        MetricConfig(
            id: "activeCalories",
            units: "kcal",
            direction: .higherIsBetter,
            min: 0.0,
            max: 1500.0
        ),

        // 睡眠
        MetricConfig(
            id: "sleepHours",
            units: "hours",
            direction: .rangeIsBest,
            min: 3.0,
            max: 12.0,
            idealLow: 7.0,
            idealHigh: 9.0
        )
    ]

    // MARK: - Domain Score Configs (4種類)

    /// 代謝力スコア設定
    static let metabolicDomain = DomainScoreConfig(
        id: "metabolic",
        metrics: [
            .init(metricId: "HbA1c", weight: 0.25),
            .init(metricId: "TG", weight: 0.20),
            .init(metricId: "HDL", weight: 0.15),
            .init(metricId: "LDL", weight: 0.15),
            .init(metricId: "bmi", weight: 0.10),
            .init(metricId: "vo2max", weight: 0.10),
            .init(metricId: "activeCalories", weight: 0.05)
        ]
    )

    /// 炎症レベルスコア設定
    static let inflammationDomain = DomainScoreConfig(
        id: "inflammation",
        metrics: [
            .init(metricId: "CRP", weight: 0.40),
            .init(metricId: "AST", weight: 0.15),
            .init(metricId: "ALT", weight: 0.15),
            .init(metricId: "GGT", weight: 0.10),
            .init(metricId: "hrv", weight: 0.10),
            .init(metricId: "sleepHours", weight: 0.10)
        ]
    )

    /// 回復スピードスコア設定
    static let recoveryDomain = DomainScoreConfig(
        id: "recovery",
        metrics: [
            .init(metricId: "CRP", weight: 0.20),
            .init(metricId: "CK", weight: 0.20),
            .init(metricId: "ferritin", weight: 0.15),
            .init(metricId: "hrv", weight: 0.15),
            .init(metricId: "rhr", weight: 0.10),
            .init(metricId: "sleepHours", weight: 0.10),
            .init(metricId: "ALB", weight: 0.10)
        ]
    )

    /// 老化速度スコア設定
    static let agingPaceDomain = DomainScoreConfig(
        id: "agingPace",
        metrics: [
            .init(metricId: "HbA1c", weight: 0.20),
            .init(metricId: "CRP", weight: 0.15),
            .init(metricId: "ALB", weight: 0.15),
            .init(metricId: "CRE", weight: 0.10),
            .init(metricId: "eGFR", weight: 0.10),
            .init(metricId: "hrv", weight: 0.10),
            .init(metricId: "vo2max", weight: 0.10),
            .init(metricId: "bmi", weight: 0.10)
        ]
    )

    /// 全ドメイン設定のリスト
    static let allDomains = [
        metabolicDomain,
        inflammationDomain,
        recoveryDomain,
        agingPaceDomain
    ]
}
