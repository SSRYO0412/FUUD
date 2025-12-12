//
//  InsightsAnalyticsSection.swift
//  FUUD
//
//  MacroFactor風 Insights & Analytics セクション
//  参考: /Users/sasakiryo/Downloads/MacrofactorUI/MacroFactor iOS 79.png
//

import SwiftUI

struct InsightsAnalyticsSection: View {
    @StateObject private var personalizer = NutritionPersonalizer.shared
    @StateObject private var weightService = WeightLogService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            Text("インサイト & 分析")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // Top Row: Expenditure + Weight Trend
            HStack(spacing: VirgilSpacing.md) {
                if #available(iOS 16.0, *) {
                    NavigationLink(destination: TDEEDetailView()) {
                        InsightMiniCard(
                            title: "消費エネルギー",
                            subtitle: dateRangeText,
                            value: "\(currentTDEE) kcal",
                            chartData: tdeeChartData,
                            chartColor: Color(hex: "FF6B6B")
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: WeightTrendDetailView()) {
                        InsightMiniCard(
                            title: "体重推移",
                            subtitle: dateRangeText,
                            value: weightText,
                            chartData: weightChartData,
                            chartColor: Color(hex: "4ECDC4")
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    InsightMiniCard(
                        title: "消費エネルギー",
                        subtitle: dateRangeText,
                        value: "\(currentTDEE) kcal",
                        chartData: tdeeChartData,
                        chartColor: Color(hex: "FF6B6B")
                    )

                    InsightMiniCard(
                        title: "体重推移",
                        subtitle: dateRangeText,
                        value: weightText,
                        chartData: weightChartData,
                        chartColor: Color(hex: "4ECDC4")
                    )
                }
            }

            // Goal Progress
            if #available(iOS 16.0, *) {
                NavigationLink(destination: GoalProgressDetailView()) {
                    GoalProgressCard(
                        startDate: goalStartDate,
                        daysCompleted: daysInProgram,
                        totalDays: nil
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                GoalProgressCard(
                    startDate: goalStartDate,
                    daysCompleted: daysInProgram,
                    totalDays: nil
                )
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            Task {
                await weightService.fetchWeightHistory()
                await weightService.fetchUserGoal()
            }
        }
    }

    // MARK: - Computed Properties

    private var currentTDEE: Int {
        personalizer.adjustedCalories?.baseTDEE ?? 2100
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return "\(formatter.string(from: startDate)) 〜 現在"
    }

    private var weightText: String {
        if let current = weightService.currentWeight {
            return String(format: "%.1f kg", current)
        }
        return "-- kg"
    }

    private var goalStartDate: Date {
        Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    }

    private var daysInProgram: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: goalStartDate, to: Date()).day ?? 0
        return days
    }

    // MARK: - Chart Data

    private var tdeeChartData: [Double] {
        // TDEEは比較的安定なので微小な変動
        return [2050, 2080, 2100, 2090, 2102, 2095, 2102].map { Double($0) }
    }

    private var weightChartData: [Double] {
        if !weightService.weightHistory.isEmpty {
            return weightService.weightHistory.prefix(7).map { $0.weight }.reversed()
        }
        return [75.2, 75.0, 74.8, 74.9, 74.7, 74.5, 74.5]
    }
}

// MARK: - Insight Mini Card

struct InsightMiniCard: View {
    let title: String
    let subtitle: String
    let value: String
    let chartData: [Double]
    let chartColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Text(subtitle)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Mini Line Chart
            MiniLineChart(data: chartData, color: chartColor)
                .frame(height: 40)

            // Value
            HStack {
                Text(value)
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

// MARK: - Mini Line Chart

struct MiniLineChart: View {
    let data: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            if data.count > 1 {
                let minValue = data.min() ?? 0
                let maxValue = data.max() ?? 1
                let range = maxValue - minValue
                let effectiveRange = range > 0 ? range : 1

                Path { path in
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    let heightMultiplier = geometry.size.height / effectiveRange

                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - (value - minValue) * heightMultiplier

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Goal Progress Card

struct GoalProgressCard: View {
    let startDate: Date
    let daysCompleted: Int
    let totalDays: Int?

    private var displayDots: Int {
        min(daysCompleted, 14)  // 最大14ドット表示
    }

    private var emptyDots: Int {
        max(0, 14 - displayDots)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("目標進捗")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Text(dateRangeText)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Progress Dots
            HStack(spacing: 4) {
                ForEach(0..<displayDots, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "00C853"))
                        .frame(width: 8, height: 8)
                }
                ForEach(0..<emptyDots, id: \.self) { _ in
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 8, height: 8)
                }

                Spacer()
            }

            // Days Text
            HStack {
                Text("\(daysCompleted)日目")
                    .font(.system(size: 12, weight: .medium))
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

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: startDate)) 〜 現在"
    }
}

// MARK: - Preview

#if DEBUG
struct InsightsAnalyticsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            InsightsAnalyticsSection()
                .padding()
        }
    }
}
#endif
