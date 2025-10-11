//
//  OrbBackground.swift
//  AWStest
//
//  背景グラデーション球体エフェクト - HTML版準拠
//

import SwiftUI

struct OrbBackground: View {
    @State private var animate1 = false
    @State private var animate2 = false
    @State private var animate3 = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Orb 1 (青) - 左上から中央へ移動
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "00A0FF").opacity(0.5),
                                Color(hex: "00E5FF").opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.65
                        )
                    )
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.width * 1.2)
                    .blur(radius: 100)
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
                                Color(hex: "00E676").opacity(0.45),
                                Color(hex: "76FF03").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.65
                        )
                    )
                    .frame(width: geometry.size.width * 1.0, height: geometry.size.width * 1.0)
                    .blur(radius: 90)
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
                                Color(hex: "FFD700").opacity(0.4),
                                Color(hex: "FFA000").opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.6
                        )
                    )
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                    .blur(radius: 80)
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
