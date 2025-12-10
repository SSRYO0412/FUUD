//
//  OrbBackground.swift
//  AWStest
//
//  背景グラデーション球体エフェクト - HTML版準拠
//

import SwiftUI

struct OrbBackground: View {
    enum ColorStyle {
        case neutral
        case blue
        case green
        case yellow
        case red

        fileprivate var palette: Palette {
            switch self {
            case .neutral:
                return Palette(
                    primary: Color(hex: "00A0FF"),
                    secondary: Color(hex: "00E676"),
                    tertiary: Color(hex: "FFD700")
                )
            case .blue:
                return Palette(
                    primary: Color(hex: "2F80FF"),
                    secondary: Color(hex: "00E5FF"),
                    tertiary: Color(hex: "1D4ED8")
                )
            case .green:
                return Palette(
                    primary: Color(hex: "22C55E"),
                    secondary: Color(hex: "A3E635"),
                    tertiary: Color(hex: "16A34A")
                )
            case .yellow:
                return Palette(
                    primary: Color(hex: "FACC15"),
                    secondary: Color(hex: "FDBA74"),
                    tertiary: Color(hex: "F59E0B")
                )
            case .red:
                return Palette(
                    primary: Color(hex: "FB7185"),
                    secondary: Color(hex: "F87171"),
                    tertiary: Color(hex: "DC2626")
                )
            }
        }
    }

    struct Palette {
        let primary: Color
        let secondary: Color
        let tertiary: Color
    }

    let style: ColorStyle

    @State private var animate1 = false
    @State private var animate2 = false
    @State private var animate3 = false

    init(style: ColorStyle = .neutral) {
        self.style = style
    }

    var body: some View {
        GeometryReader { geometry in
            let palette = style.palette

            ZStack {
                // Orb 1 (青) - 左上から中央へ移動
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                palette.primary.opacity(0.85),
                                palette.primary.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.65
                        )
                    )
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.width * 1.2)
                    .blur(radius: 70)
                    .blendMode(.normal)  // iOS 26 Liquid Glass: 透明度を保つため.normalに変更
                    .offset(
                        x: animate1 ? -geometry.size.width * 0.2 : -geometry.size.width * 0.35,
                        y: animate1 ? -geometry.size.height * 0.1 : -geometry.size.height * 0.25
                    )

                // Orb 2 (緑) - 右下
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                palette.secondary.opacity(0.75),
                                palette.secondary.opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.65
                        )
                    )
                    .frame(width: geometry.size.width * 1.0, height: geometry.size.width * 1.0)
                    .blur(radius: 60)
                    .blendMode(.normal)  // iOS 26 Liquid Glass: 透明度を保つため.normalに変更
                    .offset(
                        x: animate2 ? geometry.size.width * 0.4 : geometry.size.width * 0.5,
                        y: animate2 ? geometry.size.height * 0.5 : geometry.size.height * 0.6
                    )

                // Orb 3 (黄/オレンジ) - 中央右
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                palette.tertiary.opacity(0.7),
                                palette.tertiary.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.6
                        )
                    )
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                    .blur(radius: 55)
                    .blendMode(.normal)  // iOS 26 Liquid Glass: 透明度を保つため.normalに変更
                    .offset(
                        x: animate3 ? geometry.size.width * 0.3 : geometry.size.width * 0.4,
                        y: animate3 ? geometry.size.height * 0.25 : geometry.size.height * 0.35
                    )
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate1 = true
            }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate2 = true
            }
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                animate3 = true
            }
        }
    }
}
