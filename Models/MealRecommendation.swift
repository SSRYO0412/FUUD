//
//  MealRecommendation.swift
//  FUUD
//
//  食事レコメンドモデル + 静的生成ロジック
//  Phase 6-UI: TodayProgramView用
//

import Foundation
import SwiftUI

// MARK: - Meal Type

enum MealTime: String, CaseIterable {
    case breakfast
    case lunch
    case dinner

    var displayName: String {
        switch self {
        case .breakfast: return "朝食"
        case .lunch: return "昼食"
        case .dinner: return "夕食"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        }
    }

    /// カロリー配分割合
    var calorieRatio: Double {
        switch self {
        case .breakfast: return 0.25
        case .lunch: return 0.40
        case .dinner: return 0.35
        }
    }
}

// MARK: - Meal Recommendation

struct MealRecommendation: Identifiable {
    let id = UUID()
    let mealTime: MealTime
    let title: String
    let description: String
    let calories: Int
    let protein: Int
    let fat: Int
    let carbs: Int
    let tags: [String]
    let tips: String?

    /// PFC合計が適正か
    var isPFCBalanced: Bool {
        let totalPFC = protein * 4 + fat * 9 + carbs * 4
        let diff = abs(totalPFC - calories)
        return diff < 50  // 50kcal以内の誤差は許容
    }
}

// MARK: - Daily Meal Plan

struct DailyMealPlan {
    let date: Date
    let meals: [MealRecommendation]
    let totalCalories: Int
    let totalProtein: Int
    let totalFat: Int
    let totalCarbs: Int
    let programContext: String?

    var breakfastMeal: MealRecommendation? {
        meals.first { $0.mealTime == .breakfast }
    }

    var lunchMeal: MealRecommendation? {
        meals.first { $0.mealTime == .lunch }
    }

    var dinnerMeal: MealRecommendation? {
        meals.first { $0.mealTime == .dinner }
    }
}

// MARK: - Meal Recommendation Generator

/// 静的ルールベースの食事レコメンド生成
struct MealRecommendationGenerator {

    /// プログラムとPFC目標に基づいて1日の食事プランを生成
    static func generate(
        targetCalories: Int,
        pfc: PFCBalance,
        program: DietProgram?,
        dayContext: DayContext?
    ) -> DailyMealPlan {

        // DayContextによる調整
        let adjustedCalories = Int(Double(targetCalories) * (dayContext?.calorieMultiplier ?? 1.0))

        // 各食事のカロリー計算
        let breakfastCalories = Int(Double(adjustedCalories) * MealTime.breakfast.calorieRatio)
        let lunchCalories = Int(Double(adjustedCalories) * MealTime.lunch.calorieRatio)
        let dinnerCalories = Int(Double(adjustedCalories) * MealTime.dinner.calorieRatio)

        // プログラムカテゴリに基づくレコメンド生成
        let category = program?.category ?? .balanced
        let meals = generateMeals(
            category: category,
            breakfastCalories: breakfastCalories,
            lunchCalories: lunchCalories,
            dinnerCalories: dinnerCalories,
            pfc: pfc
        )

        return DailyMealPlan(
            date: Date(),
            meals: meals,
            totalCalories: adjustedCalories,
            totalProtein: pfc.proteinGrams(for: adjustedCalories),
            totalFat: pfc.fatGrams(for: adjustedCalories),
            totalCarbs: pfc.carbsGrams(for: adjustedCalories),
            programContext: program?.nameJa
        )
    }

    // MARK: - Private Helpers

    private static func generateMeals(
        category: ProgramCategory,
        breakfastCalories: Int,
        lunchCalories: Int,
        dinnerCalories: Int,
        pfc: PFCBalance
    ) -> [MealRecommendation] {

        switch category {
        case .balanced:
            return generateBalancedMeals(
                breakfastCalories: breakfastCalories,
                lunchCalories: lunchCalories,
                dinnerCalories: dinnerCalories,
                pfc: pfc
            )
        case .highProtein:
            return generateHighProteinMeals(
                breakfastCalories: breakfastCalories,
                lunchCalories: lunchCalories,
                dinnerCalories: dinnerCalories,
                pfc: pfc
            )
        case .lowCarb:
            return generateLowCarbMeals(
                breakfastCalories: breakfastCalories,
                lunchCalories: lunchCalories,
                dinnerCalories: dinnerCalories,
                pfc: pfc
            )
        case .fasting:
            return generateFastingMeals(
                lunchCalories: lunchCalories,
                dinnerCalories: dinnerCalories,
                pfc: pfc
            )
        case .biohacking:
            return generateBiohackingMeals(
                breakfastCalories: breakfastCalories,
                lunchCalories: lunchCalories,
                dinnerCalories: dinnerCalories,
                pfc: pfc
            )
        }
    }

