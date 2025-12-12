//
//  ParsedMeal.swift
//  FUUD
//
//  AI解析された食事モデル
//

import Foundation

struct ParsedMeal: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var mealType: MealType
    var servings: Int
    var date: Date
    var items: [FoodItem]

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        mealType: MealType = .dinner,
        servings: Int = 1,
        date: Date = Date(),
        items: [FoodItem]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.mealType = mealType
        self.servings = servings
        self.date = date
        self.items = items
    }

    // MARK: - Computed Properties

    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }

    var totalCarbs: Double {
        items.reduce(0) { $0 + $1.carbs }
    }

    var totalProtein: Double {
        items.reduce(0) { $0 + $1.protein }
    }

    var totalFat: Double {
        items.reduce(0) { $0 + $1.fat }
    }

    var carbsPercentage: Double {
        let totalCal = Double(totalCalories)
        guard totalCal > 0 else { return 0 }
        return (totalCarbs * 4 / totalCal) * 100
    }

    var proteinPercentage: Double {
        let totalCal = Double(totalCalories)
        guard totalCal > 0 else { return 0 }
        return (totalProtein * 4 / totalCal) * 100
    }

    var fatPercentage: Double {
        let totalCal = Double(totalCalories)
        guard totalCal > 0 else { return 0 }
        return (totalFat * 9 / totalCal) * 100
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

// MARK: - Meal Type

enum MealType: String, CaseIterable, Codable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"

    var displayName: String {
        switch self {
        case .breakfast: return "朝食"
        case .lunch: return "昼食"
        case .dinner: return "夕食"
        case .snack: return "間食"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.rise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "cup.and.saucer"
        }
    }
}
