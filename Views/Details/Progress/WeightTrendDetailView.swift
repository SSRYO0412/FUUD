//
//  WeightTrendDetailView.swift
//  FUUD
//
//  体重推移詳細ページ
//  期間切替対応の折れ線グラフ表示
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct WeightTrendDetailView: View {
    @StateObject private var weightService = WeightLogService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPeriod: WeightPeriod = .thirtyDays
    @State private var showingWeightInput = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                // 現在の体重
                currentWeightCard

                // 期間切替 & チャート
                chartCard

                // 統計
                statisticsCard

                // 目標
                goalCard

                // 体重記録ボタン
                addWeightButton
            }
            .padding(VirgilSpacing.md)
        }
        .background(OrbBackground())
        .navigationTitle("体重推移")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await weightService.fetchWeightHistory()
                await weightService.fetchUserGoal()
            }
        }
    }

    // MARK: - Current Weight Card

    private var currentWeightCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("現在の体重")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(currentWeightText)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.virgilTextPrimary)

                Text("kg")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            if let latestDate = weightService.weightHistory.first?.date {
                Text("最終記録: \(formatDate(latestDate))")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Period Picker
            HStack(spacing: VirgilSpacing.sm) {
                ForEach(WeightPeriod.allCases, id: \.self) { period in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPeriod = period
                        }
                    }) {
                        Text(period.title)
                            .font(.system(size: 12, weight: selectedPeriod == period ? .bold : .medium))
                            .foregroundColor(selectedPeriod == period ? .white : .virgilTextSecondary)
                            .padding(.horizontal, VirgilSpacing.sm)
                            .padding(.vertical, VirgilSpacing.xs)
                            .background(selectedPeriod == period ? Color.black : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }

            // Chart
            if !filteredData.isEmpty {
                Chart {
                    // 目標体重ライン
                    if let goal = weightService.userGoal?.targetWeight {
                        RuleMark(y: .value("目標", goal))
                            .foregroundStyle(Color(hex: "00C853").opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .trailing, alignment: .leading) {
                                Text("目標")
                                    .font(.system(size: 9))
                                    .foregroundColor(Color(hex: "00C853"))
                            }
                    }

                    // 体重データ
                    ForEach(filteredData) { entry in
                        AreaMark(
                            x: .value("日付", entry.date),
                            y: .value("体重", entry.weight)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4ECDC4").opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("日付", entry.date),
                            y: .value("体重", entry.weight)
                        )
                        .foregroundStyle(Color(hex: "4ECDC4"))
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        PointMark(
                            x: .value("日付", entry.date),
                            y: .value("体重", entry.weight)
                        )
                        .foregroundStyle(Color(hex: "4ECDC4"))
                        .symbolSize(30)
                    }
                }
                .chartYScale(domain: yAxisDomain)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%.1f", doubleValue))
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatDateShort(date))
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                    }
                }
                .frame(height: 200)
            } else {
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.virgilTextSecondary)
                    Text("データがありません")
                        .font(.system(size: 14))
                        .foregroundColor(.virgilTextSecondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Statistics Card

    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("統計")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                statRow(label: "開始時", value: startWeightText)
                statRow(label: "変動", value: changeText, valueColor: changeColor)
                statRow(label: "平均週変動", value: weeklyChangeText, valueColor: changeColor)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func statRow(label: String, value: String, valueColor: Color = .virgilTextPrimary) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.virgilTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(valueColor)
        }
    }

    // MARK: - Goal Card

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("目標")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                statRow(label: "目標体重", value: targetWeightText)
                statRow(label: "残り", value: remainingText, valueColor: Color(hex: "00C853"))
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Add Weight Button

    private var addWeightButton: some View {
        Button(action: {
            showingWeightInput = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))

                Text("体重を記録")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VirgilSpacing.md)
            .background(Color.black)
            .cornerRadius(12)
        }
    }

    // MARK: - Computed Properties

    private var filteredData: [WeightEntry] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: Date()) ?? Date()
        return weightService.weightHistory.filter { $0.date >= cutoffDate }
    }

    private var yAxisDomain: ClosedRange<Double> {
        guard !filteredData.isEmpty else { return 60...80 }
        let weights = filteredData.map { $0.weight }
        let minWeight = weights.min() ?? 70
        let maxWeight = weights.max() ?? 80
        let padding = (maxWeight - minWeight) * 0.2
        return (minWeight - padding)...(maxWeight + padding)
    }

    private var currentWeightText: String {
        if let current = weightService.currentWeight {
            return String(format: "%.1f", current)
        }
        return "--"
    }

    private var startWeightText: String {
        if let first = filteredData.last {
            return String(format: "%.1f kg", first.weight)
        }
        return "-- kg"
    }

    private var changeText: String {
        guard filteredData.count >= 2,
              let latest = filteredData.first,
              let oldest = filteredData.last else {
            return "-- kg"
        }
        let change = latest.weight - oldest.weight
        let sign = change > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change)) kg"
    }

    private var changeColor: Color {
        guard filteredData.count >= 2,
              let latest = filteredData.first,
              let oldest = filteredData.last else {
            return .virgilTextPrimary
        }
        let change = latest.weight - oldest.weight
        if change < 0 { return Color(hex: "00C853") }
        if change > 0 { return Color(hex: "FF6B6B") }
        return .virgilTextPrimary
    }

    private var weeklyChangeText: String {
        guard filteredData.count >= 2,
              let latest = filteredData.first,
              let oldest = filteredData.last else {
            return "-- kg"
        }
        let totalChange = latest.weight - oldest.weight
        let days = Calendar.current.dateComponents([.day], from: oldest.date, to: latest.date).day ?? 1
        let weeks = max(Double(days) / 7.0, 1.0)
        let weeklyChange = totalChange / weeks
        let sign = weeklyChange > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", weeklyChange)) kg/週"
    }

    private var targetWeightText: String {
        if let goal = weightService.userGoal?.targetWeight {
            return String(format: "%.1f kg", goal)
        }
        return "未設定"
    }

    private var remainingText: String {
        guard let current = weightService.currentWeight,
              let target = weightService.userGoal?.targetWeight else {
            return "-- kg"
        }
        let remaining = abs(current - target)
        return String(format: "%.1f kg", remaining)
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - Weight Period Enum

enum WeightPeriod: CaseIterable {
    case sevenDays
    case thirtyDays
    case ninetyDays

    var title: String {
        switch self {
        case .sevenDays: return "7日"
        case .thirtyDays: return "30日"
        case .ninetyDays: return "90日"
        }
    }

    var days: Int {
        switch self {
        case .sevenDays: return 7
        case .thirtyDays: return 30
        case .ninetyDays: return 90
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct WeightTrendDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeightTrendDetailView()
        }
    }
}
#endif
