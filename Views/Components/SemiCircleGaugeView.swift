//
//  SemiCircleGaugeView.swift
//  AWStest
//
//  半円ゲージビジュアル（炎症レベル用）
//

import SwiftUI

struct SemiCircleGaugeView: View {
    let progress: Double // 0.0 ~ 1.0
    let gaugeColor: Color

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height * 2) / 2 - 6
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height)
            let angle = 180 * progress // 0度（左端）から180度（右端）

            // インジケーター位置計算
            let indicatorX = center.x + radius * cos((180 - angle) * .pi / 180)
            let indicatorY = center.y - radius * sin((180 - angle) * .pi / 180)

            ZStack {
                // 背景の半円
                SemiCircle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)

                // プログレスの半円
                SemiCircle()
                    .trim(from: 0, to: progress)
                    .stroke(gaugeColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))

                // インジケーターポイント（進行度に応じて位置が変わる）
                Circle()
                    .fill(gaugeColor)
                    .frame(width: 16, height: 16)
                    .position(x: indicatorX, y: indicatorY)
                    .shadow(color: gaugeColor.opacity(0.5), radius: 4, x: 0, y: 2)
            }
        }
        .aspectRatio(2, contentMode: .fit)
    }
}

/// 半円パスを作成
struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height * 2) / 2 - 6

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )

        return path
    }
}

#if DEBUG
struct SemiCircleGaugeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            SemiCircleGaugeView(
                progress: 0.4,
                gaugeColor: Color(hex: "5E7CE2")
            )
            .frame(width: 150, height: 75)

            SemiCircleGaugeView(
                progress: 0.75,
                gaugeColor: Color(hex: "00C853")
            )
            .frame(width: 150, height: 75)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
