//
//  HealthMetricCard.swift
//  AWStest
//
//  健康指標カード（Apple Watchスタイル）
//

import SwiftUI

enum MetricVisualType {
    case horizontalBar
    case segmentedBar
    case semiCircleGauge
    case lineChart
}

struct HealthMetricCard: View {
    let title: String
    let iconName: String
    let scoreValue: String
    let scoreUnit: String?
    let statusText: String
    let statusColor: Color
    let visualType: MetricVisualType
    let progress: Double // 0.0 ~ 1.0

    // 折れ線グラフ用データ（オプション）
    var chartDataPoints: [Double] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー: タイトル + アイコン
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // スコア値
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(scoreValue)
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.white)

                if let unit = scoreUnit {
                    Text(unit)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // ステータステキスト
                Text(statusText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(statusColor)
            }

            // ビジュアル要素
            visualContent
                .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "2C2C2E"))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }

    @ViewBuilder
    private var visualContent: some View {
        switch visualType {
        case .horizontalBar:
            HorizontalBarView(
                progress: progress,
                colors: [Color(hex: "F4E04D"), Color(hex: "9FD356"), Color(hex: "4FC0D0")]
            )
            .frame(height: 12)
            .padding(.bottom, 4)

        case .segmentedBar:
            SegmentedBarView(
                progress: progress,
                segmentCount: 3,
                activeColor: Color(hex: "5E7CE2"),
                inactiveColor: Color.gray.opacity(0.3)
            )
            .frame(height: 12)
            .padding(.bottom, 4)

        case .semiCircleGauge:
            SemiCircleGaugeView(
                progress: progress,
                gaugeColor: Color(hex: "5E7CE2")
            )
            .frame(height: 50)

        case .lineChart:
            LineChartView(
                dataPoints: chartDataPoints.isEmpty ? [40, 45, 50, 55, 60, 65, 70] : chartDataPoints,
                lineColor: Color(hex: "9FD356"),
                gradientColors: [Color(hex: "9FD356").opacity(0.3), Color.clear]
            )
            .frame(height: 50)
        }
    }
}

#if DEBUG
struct HealthMetricCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                HealthMetricCard(
                    title: "回復",
                    iconName: "arrow.clockwise.circle",
                    scoreValue: "71",
                    scoreUnit: "%",
                    statusText: "準備完了",
                    statusColor: Color(hex: "4FC0D0"),
                    visualType: .horizontalBar,
                    progress: 0.71
                )
                .frame(height: 160)

                HealthMetricCard(
                    title: "代謝力",
                    iconName: "flame.circle",
                    scoreValue: "35",
                    scoreUnit: "%",
                    statusText: "低",
                    statusColor: Color(hex: "5E7CE2"),
                    visualType: .segmentedBar,
                    progress: 0.35
                )
                .frame(height: 160)
            }
            .padding()
        }
    }
}
#endif
