//
//  PerformanceMetricItem.swift
//  AWStest
//
//  Today's Performance 個別メトリクスアイテム
//

import SwiftUI

struct PerformanceMetricItem: View {
    let icon: String
    let name: String
    let score: String
    let unit: String? // 単位（オプショナル）
    let delta: String
    let deltaType: DeltaType
    let indicator: IndicatorType
    let isExpanded: Bool
    let onTap: () -> Void

    enum DeltaType {
        case positive
        case negative
        case neutral
    }

    var body: some View {
        HStack(spacing: 0) {
            // Icon (カード左端から16pt)
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 32, height: 32)
                .padding(.leading, 16)

            Spacer()
                .frame(width: 12)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                // Name
                Text(name.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)

                // Score + Unit + Delta
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    // Score
                    Text(score)
                        .font(.system(size: 24, weight: .black)) // 20pt→24pt（20%アップ）
                        .foregroundColor(.virgilTextPrimary)

                    // Unit
                    if let unit = unit {
                        Text(unit)
                            .font(.system(size: 18, weight: .semibold)) // 20pt→18pt（10%ダウン）
                            .foregroundColor(.virgilTextPrimary)
                    }

                    Text(delta)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(deltaColor)
                }
            }

            Spacer()

            // Indicator dot
            Circle()
                .fill(Color(hex: indicator.color))
                .frame(width: 8, height: 8)
                .modifier(PulsingIndicatorModifier())
                .padding(.trailing, 16)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }

    private var deltaColor: Color {
        switch deltaType {
        case .positive: return Color(hex: "00C853")
        case .negative: return Color(hex: "ED1C24")
        case .neutral: return Color(hex: "9CA3AF")
        }
    }
}

struct PulsingIndicatorModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .offset(x: isPulsing ? 3 : -3, y: 0)
            .animation(
                Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

#if DEBUG
struct PerformanceMetricItem_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceMetricItem(
            icon: "⚡",
            name: "Recovery",
            score: "87",
            unit: "%",
            delta: "+5%",
            deltaType: .positive,
            indicator: .excellent,
            isExpanded: false,
            onTap: {}
        )
        .padding()
        .background(Color.white)
    }
}
#endif
