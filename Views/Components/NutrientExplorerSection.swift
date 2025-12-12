//
//  NutrientExplorerSection.swift
//  FUUD
//
//  MacroFactor風 Nutrient Explorer セクション
//  参考: /Users/sasakiryo/Downloads/MacrofactorUI/MacroFactor iOS 83.png
//

import SwiftUI

struct NutrientExplorerSection: View {
    @StateObject private var mealService = MealLogService.shared
    @StateObject private var personalizer = NutritionPersonalizer.shared

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            Text("栄養素")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // Explore All Button
            Button(action: { /* Navigate to full nutrient explorer */ }) {
                HStack {
                    Text("すべて見る")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, VirgilSpacing.md)
                .padding(.vertical, VirgilSpacing.sm)
                .background(Color.black)
                .cornerRadius(12)
            }

            // 2x2 Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: VirgilSpacing.md),
                GridItem(.flexible(), spacing: VirgilSpacing.md)
            ], spacing: VirgilSpacing.md) {
                if #available(iOS 16.0, *) {
                    NavigationLink(destination: NutrientDetailView(nutrientType: .calories)) {
                        NutrientCard(
                            title: "カロリー",
                            current: mealService.todayTotals.calories,
                            target: targetCalories,
                            color: Color(hex: "0088CC"),
                            unit: "kcal"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: NutrientDetailView(nutrientType: .protein)) {
                        NutrientCard(
                            title: "タンパク質",
                            current: mealService.todayTotals.protein,
                            target: proteinTarget,
                            color: Color(hex: "9C27B0"),
                            unit: "g"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: NutrientDetailView(nutrientType: .fat)) {
                        NutrientCard(
                            title: "脂質",
                            current: mealService.todayTotals.fat,
                            target: fatTarget,
                            color: Color(hex: "FFCB05"),
                            unit: "g"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: NutrientDetailView(nutrientType: .carbs)) {
                        NutrientCard(
                            title: "糖質",
                            current: mealService.todayTotals.carbs,
                            target: carbsTarget,
                            color: Color(hex: "00C853"),
                            unit: "g"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    NutrientCard(
                        title: "カロリー",
                        current: mealService.todayTotals.calories,
                        target: targetCalories,
                        color: Color(hex: "0088CC"),
                        unit: "kcal"
                    )

                    NutrientCard(
                        title: "タンパク質",
                        current: mealService.todayTotals.protein,
                        target: proteinTarget,
                        color: Color(hex: "9C27B0"),
                        unit: "g"
                    )

                    NutrientCard(
                        title: "脂質",
                        current: mealService.todayTotals.fat,
                        target: fatTarget,
                        color: Color(hex: "FFCB05"),
                        unit: "g"
                    )

                    NutrientCard(
                        title: "糖質",
                        current: mealService.todayTotals.carbs,
                        target: carbsTarget,
                        color: Color(hex: "00C853"),
                        unit: "g"
                    )
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Computed Properties

    private var targetCalories: Int {
        personalizer.adjustedCalories?.adjustedTarget ?? 1800
    }

    private var proteinTarget: Int {
        personalizer.pfcBalance.proteinGrams(for: targetCalories)
    }

    private var fatTarget: Int {
        personalizer.pfcBalance.fatGrams(for: targetCalories)
    }

    private var carbsTarget: Int {
        personalizer.pfcBalance.carbsGrams(for: targetCalories)
    }
}

// MARK: - Nutrient Card

struct NutrientCard: View {
    let title: String
    let current: Int
    let target: Int
    let color: Color
    let unit: String

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.5)
    }

    private var percentage: Int {
        guard target > 0 else { return 0 }
        return Int((Double(current) / Double(target)) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Text("今日")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)

                    // Progress
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 6)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)

            // Percentage & Arrow
            HStack {
                Text("\(percentage) %")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#if DEBUG
struct NutrientExplorerSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            NutrientExplorerSection()
                .padding()
        }
    }
}
#endif
