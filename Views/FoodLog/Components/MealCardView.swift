//
//  MealCardView.swift
//  FUUD
//
//  Lifesum風AI解析結果カード
//

import SwiftUI

struct MealCardView: View {
    let meal: ParsedMeal

    private let carbsColor = Color(hex: "FFCB05")
    private let proteinColor = Color(hex: "9C27B0")
    private let fatColor = Color(hex: "FF6B6B")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Meal icon
                Image(systemName: "fork.knife")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Meal info
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(meal.mealType.displayName): \(meal.name)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(meal.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            // PFC dots
            HStack(spacing: 12) {
                pfcDot(color: carbsColor, value: meal.totalCarbs, label: "C")
                pfcDot(color: proteinColor, value: meal.totalProtein, label: "P")
                pfcDot(color: fatColor, value: meal.totalFat, label: "F")

                Spacer()

                // Calories
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("\(meal.totalCalories) kcal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func pfcDot(color: Color, value: Double, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(String(format: "%.0fg", value))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Compact Meal Card (for list)

struct CompactMealCard: View {
    let meal: ParsedMeal
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(meal.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(meal.totalCalories) kcal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Suggestion Chip

struct SuggestionChip: View {
    let text: String
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct MealCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeal = ParsedMeal(
            name: "和定食セット",
            description: "牛肉炒め、わかめスープ、冷奴、アボカドときゅうりのサラダ",
            mealType: .dinner,
            items: []
        )

        VStack(spacing: 16) {
            MealCardView(meal: sampleMeal)
                .padding()

            CompactMealCard(meal: sampleMeal)
                .padding()

            HStack {
                SuggestionChip(text: "麻婆豆腐")
                SuggestionChip(text: "ラーメン")
                SuggestionChip(text: "カレー")
            }
            .padding()
        }
        .background(Color(hex: "F5F0E8"))
    }
}
#endif
