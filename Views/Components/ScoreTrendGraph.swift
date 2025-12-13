//
//  ScoreTrendGraph.swift
//  AWStest
//
//  汎用スコアトレンドグラフコンポーネント
//

import SwiftUI

struct ScoreTrendGraph: View {
    let scores: [Int]  // 過去6ヶ月のスコア、API連携後に実データ使用

    // 月のラベルを生成（現在月から6ヶ月前まで）
    private var monthLabels: [String] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<scores.count).reversed().map { offset in
            if let date = calendar.date(byAdding: .month, value: -offset, to: now) {
                let formatter = DateFormatter()
                formatter.dateFormat = "M月"
                return formatter.string(from: date)
            }
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                // Y-axis labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach([100, 75, 50, 25, 0], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.virgilTextSecondary)
                        if value > 0 {
                            Spacer()
                        }
                    }
                }
                .frame(width: 20, height: 150)

                // Graph
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        // Grid lines
                        VStack(spacing: 0) {
                            ForEach(0..<5) { _ in
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                Spacer()
                            }
                        }

                        // Score line
                        Path { path in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let stepX = width / CGFloat(scores.count - 1)

                            for (index, score) in scores.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = height - (CGFloat(score) / 100.0 * height)

                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color(hex: "00C853"), lineWidth: 3)

                        // Data points
                        HStack(spacing: 0) {
                            ForEach(scores.indices, id: \.self) { index in
                                VStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color(hex: "00C853"))
                                        .frame(width: 8, height: 8)
                                        .offset(y: -(CGFloat(scores[index]) / 100.0 * geometry.size.height))
                                }
                                if index < scores.count - 1 {
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .frame(height: 150)
            }

            // X-axis (month labels)
            HStack(spacing: 8) {
                Spacer()
                    .frame(width: 20)

                HStack(spacing: 0) {
                    ForEach(monthLabels.indices, id: \.self) { index in
                        Text(monthLabels[index])
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.virgilTextSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ScoreTrendGraph_Previews: PreviewProvider {
    static var previews: some View {
        ScoreTrendGraph(scores: [78, 82, 85, 88, 90, 92])  // プレビュー用データ
            .padding()
            .background(Color.white)
    }
}
#endif
