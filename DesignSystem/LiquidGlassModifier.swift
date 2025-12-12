//
//  LiquidGlassModifier.swift
//  AWStest
//
//  Apple公式Liquid Glass（Clear Glass）スタイル
//  iOS 26+: .glassEffect(.regular) を使用
//  iOS 15-25: .ultraThinMaterial フォールバック
//

import SwiftUI

// MARK: - Liquid Glass Card Modifier

extension View {
    /// Apple公式Liquid Glass（Clear Glass）スタイルをカードに適用
    /// 全カードでこのModifierを使用すること
    ///
    /// - Parameter cornerRadius: 角丸の半径（デフォルト: 16）
    /// - Returns: Liquid Glass効果が適用されたView
    @ViewBuilder
    func liquidGlassCard(cornerRadius: CGFloat = 16) -> some View {
        if #available(iOS 26.0, *) {
            self.background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius, style: .continuous))
            )
        } else {
            self.background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}
