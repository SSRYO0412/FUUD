//
//  GlassmorphismModifier.swift
//  AWStest
//
//  Virgilデザインシステム - グラスモーフィズム効果
//  iOS 26: Liquid Glass - 直接.glassEffect()を使用（抽象化レイヤー削除）
//  iOS 15-25: レガシー実装（UIDesignRequiresCompatibility制御）
//

import SwiftUI

// MARK: - Legacy Glassmorphism View Modifier (iOS 15-25)

@available(iOS, introduced: 15, deprecated: 26, message: "Use LiquidGlassModifier with .glassEffect() on iOS 26+")
struct GlassmorphismModifier: ViewModifier {
    var intensity: GlassmorphismIntensity
    var borderRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)  // 背後のブラー効果のみ
            .clipShape(RoundedRectangle(cornerRadius: borderRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(intensity.borderOpacityTop),
                                Color.white.opacity(intensity.borderOpacityBottom)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: intensity.borderWidth
                    )
            )
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 4,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Glassmorphism Intensity

enum GlassmorphismIntensity {
    case ultraThin  // iOS 18通知カード・ウィジェット風の極薄ガラス
    case light
    case medium
    case strong

    /// iOS 26公式: Glass Tint Opacity (rgba(255,255,255,0.1-0.4))
    /// 公式仕様: 10-40%の透明な白色ティント
    var glassTintOpacity: Double {
        switch self {
        case .ultraThin: return 0.02  // 2% - iOS 18通知カード風の極めて透明
        case .light: return 0.08   // 8% - 非常に透明
        case .medium: return 0.15  // 15% - バランス (カード用推奨)
        case .strong: return 0.25  // 25% - やや強め
        }
    }

    /// iOS 26公式: ボーダー上部の明るさ (グラデーション)
    var borderOpacityTop: Double {
        switch self {
        case .ultraThin: return 0.10  // iOS 18通知カード風の極薄ボーダー
        case .light: return 0.25
        case .medium: return 0.35
        case .strong: return 0.45
        }
    }

    /// iOS 26公式: ボーダー下部の明るさ (グラデーション)
    var borderOpacityBottom: Double {
        switch self {
        case .ultraThin: return 0.05  // iOS 18通知カード風の極薄ボーダー
        case .light: return 0.12
        case .medium: return 0.18
        case .strong: return 0.22
        }
    }

    /// iOS 26公式: ボーダー幅
    var borderWidth: CGFloat {
        switch self {
        case .ultraThin: return 0.33  // iOS 18通知カード風の極細ボーダー
        case .light: return 0.5
        case .medium: return 0.5  // 細めのボーダー
        case .strong: return 0.75
        }
    }
}

// MARK: - View Extension

extension View {
    /// iOS 15-25 レガシーグラスモーフィズム効果を適用
    /// iOS 26+では.glassEffect()を直接使用してください
    @available(iOS, introduced: 15, deprecated: 26, message: "Use .glassEffect() directly on iOS 26+")
    func virgilGlassmorphism(
        intensity: GlassmorphismIntensity = .medium,
        radius: CGFloat = VirgilSpacing.radiusLarge
    ) -> some View {
        self.modifier(GlassmorphismModifier(intensity: intensity, borderRadius: radius))
    }

    /// カード用ガラス効果（iOS 26+でLiquid Glass、iOS 15-25でレガシー実装）
    @ViewBuilder
    func virgilGlassCard(interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            // Apple公式パターン: コンテンツに直接.glassEffect()を適用
            // tint追加で視認性向上（iOS 26通知カード・ウィジェットのパターン）
            if interactive {
                self.glassEffect(
                    .regular.tint(.white.opacity(0.15)).interactive(),
                    in: .rect(cornerRadius: 28, style: .continuous)
                )
            } else {
                self.glassEffect(
                    .regular.tint(.white.opacity(0.15)),
                    in: .rect(cornerRadius: 28, style: .continuous)
                )
            }
        } else {
            self.virgilGlassmorphism(intensity: .ultraThin, radius: 28)
        }
    }

    /// ナビゲーションバー用グラスモーフィズム (strong intensity, no radius)
    func virgilGlassNavBar() -> some View {
        self.virgilGlassmorphism(intensity: .strong, radius: 0)
    }

    /// ボトムバー用グラスモーフィズム (strong intensity, top corners only)
    func virgilGlassBottomBar() -> some View {
        self
            .background(
                ZStack {
                    Color.virgilGlassBackground
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)
                }
            )
            .overlay(
                Rectangle()
                    .strokeBorder(
                        Color.virgilGlassBorder,
                        lineWidth: 1.5
                    )
                    .frame(height: 1),
                alignment: .top
            )
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 24,
                x: 0,
                y: -8
            )
    }
}

// MARK: - Optimized Glassmorphism (Performance)

/// パフォーマンス最適化版グラスモーフィズム
/// TechSpikeの検証結果に基づき、blur(70)を使用して60fps維持
struct OptimizedGlassmorphismModifier: ViewModifier {
    var blurRadius: CGFloat = 70 // HTML blur(100px) → SwiftUI blur(70) で最適化
    var borderRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                Color.virgilGlassBackground
                    .blur(radius: blurRadius)
                    .drawingGroup() // GPU acceleration
            )
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
                    .strokeBorder(Color.virgilGlassBorder, lineWidth: 1)
            )
            .cornerRadius(borderRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 4)
    }
}

extension View {
    /// パフォーマンス最適化版グラスモーフィズム (60fps維持)
    func virgilOptimizedGlass(radius: CGFloat = VirgilSpacing.radiusLarge) -> some View {
        self.modifier(OptimizedGlassmorphismModifier(borderRadius: radius))
    }
}
