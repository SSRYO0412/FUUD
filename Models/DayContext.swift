//
//  DayContext.swift
//  FUUD
//
//  朝の問診データモデル
//  Phase 6-UI: TodayProgramView用
//

import Foundation

// MARK: - DayContext

/// 今日のコンテキスト情報（朝の問診データ）
struct DayContext {
    /// 睡眠の質
    let sleepQuality: SleepQuality?
    /// エネルギーレベル
    let energyLevel: EnergyLevel?
    /// 食欲レベル
    let appetiteLevel: AppetiteLevel?
    /// ストレスレベル
    let stressLevel: StressLevel?
    /// 特記事項（フリーテキスト）
    let notes: String?
    /// 記録日時
    let recordedAt: Date?

    /// データ未入力かどうか
    var isEmpty: Bool {
        sleepQuality == nil && energyLevel == nil &&
        appetiteLevel == nil && stressLevel == nil
    }

    /// デフォルト（未入力）状態
    static let empty = DayContext(
        sleepQuality: nil,
        energyLevel: nil,
        appetiteLevel: nil,
        stressLevel: nil,
        notes: nil,
        recordedAt: nil
    )
}

// MARK: - Sleep Quality

extension DayContext {
    enum SleepQuality: String, CaseIterable {
        case excellent  // よく眠れた
        case good       // まあまあ
        case fair       // 少し不足
        case poor       // ほとんど眠れなかった

        var displayName: String {
            switch self {
            case .excellent: return "よく眠れた"
            case .good: return "まあまあ"
            case .fair: return "少し不足"
            case .poor: return "ほとんど眠れなかった"
            }
        }

        var icon: String {
            switch self {
            case .excellent: return "moon.zzz.fill"
            case .good: return "moon.fill"
            case .fair: return "moon"
            case .poor: return "moon.haze"
            }
        }

        /// カロリー調整係数（睡眠不足時はやや控えめ）
        var calorieMultiplier: Double {
            switch self {
            case .excellent: return 1.0
            case .good: return 1.0
            case .fair: return 0.97
            case .poor: return 0.95
            }
        }
    }
}

// MARK: - Energy Level

extension DayContext {
    enum EnergyLevel: String, CaseIterable {
        case high       // 元気いっぱい
        case normal     // 普通
        case low        // 少し疲れ気味
        case exhausted  // かなり疲れている

        var displayName: String {
            switch self {
            case .high: return "元気いっぱい"
            case .normal: return "普通"
            case .low: return "少し疲れ気味"
            case .exhausted: return "かなり疲れている"
            }
        }

        var icon: String {
            switch self {
            case .high: return "bolt.fill"
            case .normal: return "bolt"
            case .low: return "bolt.slash"
            case .exhausted: return "battery.0"
            }
        }
    }
}

// MARK: - Appetite Level

extension DayContext {
    enum AppetiteLevel: String, CaseIterable {
        case high       // 食欲旺盛
        case normal     // 普通
        case low        // あまりない
        case none       // ほとんどない

        var displayName: String {
            switch self {
            case .high: return "食欲旺盛"
            case .normal: return "普通"
            case .low: return "あまりない"
            case .none: return "ほとんどない"
            }
        }

        var icon: String {
            switch self {
            case .high: return "fork.knife"
            case .normal: return "fork.knife"
            case .low: return "minus.circle"
            case .none: return "xmark.circle"
            }
        }
    }
}

// MARK: - Stress Level

extension DayContext {
    enum StressLevel: String, CaseIterable {
        case low        // リラックスしている
        case moderate   // 普通
        case high       // ストレスを感じる
        case veryHigh   // とてもストレスを感じる

        var displayName: String {
            switch self {
            case .low: return "リラックスしている"
            case .moderate: return "普通"
            case .high: return "ストレスを感じる"
            case .veryHigh: return "とてもストレスを感じる"
            }
        }

        var icon: String {
            switch self {
            case .low: return "leaf.fill"
            case .moderate: return "circle"
            case .high: return "exclamationmark.triangle"
            case .veryHigh: return "exclamationmark.triangle.fill"
            }
        }
    }
}

// MARK: - DayContext Summary

extension DayContext {
    /// サマリーテキスト（チェックイン済みの場合）
    var summaryText: String? {
        guard !isEmpty else { return nil }

        var parts: [String] = []

        if let sleep = sleepQuality {
            parts.append("睡眠: \(sleep.displayName)")
        }
        if let energy = energyLevel {
            parts.append("エネルギー: \(energy.displayName)")
        }
        if let appetite = appetiteLevel {
            parts.append("食欲: \(appetite.displayName)")
        }
        if let stress = stressLevel {
            parts.append("ストレス: \(stress.displayName)")
        }

        return parts.joined(separator: " / ")
    }

    /// 今日の総合的なカロリー調整係数
    var calorieMultiplier: Double {
        sleepQuality?.calorieMultiplier ?? 1.0
    }
}
