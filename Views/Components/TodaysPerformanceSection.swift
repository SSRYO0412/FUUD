//
//  TodaysPerformanceSection.swift
//  AWStest
//
//  Today's Performance セクション - 5つの健康指標ダッシュボード
//

import SwiftUI

struct TodaysPerformanceSection: View {
    @State private var metrics = PerformanceMetrics.sample // [DUMMY] 実際の計算値に置き換え
    @State private var expandedMetric: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header with date
            HStack {
                Text("TODAY'S PERFORMANCE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.virgilTextSecondary)
                    

                Spacer()

                Text(formattedDate)
                    .font(.system(size: 8, weight: .regular))
                    .foregroundColor(.virgilGray400)
            }
            .padding(.top, 8)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // 5つのメトリクスグリッド
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                // Recovery
                PerformanceMetricItem(
                    icon: "⚡",
                    name: "Recovery",
                    score: "\(metrics.recovery.score)",
                    delta: metrics.recovery.delta,
                    deltaType: deltaType(for: metrics.recovery.delta),
                    indicator: metrics.recovery.indicator,
                    isExpanded: expandedMetric == "recovery",
                    onTap: { toggleMetric("recovery") }
                )

                // Metabolic
                PerformanceMetricItem(
                    icon: "🔥",
                    name: "Metabolic",
                    score: metrics.metabolic.level.rawValue.uppercased(),
                    delta: metrics.metabolic.delta,
                    deltaType: deltaType(for: metrics.metabolic.delta),
                    indicator: metrics.metabolic.indicator,
                    isExpanded: expandedMetric == "metabolic",
                    onTap: { toggleMetric("metabolic") }
                )

                // Inflammation
                PerformanceMetricItem(
                    icon: "🛡",
                    name: "Inflammation",
                    score: metrics.inflammation.level.rawValue.uppercased(),
                    delta: metrics.inflammation.delta,
                    deltaType: deltaType(for: metrics.inflammation.delta),
                    indicator: metrics.inflammation.indicator,
                    isExpanded: expandedMetric == "inflammation",
                    onTap: { toggleMetric("inflammation") }
                )

                // Longevity
                PerformanceMetricItem(
                    icon: "🧬",
                    name: "Longevity",
                    score: String(format: "%.2f", metrics.longevity),
                    delta: "−18%", // [DUMMY] 実際の計算値に置き換え
                    deltaType: .positive,
                    indicator: .excellent,
                    isExpanded: expandedMetric == "longevity",
                    onTap: { toggleMetric("longevity") }
                )

                // Performance
                PerformanceMetricItem(
                    icon: "🎯",
                    name: "Performance",
                    score: "\(metrics.performance)",
                    delta: "+12%", // [DUMMY] 実際の計算値に置き換え
                    deltaType: .positive,
                    indicator: .high,
                    isExpanded: expandedMetric == "performance",
                    onTap: { toggleMetric("performance") }
                )
            }
            .padding(.horizontal, 20)

            // 詳細展開エリア
            if let metric = expandedMetric {
                MetricDetailView(
                    metric: metric,
                    data: detailData(for: metric),
                    onClose: { expandedMetric = nil }
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }

            // Tuuning Intelligence
            TuuningIntelligenceView()
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
        }
        .background(Color.white.opacity(0.001)) // Hit testing用
        .virgilGlassCard()
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
