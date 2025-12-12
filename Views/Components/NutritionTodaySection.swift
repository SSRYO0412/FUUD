//
//  NutritionTodaySection.swift
//  FUUD
//
//  Lifesum風のカロリー・PFC表示セクション
//  参考: /Users/sasakiryo/Downloads/Lifesum iOS 31.png
//

import SwiftUI

struct NutritionTodaySection: View {
    @StateObject private var personalizer = NutritionPersonalizer.shared
    @StateObject private var mealService = MealLogService.shared
    @StateObject private var healthKit = HealthKitService.shared

    @State private var selectedDate: Date = Date()
    @State private var showingStats = false

    // MARK: - Computed Properties

    private var targetCalories: Int {
        personalizer.adjustedCalories?.adjustedTarget ?? 1800
    }

    private var eatenCalories: Int {
        mealService.todayTotals.calories
    }

    private var burnedCalories: Int {
        Int(healthKit.healthData?.activeEnergyBurned ?? 0)
    }

    private var remainingCalories: Int {
        targetCalories - eatenCalories + burnedCalories
    }

    private var isOverBudget: Bool {
        remainingCalories < 0
    }

    private var progress: Double {
        guard targetCalories > 0 else { return 0 }
        return Double(eatenCalories) / Double(targetCalories)
    }

    // PFC targets
    private var proteinTarget: Int {
        personalizer.pfcBalance.proteinGrams(for: targetCalories)
    }

    private var fatTarget: Int {
        personalizer.pfcBalance.fatGrams(for: targetCalories)
    }

    private var carbsTarget: Int {
        personalizer.pfcBalance.carbsGrams(for: targetCalories)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Main Ring Area
            ringSection
                .padding(.vertical, VirgilSpacing.lg)

            // SEE STATS button
            seeStatsButton
                .padding(.bottom, VirgilSpacing.md)

            Divider()
                .background(Color.white.opacity(0.1))

            // PFC Progress Bars
            pfcBarsSection
                .padding(.vertical, VirgilSpacing.md)

            Divider()
                .background(Color.white.opacity(0.1))

            // Date Navigation
            dateNavigationSection
                .padding(.vertical, VirgilSpacing.sm)
        }
        .liquidGlassCard()
        .onAppear {
            Task {
                await mealService.fetchTodayMeals()
                await personalizer.calculatePersonalization()
            }
        }
    }

    // MARK: - Ring Section

    private var ringSection: some View {
        HStack(alignment: .center) {
            // EATEN (左)
            VStack(spacing: VirgilSpacing.xs) {
                Text("\(eatenCalories)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Text("摂取")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
            .frame(maxWidth: .infinity)

            // Center Ring
            CalorieRingView(
                remaining: remainingCalories,
                target: targetCalories,
                eaten: eatenCalories,
                progress: progress
            )
            .frame(width: 140, height: 140)

            // BURNED (右)
            VStack(spacing: VirgilSpacing.xs) {
                Text("\(burnedCalories)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Text("消費")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, VirgilSpacing.md)
    }

    // MARK: - SEE STATS Button

    private var seeStatsButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                showingStats.toggle()
            }
        }) {
            HStack(spacing: 4) {
                Text("詳細を見る")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)

                Image(systemName: showingStats ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
    }

    // MARK: - PFC Bars Section

    private var pfcBarsSection: some View {
        HStack(spacing: VirgilSpacing.md) {
            MacroProgressBar(
                label: "糖質",
                current: mealService.todayTotals.carbs,
                target: carbsTarget,
                color: Color(hex: "00C853")  // 緑
            )

            MacroProgressBar(
                label: "タンパク質",
                current: mealService.todayTotals.protein,
                target: proteinTarget,
                color: Color(hex: "9C27B0")  // 紫
            )

            MacroProgressBar(
                label: "脂質",
                current: mealService.todayTotals.fat,
                target: fatTarget,
                color: Color(hex: "FFCB05")  // 黄
            )
        }
        .padding(.horizontal, VirgilSpacing.md)
    }

    // MARK: - Date Navigation

    private var dateNavigationSection: some View {
        HStack {
            Button(action: { changeDate(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }

            Spacer()

            Text(formattedDate)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Button(action: { changeDate(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isToday ? .virgilTextSecondary.opacity(0.3) : .virgilTextSecondary)
            }
            .disabled(isToday)
        }
        .padding(.horizontal, VirgilSpacing.lg)
    }

    // MARK: - Helper Methods

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")

        if Calendar.current.isDateInToday(selectedDate) {
            formatter.dateFormat = "M月d日"
            return "今日 \(formatter.string(from: selectedDate))"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            formatter.dateFormat = "M月d日"
            return "昨日 \(formatter.string(from: selectedDate))"
        } else {
            formatter.dateFormat = "M月d日 (E)"
            return formatter.string(from: selectedDate)
        }
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private func changeDate(by days: Int) {
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) else { return }

        // 未来の日付は選択不可
        if newDate > Date() { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = newDate
        }

        Task {
            await mealService.fetchMeals(for: selectedDate)
        }
    }
}

// MARK: - Calorie Ring View

struct CalorieRingView: View {
    let remaining: Int
    let target: Int
    let eaten: Int
    let progress: Double

    private var isOver: Bool {
        remaining < 0
    }

    private var ringColor: Color {
        if isOver {
            return Color(hex: "ED1C24")  // 赤
        } else if progress > 0.9 {
            return Color(hex: "FFCB05")  // 黄
        } else {
            return Color(hex: "00C853")  // 緑
        }
    }

    var body: some View {
        ZStack {
            // Background Ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)

            // Progress Ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)

            // Over Budget Ring (超過分)
            if progress > 1.0 {
                Circle()
                    .trim(from: 0, to: progress - 1.0)
                    .stroke(
                        Color(hex: "ED1C24").opacity(0.5),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: progress)
            }

            // Center Text
            VStack(spacing: 2) {
                Text("\(abs(remaining))")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(isOver ? Color(hex: "ED1C24") : .virgilTextPrimary)

                Text(isOver ? "kcal 超過" : "kcal 残り")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
    }
}

// MARK: - Macro Progress Bar

struct MacroProgressBar: View {
    let label: String
    let current: Int
    let target: Int
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.5)
    }

    private var isOver: Bool {
        current > target
    }

    var body: some View {
        VStack(spacing: VirgilSpacing.xs) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isOver ? Color(hex: "ED1C24") : color)
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)

            // Value Text
            Text("\(current) / \(target)g")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.virgilTextPrimary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NutritionTodaySection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            NutritionTodaySection()
                .padding()
        }
    }
}
#endif
