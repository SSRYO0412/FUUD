//
//  LineChartView.swift
//  AWStest
//
//  折れ線グラフビジュアル（老化速度用）
//

import SwiftUI

struct LineChartView: View {
    let dataPoints: [Double] // データポイント配列
    let lineColor: Color
    let gradientColors: [Color]
    var showAxis: Bool = true // 軸表示フラグ

    var body: some View {
        GeometryReader { geometry in
            let chartHeight = showAxis ? geometry.size.height - 20 : geometry.size.height
            let chartWidth = showAxis ? geometry.size.width - 25 : geometry.size.width
            let maxValue = max(dataPoints.max() ?? 100, 100.0)
            let minValue: Double = 0.0
            let range = maxValue - minValue

            ZStack(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    // チャートエリア
                    ZStack(alignment: .bottom) {
                        // グラデーション背景（オプション）
                        if !gradientColors.isEmpty {
                            Path { path in
                                guard !dataPoints.isEmpty else { return }

                                let stepX = chartWidth / CGFloat(max(dataPoints.count - 1, 1))

                                // 開始点
                                let firstY = chartHeight * (1 - CGFloat((dataPoints[0] - minValue) / range))
                                path.move(to: CGPoint(x: showAxis ? 25 : 0, y: firstY))

                                // データポイントを繋ぐ
                                for (index, value) in dataPoints.enumerated() {
                                    let x = (showAxis ? 25 : 0) + CGFloat(index) * stepX
                                    let y = chartHeight * (1 - CGFloat((value - minValue) / range))
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }

                                // 下部を閉じる（グラデーション用）
                                path.addLine(to: CGPoint(x: (showAxis ? 25 : 0) + chartWidth, y: chartHeight))
                                path.addLine(to: CGPoint(x: showAxis ? 25 : 0, y: chartHeight))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(0.3)
                        }

                        // 折れ線
                        Path { path in
                            guard !dataPoints.isEmpty else { return }

                            let stepX = chartWidth / CGFloat(max(dataPoints.count - 1, 1))

                            // 開始点
                            let firstY = chartHeight * (1 - CGFloat((dataPoints[0] - minValue) / range))
                            path.move(to: CGPoint(x: showAxis ? 25 : 0, y: firstY))

                            // データポイントを繋ぐ
                            for (index, value) in dataPoints.enumerated() {
                                let x = (showAxis ? 25 : 0) + CGFloat(index) * stepX
                                let y = chartHeight * (1 - CGFloat((value - minValue) / range))
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        .stroke(lineColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        // すべてのポイントに丸を表示
                        ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, value in
                            let stepX = chartWidth / CGFloat(max(dataPoints.count - 1, 1))
                            let x = (showAxis ? 25 : 0) + CGFloat(index) * stepX
                            let y = chartHeight * (1 - CGFloat((value - minValue) / range))

                            Circle()
                                .fill(lineColor)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                    .frame(height: chartHeight)

                    // 横軸ラベル（日数）
                    if showAxis {
                        HStack {
                            Spacer().frame(width: 25)
                            ForEach(0..<7, id: \.self) { day in
                                Text("\(day + 1)")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 15)
                    }
                }

                // 縦軸ラベル（%）
                if showAxis {
                    VStack(spacing: 0) {
                        VStack {
                            Text("100")
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("50")
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("0")
                                .font(.system(size: 7))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(width: 20, height: chartHeight)

                        Spacer()
                            .frame(height: 15)
                    }
                }
            }
            .onAppear {
                print("📊 LineChartView:")
                print("  - dataPoints: \(dataPoints)")
                print("  - maxValue: \(maxValue), minValue: \(minValue), range: \(range)")
                if let firstPoint = dataPoints.first {
                    let yPercent = (1 - (firstPoint - minValue) / range) * 100
                    print("  - 第1ポイント値: \(firstPoint) → y位置: 上から\(String(format: "%.0f", yPercent))% (下から\(String(format: "%.0f", 100-yPercent))%)")
                }
            }
        }
    }
}

#if DEBUG
struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LineChartView(
                dataPoints: [50, 60, 55, 70, 65, 75, 72],
                lineColor: Color(hex: "9FD356"),
                gradientColors: [Color(hex: "9FD356").opacity(0.5), Color.clear]
            )
            .frame(width: 200, height: 80)

            LineChartView(
                dataPoints: [30, 40, 35, 45, 42],
                lineColor: Color(hex: "F4E04D"),
                gradientColors: []
            )
            .frame(width: 200, height: 80)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
