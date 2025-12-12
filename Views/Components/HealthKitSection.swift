//
//  HealthKitSection.swift
//  AWStest
//
//  HealthKitデータセクションコンポーネント
//

import SwiftUI

// MARK: - Data Model

struct HealthKitSectionMetric {
    let name: String
    let value: String
    let status: String
}

// MARK: - HealthKit Section

struct HealthKitSection: View {
    let metrics: [HealthKitSectionMetric]  // [DUMMY] HealthKitデータ、API連携後に実データ使用

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("📊")
                    .font(.system(size: 16))
                Text("RELATED HEALTHKIT")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }

            VStack(spacing: VirgilSpacing.sm) {
                ForEach(metrics.indices, id: \.self) { index in
                    HealthKitMetricRow(metric: metrics[index])
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }
}

// MARK: - HealthKit Metric Row

private struct HealthKitMetricRow: View {
    let metric: HealthKitSectionMetric

    // ステータスに応じた色分け (Optimal/最適=緑, Reference/正常範囲=黄, Risk/注意=赤)
    private var statusColor: Color {
        switch metric.status {
        case "最適", "優秀", "Optimal", "Excellent":
            return Color(hex: "00C853")  // 緑
        case "良好", "正常範囲", "Reference", "Good", "Normal":
            return Color(hex: "FFCB05")  // 黄
        case "注意", "要注意", "Risk", "Warning":
            return Color(hex: "ED1C24")  // 赤
        default:
            return Color.gray
        }
    }

    var body: some View {
        HStack {
            Text(metric.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Text(metric.value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            Text(metric.status)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(statusColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#if DEBUG
struct HealthKitSection_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitSection(metrics: [
            // [DUMMY] プレビュー用データ
            HealthKitSectionMetric(name: "睡眠時間", value: "7.5時間", status: "最適"),
            HealthKitSectionMetric(name: "HRV", value: "68ms", status: "優秀"),
            HealthKitSectionMetric(name: "歩数", value: "8,500歩", status: "良好")
        ])
        .padding()
        .background(Color.white)
    }
}
#endif
