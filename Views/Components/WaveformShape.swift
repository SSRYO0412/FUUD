//
//  WaveformShape.swift
//  AWStest
//
//  HealthKit LIVE 波形アニメーション
//

import SwiftUI

// MARK: - Wave Layer Configuration

struct WaveLayerConfig {
    let frequency: Double       // 波の周波数（高いほど細かい波）
    let amplitude: Double       // 振幅（波の高さ）
    let speed: Double           // 移動速度
    let offset: Double          // 初期位相オフセット
    let colors: [Color]         // グラデーションカラー
    let opacity: Double         // 透明度
}

// MARK: - Waveform View

struct WaveformView: View {
    @State private var time: Double = 0
    @State private var timer: Timer?

    // 各レイヤーの固定パラメータ（初期化時に設定、以降変更なし）
    // [DUMMY] 実際のHealthKitデータに応じて動的に調整予定
    private let layer1Config = WaveLayerConfig(
        frequency: 1.2,
        amplitude: 16.0, // 8.0 → 16.0（2倍）
        speed: 0.3,
        offset: 0.0,
        colors: [Color(hex: "0088CC"), Color(hex: "00C853")],
        opacity: 0.3
    )

    private let layer2Config = WaveLayerConfig(
        frequency: 1.8,
        amplitude: 12.0, // 6.0 → 12.0（2倍）
        speed: 0.5,
        offset: 2.0,
        colors: [Color(hex: "00DDFF"), Color(hex: "FFCB05")],
        opacity: 0.25
    )

    private let layer3Config = WaveLayerConfig(
        frequency: 0.9,
        amplitude: 20.0, // 10.0 → 20.0（2倍）
        speed: 0.4,
        offset: 4.0,
        colors: [Color(hex: "E91E63"), Color(hex: "9C27B0")],
        opacity: 0.2
    )

    var body: some View {
        Canvas { context, size in
            // Layer 1: 青-緑グラデーション（ゆったりとした大きな波）- 上下対称
            drawSymmetricWaveLayer(
                context: context,
                size: size,
                config: layer1Config,
                time: time
            )

            // Layer 2: シアン-黄グラデーション（細かく速い波）- 上下対称
            drawSymmetricWaveLayer(
                context: context,
                size: size,
                config: layer2Config,
                time: time
            )

            // Layer 3: 赤-紫グラデーション（最も大きくゆっくりな波）- 上下対称
            drawSymmetricWaveLayer(
                context: context,
                size: size,
                config: layer3Config,
                time: time
            )
        }
        .frame(height: 40)
        .background(Color.black.opacity(0.01))
        // [DUMMY] cornerRadius削除 - 画面幅いっぱいに波形を表示するため
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Animation Control

    private func startAnimation() {
        // 60FPSでtimeを更新（0.016秒 ≈ 16ms）
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            time += 0.016
        }
    }

    // MARK: - Wave Drawing

    // 上下対称の波形を描画
    private func drawSymmetricWaveLayer(
        context: GraphicsContext,
        size: CGSize,
        config: WaveLayerConfig,
        time: Double
    ) {
        // 上半分のパス（中心から上方向）
        let upperPath = generateSymmetricWavePath(
            size: size,
            config: config,
            time: time,
            isUpper: true
        )

        // 下半分のパス（中心から下方向）
        let lowerPath = generateSymmetricWavePath(
            size: size,
            config: config,
            time: time,
            isUpper: false
        )

        // グラデーション作成（透明度を考慮）
        let adjustedColors = config.colors.map { $0.opacity(config.opacity) }
        let gradient = Gradient(colors: adjustedColors)

        // 上半分を描画
        context.fill(
            upperPath,
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            )
        )

