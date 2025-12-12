//
//  MealLogListSection.swift
//  FUUD
//
//  Lifesum風の食事ログリストセクション
//

import SwiftUI

struct MealLogListSection: View {
    @StateObject private var mealService = MealLogService.shared

    // Group meals by type
    private var groupedMeals: [(mealType: String, meals: [MealEntry])] {
        let mealOrder = ["dinner", "lunch", "breakfast", "snack"]

        // Group by meal type
        var grouped: [String: [MealEntry]] = [:]
        for meal in mealService.todayMeals {
            let type = meal.mealType ?? "other"
            grouped[type, default: []].append(meal)
        }

        // Sort by meal order (dinner first for Lifesum style - most recent at top)
        return mealOrder.compactMap { type in
            guard let meals = grouped[type], !meals.isEmpty else { return nil }
            return (mealType: type, meals: meals)
        }
    }

    var body: some View {
        VStack(spacing: VirgilSpacing.sm) {
            if mealService.todayMeals.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Meal list
                ForEach(groupedMeals, id: \.mealType) { group in
                    ForEach(group.meals) { meal in
                        MealLogCard(meal: meal, mealType: group.mealType)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: VirgilSpacing.sm) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 32))
                .foregroundColor(.virgilTextSecondary.opacity(0.5))

            Text("今日の食事を記録しましょう")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VirgilSpacing.xl)
        .liquidGlassCard()
    }
}

// MARK: - Meal Log Card

struct MealLogCard: View {
    let meal: MealEntry
    let mealType: String

    private var mealTypeDisplayName: String {
        switch mealType {
        case "breakfast": return "Breakfast"
        case "lunch": return "Lunch"
        case "dinner": return "Dinner"
        case "snack": return "Snack"
        default: return "Meal"
        }
    }

    private var mealTypeIcon: String {
        switch mealType {
        case "breakfast": return "sun.horizon.fill"
        case "lunch": return "sun.max.fill"
        case "dinner": return "moon.stars.fill"
        case "snack": return "leaf.fill"
        default: return "fork.knife"
        }
    }

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            // Food image placeholder (circle with icon)
            ZStack {
                Circle()
                    .fill(mealTypeColor.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: mealTypeIcon)
                    .font(.system(size: 20))
                    .foregroundColor(mealTypeColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Meal type and name
                HStack(spacing: VirgilSpacing.xs) {
                    Text("\(mealTypeDisplayName):")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    Text(meal.foodName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                        .lineLimit(1)
                }

                // Serving info
                if let servingSize = meal.servingSize, let servingUnit = meal.servingUnit {
                    Text("\(Int(servingSize)) \(servingUnit)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                } else {
                    Text("1 Serving")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }

                // Nutrition info
                HStack(spacing: VirgilSpacing.sm) {
                    // Calories
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "FF6B6B"))
                        Text("\(meal.calories) kcal")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    // PFC
                    Text("P:\(Int(meal.protein))g")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "9C27B0"))

                    Text("F:\(Int(meal.fat))g")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "FFCB05"))

                    Text("C:\(Int(meal.carbs))g")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "00C853"))
                }
            }

            Spacer()
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private var mealTypeColor: Color {
        switch mealType {
        case "breakfast": return Color(hex: "FFA726")  // Orange
        case "lunch": return Color(hex: "66BB6A")      // Green
        case "dinner": return Color(hex: "5C6BC0")     // Indigo
        case "snack": return Color(hex: "26A69A")      // Teal
        default: return Color.gray
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MealLogListSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            MealLogListSection()
                .padding()
        }
    }
}
#endif
