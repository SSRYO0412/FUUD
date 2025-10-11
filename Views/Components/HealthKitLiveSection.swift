//
//  HealthKitLiveSection.swift
//  AWStest
//
//  HealthKit LIVEセクション - リアルタイムHealthKitデータ表示
//

import SwiftUI

struct HealthKitLiveSection: View {
    @State private var metrics = HealthKitMetric.samples // [DUMMY] 実際のHealthKitデータに置き換え
    @State private var lastUpdated = Date()
    @State private var timeSinceUpdate: TimeInterval = 2

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    // Pulsing dot
                    Circle()
                        .fill(Color(hex: "00C853"))
                        .frame(width: 6, height: 6)
                        .modifier(PulsingModifier())

                    Text("HEALTHKIT LIVE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.virgilTextSecondary)
                }

                Spacer()

                Text("Updated \(formattedUpdateTime)")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundColor(.virgilGray400)
            }
            .padding(.bottom, 12)

            // Metrics Grid
            HStack(spacing: 8) {
                ForEach(metrics.indices, id: \.self) { index in
                    HealthKitMetricItem(metric: metrics[index])
                }
            }
            .padding(.bottom, 8)

            // Waveform Animation
            WaveformView()
        }
        .padding(20)
        .onAppear {
            startUpdatingTime()
        }
    }

    private var formattedUpdateTime: String {
        let seconds = Int(timeSinceUpdate)
        if seconds < 60 {
            return "\(seconds)s ago"
        } else {
            return "1m ago"
        }
    }

    private func startUpdatingTime() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeSinceUpdate = Date().timeIntervalSince(lastUpdated)

            // [DUMMY] 実際はSwift側からのpush更新に置き換え
            if timeSinceUpdate >= 120 {
                lastUpdated = Date()
                timeSinceUpdate = 2
            }
        }
    }
}

// MARK: - HealthKit Metric Item

struct HealthKitMetricItem: View {
    let metric: HealthKitMetric

    var body: some View {
        VStack(spacing: 4) {
            Text(metric.label.uppercased())
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(.virgilGray400)

            Text(metric.value + metric.unit)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.virgilTextPrimary)

            Text(metric.trend.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: metric.trend.color))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Pulsing Modifier

struct PulsingModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
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

// MARK: - Waveform Placeholder

struct WaveformPlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.01))
            .frame(height: 40)
            .cornerRadius(4)
            .overlay(
                Text("波形アニメーション") // [DUMMY] Phase 5で実装予定
                    .font(.system(size: 8))
                    .foregroundColor(.virgilGray400)
            )
    }
}

// MARK: - Preview

#if DEBUG
struct HealthKitLiveSection_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitLiveSection()
            .padding()
            .background(Color.white)
    }
}
#endif