        // 下半分を描画
        context.fill(
            lowerPath,
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            )
        )
    }

    private func drawWaveLayer(
        context: GraphicsContext,
        size: CGSize,
        config: WaveLayerConfig,
        time: Double
    ) {
        let path = generateWavePath(size: size, config: config, time: time)

        // グラデーション作成（透明度を考慮）
        let adjustedColors = config.colors.map { $0.opacity(config.opacity) }
        let gradient = Gradient(colors: adjustedColors)

        context.fill(
            path,
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            )
        )
    }

    // MARK: - Wave Path Generation

    // 上下対称の波形パスを生成
    private func generateSymmetricWavePath(
        size: CGSize,
        config: WaveLayerConfig,
        time: Double,
        isUpper: Bool
    ) -> Path {
        var path = Path()
        let points = 100  // 滑らかな曲線のため多数のポイント
        let centerY = size.height / 2

        // 波形の各ポイントを計算
        var wavePoints: [CGPoint] = []
        for i in 0...points {
            let x = CGFloat(i) * size.width / CGFloat(points)
            let normalizedX = Double(i) / Double(points)

            // 波の振幅を計算
            let waveAmplitude = calculateWaveAmplitude(
                normalizedX: normalizedX,
                config: config,
                time: time
            )

            // 上半分か下半分かで方向を変える
            let y: CGFloat
            if isUpper {
                y = centerY - abs(waveAmplitude) * config.amplitude
            } else {
                y = centerY + abs(waveAmplitude) * config.amplitude
            }

            wavePoints.append(CGPoint(x: x, y: y))
        }

        // パスを構築
        if let firstPoint = wavePoints.first {
            path.move(to: firstPoint)
            for point in wavePoints.dropFirst() {
                path.addLine(to: point)
            }
        }

        // 塗りつぶしパスを完成させる（中心線で閉じる）
        path.addLine(to: CGPoint(x: size.width, y: centerY))
        path.addLine(to: CGPoint(x: 0, y: centerY))
        path.closeSubpath()

        return path
    }

    private func generateWavePath(
        size: CGSize,
        config: WaveLayerConfig,
        time: Double
    ) -> Path {
        var path = Path()
        let points = 100  // 滑らかな曲線のため多数のポイント

        // 最初のポイント
        let firstY = calculateWaveY(
            normalizedX: 0,
            size: size,
            config: config,
            time: time
        )
        path.move(to: CGPoint(x: 0, y: firstY))

        // 波形の各ポイントを計算
        for i in 1...points {
            let x = CGFloat(i) * size.width / CGFloat(points)
            let normalizedX = Double(i) / Double(points)

            let y = calculateWaveY(
                normalizedX: normalizedX,
                size: size,
                config: config,
                time: time
            )

            path.addLine(to: CGPoint(x: x, y: y))
        }

        // 塗りつぶしパスを完成させる
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()

        return path
    }

    // MARK: - Wave Y Calculation

    // 波の振幅を計算（-1.0 ~ 1.0の範囲）
    private func calculateWaveAmplitude(
        normalizedX: Double,
        config: WaveLayerConfig,
        time: Double
    ) -> CGFloat {
        // 3つの正弦波を合成して有機的な動きを作る
        // 異なる周波数比（1.0, 1.7, 2.3）で不規則な動きを実現

        let wave1 = sin(
            (normalizedX * config.frequency + time * config.speed + config.offset) * .pi * 2
        )

        let wave2 = sin(
            (normalizedX * config.frequency * 1.7 + time * config.speed * 0.8) * .pi * 2
        ) * 0.5

        let wave3 = sin(
            (normalizedX * config.frequency * 2.3 + time * config.speed * 1.2) * .pi * 2
        ) * 0.3

        // 合成波（加重平均）
        let combined = (wave1 + wave2 + wave3) / 1.8

        return combined
    }

    private func calculateWaveY(
        normalizedX: Double,
        size: CGSize,
        config: WaveLayerConfig,
        time: Double
    ) -> CGFloat {
        // 3つの正弦波を合成して有機的な動きを作る
        // 異なる周波数比（1.0, 1.7, 2.3）で不規則な動きを実現

        let wave1 = sin(
            (normalizedX * config.frequency + time * config.speed + config.offset) * .pi * 2
        )

        let wave2 = sin(
            (normalizedX * config.frequency * 1.7 + time * config.speed * 0.8) * .pi * 2
        ) * 0.5

        let wave3 = sin(
            (normalizedX * config.frequency * 2.3 + time * config.speed * 1.2) * .pi * 2
        ) * 0.3

        // 合成波（加重平均）
        let combined = (wave1 + wave2 + wave3) / 1.8

        // Y座標計算（中心からの振幅）
        let y = size.height / 2 + combined * config.amplitude

        return y
    }
}

// MARK: - Preview

#if DEBUG
struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView()
            .padding()
            .background(Color.white)
    }
}
#endif
