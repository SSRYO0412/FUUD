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
                    // Base glass background
                    Color.virgilGlassBackground

                    // Material blur effect (iOS 15+)
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(intensity.backgroundOpacity)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
                    .strokeBorder(
                        Color.virgilGlassBorder,
                        lineWidth: intensity.borderWidth
                    )
            )
            .cornerRadius(borderRadius)
            .shadow(
                color: Color.black.opacity(intensity.shadowOpacity),
                radius: intensity.shadowRadius,
                x: 0,
                y: intensity.shadowY
            )
    }
}

// MARK: - Glassmorphism Intensity

enum GlassmorphismIntensity {
    case light
    case medium
    case strong

    var backgroundOpacity: Double {
        switch self {
        case .light: return 0.5
        case .medium: return 0.7
        case .strong: return 0.9
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .light: return 0.5
        case .medium: return 1.0
        case .strong: return 1.5
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .light: return 0.1
        case .medium: return 0.2
        case .strong: return 0.3
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .light: return 8
        case .medium: return 16
        case .strong: return 24
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .light: return 2
        case .medium: return 4
        case .strong: return 8
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

    /// カード用グラスモーフィズム (medium intensity, large radius)
    func virgilGlassCard() -> some View {
        self.virgilGlassmorphism(intensity: .medium, radius: VirgilSpacing.radiusLarge)
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
