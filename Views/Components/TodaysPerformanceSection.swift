//
//  TodaysPerformanceSection.swift
//  AWStest
//
//  Today's Performance セクション - 5つの健康指標ダッシュボード
//

import SwiftUI

struct TodaysPerformanceSection: View {
    @State private var metrics = PerformanceMetrics.sample // 実際の計算値に置き換え
    @State private var expandedMetric: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // メトリクス一覧（縦並び）- 予想消費カロリーを最上位に配置
            VStack(spacing: 0) {
                // Predicted Calories
                PerformanceMetricItem(
                    icon: "🔥",
                    name: "予想消費カロリー",
                    score: "\(metrics.predictedCalories)",
                    unit: "kcal",
                    delta: "+8%", // 実際の計算値に置き換え
                    deltaType: .positive,
                    indicator: .high,
                    isExpanded: expandedMetric == "predictedCalories",
                    onTap: { toggleMetric("predictedCalories") }
                )

                // 詳細展開エリア - 予想消費カロリー
                if expandedMetric == "predictedCalories" {
                    VStack(spacing: 12) {
                        MetricDetailView(
                            metric: "predictedCalories",
                            data: detailData(for: "predictedCalories"),
                            onClose: { expandedMetric = nil }
                        )

                        TuuningIntelligenceView(selectedMetric: expandedMetric)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 4)

                // Recovery
                PerformanceMetricItem(
                    icon: "⚡",
                    name: "回復スピード",
                    score: "\(metrics.recovery.score)",
                    unit: "%",
                    delta: metrics.recovery.delta,
                    deltaType: deltaType(for: metrics.recovery.delta),
                    indicator: metrics.recovery.indicator,
                    isExpanded: expandedMetric == "recovery",
                    onTap: { toggleMetric("recovery") }
                )

                // 詳細展開エリア - 回復スピード
                if expandedMetric == "recovery" {
                    VStack(spacing: 12) {
                        MetricDetailView(
                            metric: "recovery",
                            data: detailData(for: "recovery"),
                            onClose: { expandedMetric = nil }
                        )

                        TuuningIntelligenceView(selectedMetric: expandedMetric)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 4)

                // Metabolic
                PerformanceMetricItem(
                    icon: "🔥",
                    name: "代謝力",
                    score: metrics.metabolic.level.rawValue.uppercased(),
                    unit: nil,
                    delta: metrics.metabolic.delta,
                    deltaType: deltaType(for: metrics.metabolic.delta),
                    indicator: metrics.metabolic.indicator,
                    isExpanded: expandedMetric == "metabolic",
                    onTap: { toggleMetric("metabolic") }
                )

                // 詳細展開エリア - 代謝力
                if expandedMetric == "metabolic" {
                    VStack(spacing: 12) {
                        MetricDetailView(
                            metric: "metabolic",
                            data: detailData(for: "metabolic"),
                            onClose: { expandedMetric = nil }
                        )

                        TuuningIntelligenceView(selectedMetric: expandedMetric)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 4)

                // Inflammation
                PerformanceMetricItem(
                    icon: "🛡",
                    name: "炎症レベル",
                    score: metrics.inflammation.level.rawValue.uppercased(),
                    unit: nil,
                    delta: metrics.inflammation.delta,
                    deltaType: deltaType(for: metrics.inflammation.delta),
                    indicator: metrics.inflammation.indicator,
                    isExpanded: expandedMetric == "inflammation",
                    onTap: { toggleMetric("inflammation") }
                )

                // 詳細展開エリア - 炎症レベル
                if expandedMetric == "inflammation" {
                    VStack(spacing: 12) {
                        MetricDetailView(
                            metric: "inflammation",
                            data: detailData(for: "inflammation"),
                            onClose: { expandedMetric = nil }
                        )

                        TuuningIntelligenceView(selectedMetric: expandedMetric)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 4)

                // Aging pace
                PerformanceMetricItem(
                    icon: "🧬",
                    name: "老化速度",
                    score: String(format: "%.2f", metrics.longevity),
                    unit: "age/year",
                    delta: "−18%", // 実際の計算値に置き換え
                    deltaType: .positive,
                    indicator: .excellent,
                    isExpanded: expandedMetric == "longevity",
                    onTap: { toggleMetric("longevity") }
                )

                // 詳細展開エリア - 老化速度
                if expandedMetric == "longevity" {
                    VStack(spacing: 12) {
                        MetricDetailView(
                            metric: "longevity",
                            data: detailData(for: "longevity"),
                            onClose: { expandedMetric = nil }
                        )

                        TuuningIntelligenceView(selectedMetric: expandedMetric)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 4)

                // Performance
                PerformanceMetricItem(
                    icon: "🎯",
                    name: "総合パフォーマンス",
                    score: "\(metrics.performance)",
                    unit: nil,
                    delta: "+12%", // 実際の計算値に置き換え
                    deltaType: .positive,
                    indicator: .high,
                    isExpanded: expandedMetric == "performance",
                    onTap: { toggleMetric("performance") }
                )

                // 詳細展開エリア - 総合パフォーマンス
                if expandedMetric == "performance" {
                    VStack(spacing: 12) {
                        MetricDetailView(
                            metric: "performance",
                            data: detailData(for: "performance"),
                            onClose: { expandedMetric = nil }
                        )

                        TuuningIntelligenceView(selectedMetric: expandedMetric)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 0)
            .padding(.bottom, 20)
        }
        .background(Color.white.opacity(0.001)) // Hit testing用
        .liquidGlassCard()
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }

    private func toggleMetric(_ metric: String) {
        withAnimation(.spring(response: 0.3)) {
            if expandedMetric == metric {
                expandedMetric = nil
            } else {
                expandedMetric = metric
            }
        }
    }

    private func deltaType(for delta: String) -> PerformanceMetricItem.DeltaType {
        if delta.contains("+") {
            return .positive
        } else if delta.contains("−") || delta.contains("-") {
            return .negative
        } else {
            return .neutral
        }
    }

    private func detailData(for metric: String) -> [String: String] {
        let sampleData = PerformanceDetailData.sample
        switch metric {
        case "recovery":
            return sampleData.recovery
        case "metabolic":
            return sampleData.metabolic
        case "inflammation":
            return sampleData.inflammation
        case "longevity":
            return sampleData.longevity
        case "performance":
            return sampleData.performance
        case "predictedCalories":
            return sampleData.predictedCalories
        default:
            return [:]
        }
    }
}

#if DEBUG
struct TodaysPerformanceSection_Previews: PreviewProvider {
    static var previews: some View {
        TodaysPerformanceSection()
            .padding()
            .background(Color(hex: "F5F5F5"))
    }
}
#endif
