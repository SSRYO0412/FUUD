//
//  BodyMetricsDetailView.swift
//  FUUD
//
//  体組成詳細ページ
//  デュアル折れ線グラフ（体脂肪率・除脂肪体重）
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct BodyMetricsDetailView: View {
    @StateObject private var healthKit = HealthKitService.shared
    @StateObject private var weightService = WeightLogService.shared

    @State private var bodyMetricsHistory: [BodyMetricsDataPoint] = []
    @State private var showingInputSheet = false

    private let bodyFatColor = Color(hex: "FFCB05")
    private let leanMassColor = Color(hex: "4ECDC4")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                // 現在の体組成
                currentMetricsCard

                // 推移チャート
                chartCard

                // 目標
                goalCard

                // 記録ボタン
                addMetricsButton
            }
            .padding(VirgilSpacing.md)
        }
        .background(OrbBackground())
        .navigationTitle("体組成")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateSampleData()
        }
    }

    // MARK: - Current Metrics Card

    private var currentMetricsCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("現在の体組成")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            HStack(spacing: VirgilSpacing.lg) {
                // 体脂肪率
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(bodyFatColor)
                            .frame(width: 8, height: 8)
                        Text("体脂肪率")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text(bodyFatText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.virgilTextPrimary)
                }

                Spacer()

                // 除脂肪体重
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(leanMassColor)
                            .frame(width: 8, height: 8)
                        Text("除脂肪体重")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text(leanMassText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.virgilTextPrimary)
                }
            }

            if let lastUpdated = bodyMetricsHistory.first?.date {
                Text("最終更新: \(formatDate(lastUpdated))")
                    .font(.system(size: 11, weight: .regular))
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
            Text("30日間推移")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            if !bodyMetricsHistory.isEmpty {
                Chart {
                    ForEach(bodyMetricsHistory) { point in
                        // 体脂肪率ライン
                        LineMark(
                            x: .value("日付", point.date),
                            y: .value("体脂肪率", point.bodyFatPercentage),
                            series: .value("指標", "体脂肪率")
                        )
                        .foregroundStyle(bodyFatColor)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        PointMark(
                            x: .value("日付", point.date),
                            y: .value("体脂肪率", point.bodyFatPercentage)
                        )
                        .foregroundStyle(bodyFatColor)
                        .symbolSize(20)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%.0f%%", doubleValue))
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
                .frame(height: 150)

                // 除脂肪体重チャート（別グラフ）
                Text("除脂肪体重推移")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
                    .padding(.top, VirgilSpacing.sm)

                Chart {
                    ForEach(bodyMetricsHistory) { point in
                        LineMark(
                            x: .value("日付", point.date),
                            y: .value("除脂肪体重", point.leanBodyMass)
                        )
                        .foregroundStyle(leanMassColor)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("日付", point.date),
                            y: .value("除脂肪体重", point.leanBodyMass)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [leanMassColor.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("日付", point.date),
                            y: .value("除脂肪体重", point.leanBodyMass)
                        )
                        .foregroundStyle(leanMassColor)
                        .symbolSize(20)
                    }
                }
                .chartYScale(domain: leanMassDomain)
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
                .frame(height: 150)

                // Legend
                HStack(spacing: VirgilSpacing.md) {
                    legendItem(color: bodyFatColor, label: "体脂肪率")
                    legendItem(color: leanMassColor, label: "除脂肪体重")
                }
                .padding(.top, VirgilSpacing.xs)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
        }
    }

    // MARK: - Goal Card

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("目標")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                goalRow(label: "目標体脂肪率", value: "15.0 %")

                if let current = currentBodyFat {
                    let remaining = current - 15.0
                    goalRow(
                        label: "残り",
                        value: String(format: "%.1f %%", remaining),
                        valueColor: remaining > 0 ? Color(hex: "FF6B6B") : Color(hex: "00C853")
                    )
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func goalRow(label: String, value: String, valueColor: Color = .virgilTextPrimary) -> some View {
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

    // MARK: - Add Metrics Button

    private var addMetricsButton: some View {
        Button(action: {
            showingInputSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))

                Text("体組成を記録")
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

    private var currentBodyFat: Double? {
        if let bf = healthKit.healthData?.bodyFatPercentage {
            return bf * 100
        }
        return bodyMetricsHistory.first?.bodyFatPercentage
    }

    private var currentLeanMass: Double? {
        if let weight = weightService.currentWeight,
           let bf = currentBodyFat {
            return weight * (1 - bf / 100)
        }
        return bodyMetricsHistory.first?.leanBodyMass
    }

    private var bodyFatText: String {
        if let bf = currentBodyFat {
            return String(format: "%.1f %%", bf)
        }
        return "-- %"
    }

    private var leanMassText: String {
        if let lm = currentLeanMass {
            return String(format: "%.1f kg", lm)
        }
        return "-- kg"
    }

    private var leanMassDomain: ClosedRange<Double> {
        guard !bodyMetricsHistory.isEmpty else { return 55...65 }
        let masses = bodyMetricsHistory.map { $0.leanBodyMass }
        let min = masses.min() ?? 55
        let max = masses.max() ?? 65
        let padding = (max - min) * 0.2
        return (min - padding)...(max + padding)
    }

    // MARK: - Helper Methods

    private func generateSampleData() {
        let calendar = Calendar.current
        let baseBodyFat = currentBodyFat ?? 18.5
        let baseLeanMass = currentLeanMass ?? 60.5

        bodyMetricsHistory = (0..<30).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }

            // 徐々に体脂肪が減少、除脂肪体重が増加するトレンド
            let progressRatio = Double(30 - daysAgo) / 30.0
            let bodyFat = baseBodyFat + (1 - progressRatio) * 2 + Double.random(in: -0.3...0.3)
            let leanMass = baseLeanMass - (1 - progressRatio) * 0.5 + Double.random(in: -0.2...0.2)

            return BodyMetricsDataPoint(
                date: date,
                bodyFatPercentage: bodyFat,
                leanBodyMass: leanMass
            )
        }
    }

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

// MARK: - Body Metrics Data Point

struct BodyMetricsDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let bodyFatPercentage: Double
    let leanBodyMass: Double
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct BodyMetricsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BodyMetricsDetailView()
        }
    }
}
#endif
