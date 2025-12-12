//
//  HealthKitLiveData.swift
//  AWStest
//
//  HealthKit LIVEセクション用のデータモデル
//

import Foundation

// MARK: - HealthKit Live Data

struct HealthKitLiveData: Codable {
    let hrv: Double?          // 心拍変動 (HealthKit HRV SDNN)
    let rhr: Int?            // 安静時心拍数 (HealthKit Resting Heart Rate)
    let vo2Max: Double?      // 最大酸素摂取量 (HealthKit VO2Max)
    let basalCalories: Int?  // 基礎代謝 (計算値: 体重と年齢から推定)
    let lastUpdated: Date    // 最終更新時刻

    /// HealthKitServiceから実データを生成
    static func fromHealthKitService() -> HealthKitLiveData {
        let healthService = HealthKitService.shared
        guard let healthData = healthService.healthData else {
            // データがない場合はサンプルデータを返す
            return sample
        }

        // 基礎代謝の計算 (Harris-Benedict式の簡易版)
        // 男性: 66 + (13.7 × 体重kg) + (5.0 × 身長cm) - (6.8 × 年齢)
        // 女性: 655 + (9.6 × 体重kg) + (1.8 × 身長cm) - (4.7 × 年齢)
        // ここでは簡易的に体重ベースで推定 (性別・年齢不明のため)
        var basalCal: Int? = nil
        if let bodyMass = healthData.bodyMass {
            // 簡易計算: 体重 × 22 (大まかな基礎代謝の目安)
            basalCal = Int(bodyMass * 22)
        }

        return HealthKitLiveData(
            hrv: healthData.heartRateVariability,
            rhr: healthData.restingHeartRate.map { Int($0) },
            vo2Max: healthData.vo2Max,
            basalCalories: basalCal,
            lastUpdated: healthData.lastUpdated
        )
    }

    // テスト用のサンプルデータ生成 (HealthKitデータがない場合のフォールバック)
    static var sample: HealthKitLiveData {
        HealthKitLiveData(
            hrv: 68.0,
            rhr: 52,
            vo2Max: 42.3,
            basalCalories: 1850,
            lastUpdated: Date()
        )
    }
}

// MARK: - Metric Trend

enum MetricTrend: String, Codable {
    case up = "↑"
    case down = "↓"
    case neutral = "→"

    var color: String {
        switch self {
        case .up: return "00C853"    // 緑
        case .down: return "0088CC"  // 青
        case .neutral: return "9CA3AF" // グレー
        }
    }
}

// MARK: - HealthKit Metric

struct HealthKitMetric {
    let label: String
    let value: String
    let unit: String
    let trend: MetricTrend
    let updateInterval: TimeInterval

    // [DUMMY] テスト用のサンプルメトリクス
    static let samples: [HealthKitMetric] = [
        HealthKitMetric(
            label: "心拍変動",
            value: "68", // [DUMMY] 実際のHealthKitデータに置き換え
            unit: "ms",
            trend: .up,
            updateInterval: 3.0
        ),
        HealthKitMetric(
            label: "安静時心拍数",
            value: "52", // [DUMMY] 実際のHealthKitデータに置き換え
            unit: "bpm",
            trend: .down,
            updateInterval: 3.0
        ),
        HealthKitMetric(
            label: "VO₂max",
            value: "42.3", // [DUMMY] 実際のHealthKitデータに置き換え
            unit: "",
            trend: .neutral,
            updateInterval: 30.0
        ),
        HealthKitMetric(
            label: "Burn Cal",
            value: "1,850", // [DUMMY] 実際の消費カロリー計算値に置き換え
            unit: "",
            trend: .neutral,
            updateInterval: 60.0
        )
    ]
}