    // MARK: - Balanced Meals

    private static func generateBalancedMeals(
        breakfastCalories: Int,
        lunchCalories: Int,
        dinnerCalories: Int,
        pfc: PFCBalance
    ) -> [MealRecommendation] {
        [
            MealRecommendation(
                mealTime: .breakfast,
                title: "和定食（ご飯・味噌汁・焼き魚）",
                description: "バランスの取れた和朝食で1日をスタート",
                calories: breakfastCalories,
                protein: pfc.proteinGrams(for: breakfastCalories),
                fat: pfc.fatGrams(for: breakfastCalories),
                carbs: pfc.carbsGrams(for: breakfastCalories),
                tags: ["和食", "バランス"],
                tips: "味噌汁で発酵食品も摂取できます"
            ),
            MealRecommendation(
                mealTime: .lunch,
                title: "鶏むね肉のサラダ定食",
                description: "タンパク質と野菜をしっかり摂取",
                calories: lunchCalories,
                protein: pfc.proteinGrams(for: lunchCalories),
                fat: pfc.fatGrams(for: lunchCalories),
                carbs: pfc.carbsGrams(for: lunchCalories),
                tags: ["高タンパク", "野菜たっぷり"],
                tips: "ドレッシングはオリーブオイルベースがおすすめ"
            ),
            MealRecommendation(
                mealTime: .dinner,
                title: "豆腐と野菜の炒め物",
                description: "消化に優しい夕食で体を休める準備",
                calories: dinnerCalories,
                protein: pfc.proteinGrams(for: dinnerCalories),
                fat: pfc.fatGrams(for: dinnerCalories),
                carbs: pfc.carbsGrams(for: dinnerCalories),
                tags: ["低GI", "植物性タンパク"],
                tips: "就寝3時間前までに食べ終えましょう"
            )
        ]
    }

    // MARK: - High Protein Meals

    private static func generateHighProteinMeals(
        breakfastCalories: Int,
        lunchCalories: Int,
        dinnerCalories: Int,
        pfc: PFCBalance
    ) -> [MealRecommendation] {
        [
            MealRecommendation(
                mealTime: .breakfast,
                title: "卵3個のスクランブルエッグ＋ヨーグルト",
                description: "朝からタンパク質をしっかり摂取",
                calories: breakfastCalories,
                protein: pfc.proteinGrams(for: breakfastCalories),
                fat: pfc.fatGrams(for: breakfastCalories),
                carbs: pfc.carbsGrams(for: breakfastCalories),
                tags: ["高タンパク", "卵"],
                tips: "ギリシャヨーグルトだとタンパク質がさらにアップ"
            ),
            MealRecommendation(
                mealTime: .lunch,
                title: "グリルチキンブレスト＋玄米",
                description: "筋肉の維持・成長に最適な高タンパクランチ",
                calories: lunchCalories,
                protein: pfc.proteinGrams(for: lunchCalories),
                fat: pfc.fatGrams(for: lunchCalories),
                carbs: pfc.carbsGrams(for: lunchCalories),
                tags: ["筋肉", "高タンパク"],
                tips: "鶏むね肉200gでタンパク質約45g"
            ),
            MealRecommendation(
                mealTime: .dinner,
                title: "鮭のホイル焼き＋納豆",
                description: "良質な脂質とタンパク質で体を回復",
                calories: dinnerCalories,
                protein: pfc.proteinGrams(for: dinnerCalories),
                fat: pfc.fatGrams(for: dinnerCalories),
                carbs: pfc.carbsGrams(for: dinnerCalories),
                tags: ["オメガ3", "発酵食品"],
                tips: "納豆は腸内環境も整えます"
            )
        ]
    }

    // MARK: - Low Carb Meals

