//
//  HealthKitDataModels.swift
//  TUUN
//
//  HealthKitデータモデル定義
//

import Foundation
import HealthKit

/// HealthKitから取得した全データを格納するメインモデル
struct HealthKitData: Codable {
    // 体組成系 (4種類)
    var bodyMass: Double?              // 体重 (kg)
    var height: Double?                // 身長 (cm)
    var bodyFatPercentage: Double?     // 体脂肪率 (%)
    var leanBodyMass: Double?          // 除脂肪体重 (kg)

    // 心臓・循環器系 (4種類)
    var restingHeartRate: Double?      // 安静時心拍数 (bpm)
    var vo2Max: Double?                // VO2Max (ml/kg/min)
    var heartRateVariability: Double?  // 心拍変動 SDNN (ms)
    var heartRate: Double?             // 心拍数 (bpm)

    // 活動量系 (3種類)
    var activeEnergyBurned: Double?    // アクティブカロリー (kcal)
    var exerciseTime: Double?          // エクササイズ時間 (分)
    var stepCount: Double?             // 歩数 (steps)

    // 移動距離系 (2種類)
    var walkingRunningDistance: Double? // 歩行・ランニング距離 (km)
    var cyclingDistance: Double?       // サイクリング距離 (km)

    // 睡眠分析
    var sleepData: [SleepSample]?      // 睡眠データ

    // ワークアウト
    var workouts: [WorkoutSample]?     // ワークアウトデータ

    var lastUpdated: Date

    init() {
        self.lastUpdated = Date()
    }
}

/// 睡眠サンプルデータ
struct SleepSample: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let value: SleepCategory
    let duration: TimeInterval  // 秒単位

    enum SleepCategory: Int, Codable {
        case inBed = 0
        case asleep = 1
        case awake = 2
        case core = 3
        case deep = 4
        case rem = 5

        var displayName: String {
            switch self {
            case .inBed: return "ベッド内"
            case .asleep: return "睡眠中"
            case .awake: return "覚醒"
            case .core: return "コア睡眠"
            case .deep: return "深い睡眠"
            case .rem: return "レム睡眠"
            }
        }
    }

    init(id: UUID = UUID(), startDate: Date, endDate: Date, value: SleepCategory) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.value = value
        self.duration = endDate.timeIntervalSince(startDate)
    }
}

/// ワークアウトサンプルデータ
struct WorkoutSample: Codable, Identifiable {
    let id: UUID
    let workoutType: WorkoutType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval          // 秒単位
    let totalEnergyBurned: Double?      // 消費カロリー (kcal)
    let totalDistance: Double?          // 距離 (m)
    let metadata: [String: String]?     // メタデータ

    enum WorkoutType: Int, Codable {
        case running = 37
        case cycling = 13
        case walking = 52
        case swimming = 46
        case yoga = 57
        case strengthTraining = 44
        case other = 3000

        var displayName: String {
            switch self {
            case .running: return "ランニング"
            case .cycling: return "サイクリング"
            case .walking: return "ウォーキング"
            case .swimming: return "水泳"
            case .yoga: return "ヨガ"
            case .strengthTraining: return "筋力トレーニング"
            case .other: return "その他"
            }
        }

        var icon: String {
            switch self {
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            case .walking: return "figure.walk"
            case .swimming: return "figure.pool.swim"
            case .yoga: return "figure.yoga"
            case .strengthTraining: return "dumbbell"
            case .other: return "figure.mixed.cardio"
            }
        }
    }

    init(id: UUID = UUID(), workoutType: WorkoutType, startDate: Date, endDate: Date,
         totalEnergyBurned: Double? = nil, totalDistance: Double? = nil, metadata: [String: String]? = nil) {
        self.id = id
        self.workoutType = workoutType
        self.startDate = startDate
        self.endDate = endDate
        self.duration = endDate.timeIntervalSince(startDate)
        self.totalEnergyBurned = totalEnergyBurned
        self.totalDistance = totalDistance
        self.metadata = metadata
    }
}

/// HealthKitデータ取得の結果ステータス
enum HealthKitAuthorizationStatus {
    case notDetermined    // 未確認
    case denied          // 拒否
    case authorized      // 許可済み
    case restricted      // 制限あり

    var description: String {
        switch self {
        case .notDetermined: return "未確認"
        case .denied: return "拒否されました"
        case .authorized: return "許可済み"
        case .restricted: return "制限があります"
        }
    }
}
