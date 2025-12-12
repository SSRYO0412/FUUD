//
//  OnboardingData.swift
//  FUUD
//
//  Lifesum風オンボーディング データモデル
//

import Foundation

// MARK: - Onboarding Step

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case goal
    case gender
    case birthdate
    case height
    case weight
    case targetWeight
    case auth
    case loading
    case planReady
    case premium
    case complete
    case notification

    var progressIndex: Int? {
        // プログレスバーに表示するステップのみ
        switch self {
        case .goal: return 0
        case .gender: return 1
        case .birthdate: return 2
        case .height: return 3
        case .weight: return 4
        case .targetWeight: return 5
        default: return nil
        }
    }

    static var progressStepCount: Int { 6 }

    var encouragementMessage: String {
        switch self {
        case .welcome: return ""
        case .goal: return "あなたのことを教えてください！"
        case .gender: return "いいですね、続けましょう"
        case .birthdate: return "了解です"
        case .height: return "順調ですね！"
        case .weight: return "OK、続けましょう"
        case .targetWeight: return "あと少しです！"
        case .auth: return "最後のステップです！"
        default: return ""
        }
    }
}

// MARK: - Onboarding Goal

enum OnboardingGoal: String, Codable, CaseIterable {
    case loseWeight = "lose"
    case maintainWeight = "maintain"
    case gainWeight = "gain"

    var displayName: String {
        switch self {
        case .loseWeight: return "体重を減らす"
        case .maintainWeight: return "体重を維持する"
        case .gainWeight: return "体重を増やす"
        }
    }

    var needsTargetWeight: Bool {
        return self != .maintainWeight
    }
}

// MARK: - Gender

enum Gender: String, Codable, CaseIterable {
    case female = "female"
    case male = "male"

    var displayName: String {
        switch self {
        case .female: return "女性"
        case .male: return "男性"
        }
    }
}

// MARK: - Unit Preference

enum WeightUnit: String, Codable {
    case kg = "kg"
    case lbs = "lbs"

    var displayName: String {
        return rawValue
    }

    func convert(_ value: Double, to target: WeightUnit) -> Double {
        if self == target { return value }
        switch (self, target) {
        case (.kg, .lbs): return value * 2.20462
        case (.lbs, .kg): return value / 2.20462
        default: return value
        }
    }
}

enum HeightUnit: String, Codable {
    case cm = "cm"
    case ftIn = "ft/in"

    var displayName: String {
        return rawValue
    }
}

// MARK: - Onboarding User Data

struct OnboardingUserData: Codable {
    var goal: OnboardingGoal?
    var gender: Gender?
    var birthdate: Date?
    var heightCm: Double?
    var weightKg: Double?
    var targetWeightKg: Double?
    var firstName: String?
    var email: String?

    // Unit preferences (UI用、保存はmetric)
    var preferredWeightUnit: WeightUnit = .kg
    var preferredHeightUnit: HeightUnit = .cm

    // Computed
    var age: Int? {
        guard let birthdate = birthdate else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: birthdate, to: now)
        return components.year
    }

    var bmi: Double? {
        guard let height = heightCm, let weight = weightKg, height > 0 else { return nil }
        let heightM = height / 100
        return weight / (heightM * heightM)
    }

    // Validation
    var isBasicInfoComplete: Bool {
        return goal != nil &&
               gender != nil &&
               birthdate != nil &&
               heightCm != nil &&
               weightKg != nil
    }

    var isTargetWeightRequired: Bool {
        return goal?.needsTargetWeight ?? false
    }

    var isTargetWeightComplete: Bool {
        if !isTargetWeightRequired { return true }
        return targetWeightKg != nil
    }
}

// MARK: - Nutrition Plan (計算結果)

struct NutritionPlan: Codable {
    let calories: Int
    let carbsPercentage: Int
    let fatPercentage: Int
    let proteinPercentage: Int
    let lifeScore: Int

    var carbsGrams: Int {
        return Int(Double(calories) * Double(carbsPercentage) / 100 / 4)
    }

    var fatGrams: Int {
        return Int(Double(calories) * Double(fatPercentage) / 100 / 9)
    }

    var proteinGrams: Int {
        return Int(Double(calories) * Double(proteinPercentage) / 100 / 4)
    }

    // デフォルトプラン計算
    static func calculate(for userData: OnboardingUserData) -> NutritionPlan {
        // Harris-Benedict式 (簡易版)
        var bmr: Double = 1500

        if let weight = userData.weightKg,
           let height = userData.heightCm,
           let age = userData.age {

            if userData.gender == .male {
                bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
            } else {
                bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
            }
        }

        // 活動レベル（デフォルト: 軽い活動）
        let activityMultiplier = 1.375
        var tdee = bmr * activityMultiplier

        // 目標に応じた調整
        switch userData.goal {
        case .loseWeight:
            tdee -= 500 // -500kcal/day = -0.5kg/week
        case .gainWeight:
            tdee += 300 // +300kcal/day
        case .maintainWeight:
            break
        case .none:
            break
        }

        let calories = max(1200, Int(tdee))

        // マクロ比率（バランス型）
        let proteinPercentage = 20
        let fatPercentage = 30
        let carbsPercentage = 50

        // ライフスコア（初期値）
        let lifeScore = 110

        return NutritionPlan(
            calories: calories,
            carbsPercentage: carbsPercentage,
            fatPercentage: fatPercentage,
            proteinPercentage: proteinPercentage,
            lifeScore: lifeScore
        )
    }
}

// MARK: - Goal Achievement Item

struct GoalAchievementItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String

    static let defaultItems: [GoalAchievementItem] = [
        GoalAchievementItem(
            icon: "goal_flower",
            title: "週間ライフスコアと",
            description: "パーソナルアドバイスを受け取る"
        ),
        GoalAchievementItem(
            icon: "goal_pear",
            title: "食事を記録",
            description: ""
        ),
        GoalAchievementItem(
            icon: "goal_avocado",
            title: "1日のカロリー目標に",
            description: "従う"
        ),
        GoalAchievementItem(
            icon: "goal_bars",
            title: "炭水化物、タンパク質、",
            description: "脂質、食物繊維のバランスを整える"
        ),
        GoalAchievementItem(
            icon: "goal_water",
            title: "水分補給を",
            description: "追跡する"
        )
    ]
}