    private static func generateLowCarbMeals(
        breakfastCalories: Int,
        lunchCalories: Int,
        dinnerCalories: Int,
        pfc: PFCBalance
    ) -> [MealRecommendation] {
        [
            MealRecommendation(
                mealTime: .breakfast,
                title: "アボカドエッグ＋ベーコン",
                description: "糖質を抑えた脂質リッチな朝食",
                calories: breakfastCalories,
                protein: pfc.proteinGrams(for: breakfastCalories),
                fat: pfc.fatGrams(for: breakfastCalories),
                carbs: pfc.carbsGrams(for: breakfastCalories),
                tags: ["低糖質", "良質な脂質"],
                tips: "アボカドはカリウムも豊富"
            ),
            MealRecommendation(
                mealTime: .lunch,
                title: "牛肉のステーキ＋野菜サラダ",
                description: "炭水化物なしでも満足感のあるランチ",
                calories: lunchCalories,
                protein: pfc.proteinGrams(for: lunchCalories),
                fat: pfc.fatGrams(for: lunchCalories),
                carbs: pfc.carbsGrams(for: lunchCalories),
                tags: ["ケト", "肉"],
                tips: "葉物野菜でボリュームアップ"
            ),
            MealRecommendation(
                mealTime: .dinner,
                title: "豚しゃぶ＋ごま豆腐",
                description: "消化に優しい低糖質ディナー",
                calories: dinnerCalories,
                protein: pfc.proteinGrams(for: dinnerCalories),
                fat: pfc.fatGrams(for: dinnerCalories),
                carbs: pfc.carbsGrams(for: dinnerCalories),
                tags: ["低糖質", "しゃぶしゃぶ"],
                tips: "ポン酢は糖質控えめ"
            )
        ]
    }

    // MARK: - Fasting Meals (16:8)

    private static func generateFastingMeals(
        lunchCalories: Int,
        dinnerCalories: Int,
        pfc: PFCBalance
    ) -> [MealRecommendation] {
        // 朝食なし（断食中）
        let adjustedLunch = Int(Double(lunchCalories) * 1.15)
        let adjustedDinner = Int(Double(dinnerCalories) * 1.15)

        return [
            MealRecommendation(
                mealTime: .breakfast,
                title: "断食中（水・お茶・ブラックコーヒーOK）",
                description: "12:00まで固形物は控えましょう",
                calories: 0,
                protein: 0,
                fat: 0,
                carbs: 0,
                tags: ["断食", "16:8"],
                tips: "空腹感が強い場合はミネラルウォーターを"
            ),
            MealRecommendation(
                mealTime: .lunch,
                title: "玄米おにぎり＋鶏むね肉サラダ",
                description: "断食明けは消化の良いものからスタート",
                calories: adjustedLunch,
                protein: pfc.proteinGrams(for: adjustedLunch),
                fat: pfc.fatGrams(for: adjustedLunch),
                carbs: pfc.carbsGrams(for: adjustedLunch),
                tags: ["断食明け", "消化しやすい"],
                tips: "ゆっくり噛んで食べましょう"
            ),
            MealRecommendation(
                mealTime: .dinner,
                title: "魚の煮付け＋野菜たっぷり味噌汁",
                description: "20:00までに食べ終えましょう",
                calories: adjustedDinner,
                protein: pfc.proteinGrams(for: adjustedDinner),
                fat: pfc.fatGrams(for: adjustedDinner),
                carbs: pfc.carbsGrams(for: adjustedDinner),
                tags: ["和食", "発酵食品"],
                tips: "夕食は軽めでも断食時間を守ることが大切"
            )
        ]
    }

    // MARK: - Biohacking Meals

    private static func generateBiohackingMeals(
        breakfastCalories: Int,
        lunchCalories: Int,
        dinnerCalories: Int,
        pfc: PFCBalance
    ) -> [MealRecommendation] {
        [
            MealRecommendation(
                mealTime: .breakfast,
                title: "MCTオイルコーヒー＋プロテイン",
                description: "ケトン体生成を促進する朝食",
                calories: breakfastCalories,
                protein: pfc.proteinGrams(for: breakfastCalories),
                fat: pfc.fatGrams(for: breakfastCalories),
                carbs: pfc.carbsGrams(for: breakfastCalories),
                tags: ["ケトン", "MCT"],
                tips: "MCTオイルは小さじ1から始めましょう"
            ),
            MealRecommendation(
                mealTime: .lunch,
                title: "サーモンボウル＋アボカド＋キヌア",
                description: "オメガ3と抗酸化成分で脳機能をサポート",
                calories: lunchCalories,
                protein: pfc.proteinGrams(for: lunchCalories),
                fat: pfc.fatGrams(for: lunchCalories),
                carbs: pfc.carbsGrams(for: lunchCalories),
                tags: ["脳活性", "オメガ3"],
                tips: "ターメリックを加えると抗炎症効果アップ"
            ),
            MealRecommendation(
                mealTime: .dinner,
                title: "牧草牛ステーキ＋発酵野菜",
                description: "腸-脳軸をサポートする夕食",
                calories: dinnerCalories,
                protein: pfc.proteinGrams(for: dinnerCalories),
                fat: pfc.fatGrams(for: dinnerCalories),
                carbs: pfc.carbsGrams(for: dinnerCalories),
                tags: ["腸活", "グラスフェッド"],
                tips: "キムチやザワークラウトで腸内環境改善"
            )
        ]
    }
}
