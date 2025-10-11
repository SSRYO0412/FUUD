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
        VStack(spacing: 2) {
            // Icon
            Text(icon)
                .font(.system(size: 16))
                .padding(.bottom, 8)

            // Content
            VStack(spacing: 2) {
                // Name
                Text(name.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
                    

                // Score
                Text(score)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.virgilTextPrimary)

                // Delta
                Text(delta)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(deltaColor)
            }

            // Indicator dot (top-right)
            Circle()
                .fill(Color(hex: indicator.color))
                .frame(width: 6, height: 6)
                .modifier(PulsingModifier())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding([.top, .trailing], 8)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
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
