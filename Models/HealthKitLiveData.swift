//
//  HealthKitLiveData.swift
//  AWStest
//
//  HealthKit LIVEセクション用のデータモデル
//

import Foundation

// MARK: - HealthKit Live Data

struct HealthKitLiveData: Codable {
    let hrv: Double?          // 心拍変動 [DUMMY] HealthKit HRVデータに置き換え
    let rhr: Int?            // 安静時心拍数 [DUMMY] HealthKit安静時心拍数に置き換え
    let vo2Max: Double?      // 最大酸素摂取量 [DUMMY] HealthKit VO2Maxに置き換え
    let basalCalories: Int?  // 基礎代謝 [DUMMY] 基礎代謝計算値に置き換え
    let lastUpdated: Date    // 最終更新時刻

    // [DUMMY] テスト用のサンプルデータ生成
    static var sample: HealthKitLiveData {
        HealthKitLiveData(
            hrv: 68.0,    // [DUMMY] 仮のHRV値
            rhr: 52,      // [DUMMY] 仮の安静時心拍数
            vo2Max: 42.3, // [DUMMY] 仮のVO2Max
            basalCalories: 1850, // [DUMMY] 仮の基礎代謝
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
            label: "HRV",
            value: "68", // [DUMMY] 実際のHealthKitデータに置き換え
            unit: "ms",
            trend: .up,
            updateInterval: 3.0
        ),
        HealthKitMetric(
            label: "RHR",
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
