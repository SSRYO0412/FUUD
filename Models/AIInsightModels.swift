//
//  AIInsightModels.swift
//  TUUN
//
//  Created by Claude on 2025/12/01.
//  TUUNING Intelligence API用モデル定義
//

import Foundation

// MARK: - API Response Models

/// TUUNING Intelligence APIのレスポンス
struct AIInsightResponse: Codable {
    let timeSlot: String
    let mainComment: String
    let dataReference: String
    let food: ActionRecommendation
    let activity: ActionRecommendation
    let nextUpdate: String
    let timestamp: String
}

/// 食事・運動のレコメンド
struct ActionRecommendation: Codable {
    let icon: String
    let title: String
    let recommendation: String
    let benefit: String
}

// MARK: - API Request Models

/// TUUNING Intelligence APIへのリクエスト
struct IntelligenceRequest: Encodable {
    let userId: String
    let timeSlot: String
    let bloodData: IntelligenceBloodData?
    let vitalData: IntelligenceVitalData?
    let geneData: IntelligenceGeneData?
}

/// 血液データ（10項目）
struct IntelligenceBloodData: Codable {
    let hbA1c: Double?          // HbA1c
    let fpg: Double?            // 空腹時血糖
    let tg: Double?             // 中性脂肪
    let hdl: Double?            // HDLコレステロール
    let ldl: Double?            // LDLコレステロール
    let crp: Double?            // CRP
    let ferritin: Double?       // フェリチン
    let ast: Double?            // AST
    let ua: Double?             // 尿酸
    let ins: Double?            // インスリン

    enum CodingKeys: String, CodingKey {
        case hbA1c = "HbA1c"
        case fpg = "FPG"
        case tg = "TG"
        case hdl = "HDL"
        case ldl = "LDL"
        case crp = "CRP"
        case ferritin = "Ferritin"
        case ast = "AST"
        case ua = "UA"
        case ins = "INS"
    }
}

/// HealthKitデータ（10項目）
struct IntelligenceVitalData: Codable {
    let hrv: Double?                    // 心拍変動
    let restingHeartRate: Double?       // 安静時心拍
    let vo2Max: Double?                 // VO2Max
    let sleepTotal: Double?             // 睡眠時間（時間）
    let sleepDeep: Double?              // 深い睡眠（時間）
    let sleepRem: Double?               // REM睡眠（時間）
    let stepCount: Double?              // 歩数
    let activeEnergyBurned: Double?     // アクティブカロリー
    let recentWorkout: String?          // 直近ワークアウト（種類）
    let bodyMass: Double?               // 体重
}

/// 遺伝子データ（5項目）
struct IntelligenceGeneData: Codable {
    let caffeine: GeneMarkerResult?         // カフェイン代謝
    let circadianRhythm: GeneMarkerResult?  // 概日リズム
    let highFatDiet: GeneMarkerResult?      // 高脂肪ダイエット効果
    let highProteinDiet: GeneMarkerResult?  // 高たんぱくダイエット効果
    let sleepDepth: GeneMarkerResult?       // 眠りの深さ

    enum CodingKeys: String, CodingKey {
        case caffeine = "カフェイン代謝"
        case circadianRhythm = "概日リズム"
        case highFatDiet = "高脂肪ダイエット効果"
        case highProteinDiet = "高たんぱくダイエット効果"
        case sleepDepth = "眠りの深さ"
    }
}

/// 遺伝子マーカーの結果
struct GeneMarkerResult: Codable {
    let score: Int              // -100 ~ +100
    let scoreLevel: String      // "高い", "やや高い", "普通", "やや低い", "低い"
    let protective: Int         // 保護因子数
    let risk: Int              // リスク因子数
}

// MARK: - Debug Models

/// デバッグ用：収集した全データ
struct IntelligenceDebugData {
    let bloodData: IntelligenceBloodData?
    let vitalData: IntelligenceVitalData?
    let geneData: IntelligenceGeneData?
    let timeSlot: String
    let timestamp: Date

    /// JSON形式でエクスポート
    func toJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        struct DebugOutput: Encodable {
            let timeSlot: String
            let timestamp: String
            let bloodData: IntelligenceBloodData?
            let vitalData: IntelligenceVitalData?
            let geneData: IntelligenceGeneData?
        }

        let output = DebugOutput(
            timeSlot: timeSlot,
            timestamp: ISO8601DateFormatter().string(from: timestamp),
            bloodData: bloodData,
            vitalData: vitalData,
            geneData: geneData
        )

        if let data = try? encoder.encode(output),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{}"
    }
}

// MARK: - Time Slot Extension

extension TimeSlot {
    /// 次の更新時刻を取得
    var nextUpdateTime: String {
        switch self {
        case .earlyMorning:
            return "8:00"
        case .morning:
            return "12:00"
        case .lunch:
            return "14:00"
        case .afternoon:
            return "18:00"
        case .evening:
            return "21:00"
        case .night:
            return "5:00"
        }
    }

    /// 日本語表示名
    var displayName: String {
        switch self {
        case .earlyMorning:
            return "早朝"
        case .morning:
            return "午前"
        case .lunch:
            return "昼食"
        case .afternoon:
            return "午後"
        case .evening:
            return "夕方"
        case .night:
            return "夜間"
        }
    }
}
