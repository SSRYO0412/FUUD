//
//  GlassmorphismModifier.swift
//  AWStest
//
//  Virgilデザインシステム - グラスモーフィズム効果
//

import SwiftUI

// MARK: - Glassmorphism View Modifier

struct GlassmorphismModifier: ViewModifier {
    var intensity: GlassmorphismIntensity
    var borderRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // iOS 26 Liquid Glass公式仕様: 透明な白ティント (10-40%)
                    // ultraThinMaterialではなく純粋な白色を使用してグレー味を除去
                    RoundedRectangle(cornerRadius: borderRadius)
                        .fill(Color.white.opacity(intensity.glassTintOpacity))
                        .background(
                            // 背景のぼかし効果
                            RoundedRectangle(cornerRadius: borderRadius)
                                .fill(.ultraThinMaterial)
                                .opacity(0.1) // 最小限のmaterial効果
                        )
                }
            )
            .overlay(
                // 公式: Inner Shadow (blur 15px, inset)
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    .blur(radius: 15)
                    .offset(x: 0, y: 0)
                    .mask(
                        RoundedRectangle(cornerRadius: borderRadius)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
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
                color: Color.black.opacity(0.15), // より軽いシャドウ
                radius: 6,
                x: 0,
                y: 6
            )
    }
}

// MARK: - Glassmorphism Intensity

enum GlassmorphismIntensity {
    case light
    case medium
    case strong

    /// iOS 26公式: Glass Tint Opacity (rgba(255,255,255,0.1-0.4))
    /// 公式仕様: 10-40%の透明な白色ティント
    var glassTintOpacity: Double {
        switch self {
        case .light: return 0.1   // 10% - 非常に透明
        case .medium: return 0.2  // 20% - バランス (カード用推奨)
        case .strong: return 0.3  // 30% - やや強め
        }
    }

    /// iOS 26公式: ボーダー上部の明るさ (グラデーション)
    var borderOpacityTop: Double {
        switch self {
        case .light: return 0.5
        case .medium: return 0.6
        case .strong: return 0.7
        }
    }

    /// iOS 26公式: ボーダー下部の明るさ (グラデーション)
    var borderOpacityBottom: Double {
        switch self {
        case .light: return 0.2
        case .medium: return 0.25
        case .strong: return 0.3
        }
    }

    /// iOS 26公式: ボーダー幅
    var borderWidth: CGFloat {
        switch self {
        case .light: return 0.5
        case .medium: return 0.5  // 細めのボーダー
        case .strong: return 0.75
        }
    }
}

// MARK: - View Extension

extension View {
    /// Virgilデザインシステムのグラスモーフィズム効果を適用
    /// - Parameters:
    ///   - intensity: エフェクトの強度 (.light, .medium, .strong)
    ///   - radius: border radius (デフォルト: 16pt)
    func virgilGlassmorphism(
        intensity: GlassmorphismIntensity = .medium,
        radius: CGFloat = VirgilSpacing.radiusLarge
    ) -> some View {
        self.modifier(GlassmorphismModifier(intensity: intensity, borderRadius: radius))
    }

    /// カード用グラスモーフィズム (iOS 26公式: radius 28px)
    func virgilGlassCard() -> some View {
        self.virgilGlassmorphism(intensity: .medium, radius: 28)
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
