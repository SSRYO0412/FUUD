//
//  FoodItem.swift
//  FUUD
//
//  AI解析された食材モデル
//

import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var unit: String
    var calories: Int
    var carbs: Double
    var protein: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var sodium: Double

    // 食品評価用
    var isProteinRich: Bool { protein > 20 }
    var isLowCarb: Bool { carbs < 10 }
    var isLowSugar: Bool { sugar < 5 }
    var isLowSodium: Bool { sodium < 200 }
    var isCalorieDense: Bool { calories > 250 }
    var isHighSaturatedFat: Bool { fat > 15 }
    var isProcessed: Bool  // 加工食品フラグ

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: String,
        calories: Int,
        carbs: Double,
        protein: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        sodium: Double = 0,
        isProcessed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.isProcessed = isProcessed
    }

    // PFC比率計算
    var carbsPercentage: Double {
        let totalCalories = Double(calories)
        guard totalCalories > 0 else { return 0 }
        return (carbs * 4 / totalCalories) * 100
    }

    var proteinPercentage: Double {
        let totalCalories = Double(calories)
        guard totalCalories > 0 else { return 0 }
        return (protein * 4 / totalCalories) * 100
    }

    var fatPercentage: Double {
        let totalCalories = Double(calories)
        guard totalCalories > 0 else { return 0 }
        return (fat * 9 / totalCalories) * 100
    }

    // 量に応じたカロリー計算
    func caloriesFor(amount newAmount: Double) -> Int {
        guard amount > 0 else { return 0 }
        return Int(Double(calories) * newAmount / amount)
    }
}

// MARK: - Unit Options

enum FoodUnit: String, CaseIterable {
    case gram = "g"
    case piece = "個"
    case serving = "人前"
    case cup = "杯"
    case tablespoon = "大さじ"
    case teaspoon = "小さじ"
    case slice = "枚"
    case pack = "パック"

    var displayName: String {
        switch self {
        case .gram: return "グラム"
        case .piece: return "個"
        case .serving: return "人前"
        case .cup: return "杯"
        case .tablespoon: return "大さじ"
        case .teaspoon: return "小さじ"
        case .slice: return "枚"
        case .pack: return "パック"
        }
    }
}

// MARK: - API Response Mapping

extension FoodItem {
    /// ParsedFoodItem（API レスポンス）から FoodItem を生成
    init(from parsed: ParsedFoodItem) {
        self.init(
            name: parsed.name,
            amount: parsed.grams,
            unit: parsed.servingDescription ?? "g",
            calories: Int(parsed.calories.rounded()),
            carbs: parsed.carbs,
            protein: parsed.protein,
            fat: parsed.fat,
            fiber: parsed.fiber ?? 0,
            sugar: 0,  // API未提供、デフォルト0
            sodium: parsed.sodium ?? 0,
            isProcessed: parsed.source == "estimated"
        )
    }
}
