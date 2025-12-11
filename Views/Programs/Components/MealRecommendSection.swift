//
//  MealRecommendSection.swift
//  FUUD
//
//  食事レコメンドセクション（朝/昼/夜）
//  Phase 6-UI: TodayProgramView用
//

import SwiftUI

struct MealRecommendSection: View {
    let mealPlan: DailyMealPlan?
    var onMealTap: ((MealRecommendation) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Title
            HStack {
                Text("TODAY'S MEALS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Spacer()

                if let mealPlan = mealPlan {
                    Text("\(mealPlan.totalCalories) kcal")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.lifesumDarkGreen)
                }
            }
            .padding(.horizontal, VirgilSpacing.md)

            // Meal Cards
            if let mealPlan = mealPlan {
                VStack(spacing: VirgilSpacing.sm) {
                    ForEach(mealPlan.meals) { meal in
                        MealRecommendCard(
                            meal: meal,
                            onTap: { onMealTap?(meal) }
                        )
                    }
                }
                .padding(.horizontal, VirgilSpacing.md)
            } else {
                // Loading placeholder
                VStack(spacing: VirgilSpacing.sm) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 80)
                    }
                }
                .padding(.horizontal, VirgilSpacing.md)
            }
        }
    }
}

// MARK: - Meal Recommend Card

struct MealRecommendCard: View {
    let meal: MealRecommendation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VirgilSpacing.md) {
                // Meal Time Icon
                ZStack {
                    Circle()
                        .fill(meal.mealTime.iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: meal.mealTime.icon)
                        .font(.system(size: 18))
                        .foregroundColor(meal.mealTime.iconColor)
                }

                // Meal Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(meal.mealTime.displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(meal.mealTime.iconColor)

                        Spacer()

                        Text("\(meal.calories) kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(meal.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    // Tags
                    if !meal.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(meal.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // With meal plan
            MealRecommendSection(
                mealPlan: DailyMealPlan(
                    date: Date(),
                    meals: [
                        MealRecommendation(
                            mealTime: .breakfast,
                            title: "和定食（ご飯・味噌汁・焼き魚）",
                            description: "バランスの取れた和朝食",
                            calories: 450,
                            protein: 25,
                            fat: 15,
                            carbs: 55,
                            tags: ["和食", "バランス"],
                            tips: nil
                        ),
                        MealRecommendation(
                            mealTime: .lunch,
                            title: "鶏むね肉のサラダ定食",
                            description: "高タンパクランチ",
                            calories: 650,
                            protein: 40,
                            fat: 20,
                            carbs: 70,
                            tags: ["高タンパク", "野菜たっぷり"],
                            tips: nil
                        ),
                        MealRecommendation(
                            mealTime: .dinner,
                            title: "豆腐と野菜の炒め物",
                            description: "消化に優しい夕食",
                            calories: 500,
                            protein: 30,
                            fat: 18,
                            carbs: 50,
                            tags: ["低GI", "植物性タンパク"],
                            tips: nil
                        )
                    ],
                    totalCalories: 1600,
                    totalProtein: 95,
                    totalFat: 53,
                    totalCarbs: 175,
                    programContext: "バランス型ダイエット"
                ),
                onMealTap: { _ in }
            )

            Divider()

            // Without meal plan (loading)
            MealRecommendSection(mealPlan: nil)
        }
        .padding(.vertical)
    }
    .background(Color(.systemBackground))
}
