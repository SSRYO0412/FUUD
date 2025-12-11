//
//  TDEEDetailView.swift
//  FUUD
//
//  消費エネルギー（TDEE）詳細ページ
//  30日間の折れ線グラフ表示
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct TDEEDetailView: View {
    @StateObject private var personalizer = NutritionPersonalizer.shared
    @StateObject private var healthKit = HealthKitService.shared
    @Environment(\.dismiss) private var dismiss

    // サンプル30日間データ
    @State private var tdeeHistory: [TDEEDataPoint] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                // 現在のTDEE
                currentTDEECard

                // 30日間推移チャート
                chartCard

                // 内訳
                breakdownCard

                // 目標設定
                goalSettingsCard
            }
            .padding(VirgilSpacing.md)
        }
        .background(OrbBackground())
        .navigationTitle("消費エネルギー")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateSampleData()
        }
    }

    // MARK: - Current TDEE Card

    private var currentTDEECard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("現在のTDEE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(currentTDEE)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.virgilTextPrimary)

                Text("kcal/日")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            Text("過去30日間の平均消費エネルギー")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
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

            if !tdeeHistory.isEmpty {
                Chart(tdeeHistory) { dataPoint in
                    LineMark(
                        x: .value("日付", dataPoint.date),
                        y: .value("TDEE", dataPoint.tdee)
                    )
                    .foregroundStyle(Color(hex: "FF6B6B"))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("日付", dataPoint.date),
                        y: .value("TDEE", dataPoint.tdee)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FF6B6B").opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("日付", dataPoint.date),
                        y: .value("TDEE", dataPoint.tdee)
                    )
                    .foregroundStyle(Color(hex: "FF6B6B"))
                    .symbolSize(20)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatDate(date))
                                    .font(.system(size: 10))
                                    .foregroundColor(.virgilTextSecondary)
                            }
                        }
                    }
                }
                .frame(height: 200)
            } else {
                Text("データを読み込み中...")
                    .font(.system(size: 14))
                    .foregroundColor(.virgilTextSecondary)
                    .frame(height: 200)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Breakdown Card

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("内訳")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                breakdownRow(
                    label: "基礎代謝 (BMR)",
                    value: "\(bmr) kcal",
                    color: Color(hex: "4ECDC4")
                )

                breakdownRow(
                    label: "活動代謝",
                    value: "\(activityCalories) kcal",
                    color: Color(hex: "FF6B6B")
                )

                breakdownRow(
                    label: "食事誘発性熱産生 (TEF)",
                    value: "\(tef) kcal",
                    color: Color(hex: "FFCB05")
                )

                Divider()

                breakdownRow(
                    label: "合計 TDEE",
                    value: "\(currentTDEE) kcal",
                    color: .virgilTextPrimary,
                    isBold: true
                )
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func breakdownRow(label: String, value: String, color: Color, isBold: Bool = false) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.system(size: 14, weight: isBold ? .semibold : .regular))
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: isBold ? .bold : .medium))
                .foregroundColor(.virgilTextPrimary)
        }
    }

    // MARK: - Goal Settings Card

    private var goalSettingsCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("目標設定")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                settingRow(label: "カロリー目標", value: "\(targetCalories) kcal")
                settingRow(label: "目的", value: goalDescription)
                settingRow(label: "カロリー調整", value: calorieAdjustment)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func settingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.virgilTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.virgilTextPrimary)
        }
    }

    // MARK: - Computed Properties

    private var currentTDEE: Int {
        personalizer.adjustedCalories?.baseTDEE ?? 2100
    }

    private var bmr: Int {
        Int(Double(currentTDEE) * 0.7)
    }

    private var activityCalories: Int {
        Int(healthKit.healthData?.activeEnergyBurned ?? Double(currentTDEE) * 0.2)
    }

    private var tef: Int {
        currentTDEE - bmr - activityCalories
    }

    private var targetCalories: Int {
        personalizer.adjustedCalories?.adjustedTarget ?? 1800
    }

    private var goalDescription: String {
        let diff = targetCalories - currentTDEE
        if diff < -200 {
            return "減量"
        } else if diff > 200 {
            return "増量"
        } else {
            return "維持"
        }
    }

    private var calorieAdjustment: String {
        let diff = targetCalories - currentTDEE
        if diff > 0 {
            return "+\(diff) kcal/日"
        } else {
            return "\(diff) kcal/日"
        }
    }

    // MARK: - Helper Methods

    private func generateSampleData() {
        let calendar = Calendar.current
        let baseTDEE = Double(currentTDEE)

        tdeeHistory = (0..<30).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            let variation = Double.random(in: -100...100)
            return TDEEDataPoint(date: date, tdee: Int(baseTDEE + variation))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - TDEE Data Point

struct TDEEDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let tdee: Int
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct TDEEDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TDEEDetailView()
        }
    }
}
#endif
