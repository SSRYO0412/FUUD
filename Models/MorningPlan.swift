//
//  MorningPlan.swift
//  FUUD
//
//  朝の問診データモデル（食事予定・運動予定）
//

import Foundation

// MARK: - MorningPlan

/// 今日の食事・運動予定（朝の問診データ）
struct MorningPlan: Codable {
    /// 朝食の予定
    var breakfast: PlannedMealType?
    /// 昼食の予定
    var lunch: PlannedMealType?
    /// 夕食の予定
    var dinner: PlannedMealType?
    /// 運動の予定
    var exercise: ExercisePlan?
    /// 記録日時
    var recordedAt: Date?

    /// データ未入力かどうか
    var isEmpty: Bool {
        breakfast == nil && lunch == nil && dinner == nil && exercise == nil
    }

    /// デフォルト（未入力）状態
    static let empty = MorningPlan(
        breakfast: nil,
        lunch: nil,
        dinner: nil,
        exercise: nil,
        recordedAt: nil
    )

    // MARK: - UserDefaults Storage

    private static let storageKey = "morningPlan"
    private static let dateKey = "morningPlanDate"

    /// 今日のプランを保存
    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
            UserDefaults.standard.set(Date(), forKey: Self.dateKey)
        }
    }

    /// 今日のプランを読み込み（当日分のみ）
    static func loadToday() -> MorningPlan? {
        guard let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date,
              Calendar.current.isDateInToday(savedDate),
              let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(MorningPlan.self, from: data)
    }

    /// 保存されたプランをクリア
    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: dateKey)
    }
}

// MARK: - PlannedMealType

/// 食事予定の種類（朝の問診用）
enum PlannedMealType: String, CaseIterable, Codable {
    case skip           // 食べない
    case homemade       // 自炊
    case eatingOut      // 外食
    case convenience    // コンビニ

    var displayName: String {
        switch self {
        case .skip: return "食べない"
        case .homemade: return "自炊"
        case .eatingOut: return "外食"
        case .convenience: return "コンビニ"
        }
    }

    var icon: String {
        switch self {
        case .skip: return "xmark.circle"
        case .homemade: return "frying.pan"
        case .eatingOut: return "fork.knife"
        case .convenience: return "bag"
        }
    }

    var shortName: String {
        switch self {
        case .skip: return "食べない"
        case .homemade: return "自炊"
        case .eatingOut: return "外食"
        case .convenience: return "コンビニ"
        }
    }
}

// MARK: - ExercisePlan

/// 運動の予定
struct ExercisePlan: Codable, Equatable {
    /// 運動の種類
    var type: ExerciseType
    /// 時間（分）
    var durationMinutes: Int

    /// デフォルト値
    static let `default` = ExercisePlan(type: .none, durationMinutes: 30)
}

// MARK: - ExerciseType

/// 運動の種類
enum ExerciseType: String, CaseIterable, Codable {
    case none       // なし
    case walking    // ウォーキング
    case running    // ランニング
    case gym        // ジム
    case yoga       // ヨガ
    case swimming   // 水泳
    case cycling    // サイクリング
    case other      // その他

    var displayName: String {
        switch self {
        case .none: return "なし"
        case .walking: return "ウォーキング"
        case .running: return "ランニング"
        case .gym: return "ジム"
        case .yoga: return "ヨガ"
        case .swimming: return "水泳"
        case .cycling: return "サイクリング"
        case .other: return "その他"
        }
    }

    var icon: String {
        switch self {
        case .none: return "figure.stand"
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .gym: return "dumbbell"
        case .yoga: return "figure.mind.and.body"
        case .swimming: return "figure.pool.swim"
        case .cycling: return "bicycle"
        case .other: return "sportscourt"
        }
    }
}

// MARK: - MorningPlan Summary

extension MorningPlan {
    /// サマリーテキスト
    var summaryText: String? {
        guard !isEmpty else { return nil }

        var parts: [String] = []

        if let breakfast = breakfast {
            parts.append("朝: \(breakfast.shortName)")
        }
        if let lunch = lunch {
            parts.append("昼: \(lunch.shortName)")
        }
        if let dinner = dinner {
            parts.append("夕: \(dinner.shortName)")
        }
        if let exercise = exercise, exercise.type != .none {
            parts.append("\(exercise.type.displayName) \(exercise.durationMinutes)分")
        }

        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }
}
