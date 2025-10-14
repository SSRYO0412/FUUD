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
        TimelineView(.animation) { context in
            VStack(spacing: 0) {
                // Header & Metrics Grid - 左右にpadding適用
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
                                .font(.system(size: 12.88, weight: .bold)) // 9.2 × 1.4 = 12.88
                                .foregroundColor(.virgilTextSecondary)
                        }

                        Spacer()

                        Text("Updated \(formattedUpdateTime)")
                            .font(.system(size: 12.88, weight: .regular)) // 9.2 × 1.4 = 12.88
                            .foregroundColor(.virgilGray400)
                    }
                    .padding(.bottom, 12)

                    // Metrics Grid - 波形と同期して点滅
                    HStack(spacing: 8) {
                        ForEach(metrics.indices, id: \.self) { index in
                            HealthKitMetricItem(metric: metrics[index])
                                .modifier(WaveSyncPulsingModifier(date: context.date))
                        }
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Waveform Animation - 画面幅いっぱいに表示、文字に少し重なるように配置
                WaveformView()
                    .padding(.top, -14)
                    .padding(.bottom, 20)
            }
        }
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
                .font(.system(size: 11.27, weight: .semibold)) // 8.05 × 1.4 = 11.27
                .foregroundColor(.virgilGray400)

            Text(metric.value + metric.unit)
                .font(.system(size: 17.71, weight: .bold)) // 12.65 × 1.4 = 17.71
                .foregroundColor(.virgilTextPrimary)

            Text(metric.trend.rawValue)
                .font(.system(size: 16.1, weight: .semibold)) // 11.5 × 1.4 = 16.1
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

// MARK: - Wave Sync Pulsing Modifier

struct WaveSyncPulsingModifier: ViewModifier {
    let date: Date

    // 波形の動きに合わせて透明度を計算（0.5〜1.0の範囲でより明確な点滅）
    private var calculatedOpacity: Double {
        let time = date.timeIntervalSinceReferenceDate
        // sin波で滑らかな点滅効果（周波数3.0で波形と同期）
        return 0.5 + 0.5 * (1 + sin(time * 3.0)) / 2
    }

    func body(content: Content) -> some View {
        content
            .opacity(calculatedOpacity)
    }
}

// MARK: - Waveform Placeholder

// [DUMMY] 旧プレースホルダー、現在はWaveformViewに置き換え済み、削除予定
struct WaveformPlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.01))
            .frame(height: 40)
            .cornerRadius(4)
            .overlay(
                Text("波形アニメーション")
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
