//
//  Typography.swift
//  AWStest
//
//  Virgilデザインシステム - タイポグラフィ定義
//

import SwiftUI

extension Font {
    // MARK: - Font Families

    /// Inter font family (Primary)
    static let virgilFontFamily = "Inter"

    /// JetBrains Mono font family (Monospace)
    static let virgilMonoFontFamily = "JetBrains Mono"

    // MARK: - Display Fonts

    /// Display Large: 48px / 3rem, weight 700
    static let virgilDisplayLarge = Font.custom(virgilFontFamily, size: 48).weight(.bold)

    /// Display Medium: 40px / 2.5rem, weight 600
    static let virgilDisplayMedium = Font.custom(virgilFontFamily, size: 40).weight(.semibold)

    /// Display Small: 32px / 2rem, weight 600
    static let virgilDisplaySmall = Font.custom(virgilFontFamily, size: 32).weight(.semibold)

    // MARK: - Heading Fonts

    /// Heading 1: 32px / 2rem, weight 600
    static let virgilHeading1 = Font.custom(virgilFontFamily, size: 32).weight(.semibold)

    /// Heading 2: 24px / 1.5rem, weight 600
    static let virgilHeading2 = Font.custom(virgilFontFamily, size: 24).weight(.semibold)

    /// Heading 3: 20px / 1.25rem, weight 500
    static let virgilHeading3 = Font.custom(virgilFontFamily, size: 20).weight(.medium)

    /// Heading 4: 18px / 1.125rem, weight 500
    static let virgilHeading4 = Font.custom(virgilFontFamily, size: 18).weight(.medium)

    // MARK: - Body Fonts

    /// Body Large: 18px / 1.125rem, weight 400
    static let virgilBodyLarge = Font.custom(virgilFontFamily, size: 18).weight(.regular)

    /// Body: 16px / 1rem, weight 400
    static let virgilBody = Font.custom(virgilFontFamily, size: 16).weight(.regular)

    /// Body Small: 14px / 0.875rem, weight 400
    static let virgilBodySmall = Font.custom(virgilFontFamily, size: 14).weight(.regular)

    // MARK: - Label Fonts

    /// Label Large: 14px / 0.875rem, weight 500
    static let virgilLabelLarge = Font.custom(virgilFontFamily, size: 14).weight(.medium)

    /// Label: 12px / 0.75rem, weight 500
    static let virgilLabel = Font.custom(virgilFontFamily, size: 12).weight(.medium)

    /// Label Small: 11px / 0.6875rem, weight 500
    static let virgilLabelSmall = Font.custom(virgilFontFamily, size: 11).weight(.medium)

    // MARK: - Monospace Fonts

    /// Code Large: 16px / 1rem, JetBrains Mono, weight 400
    static let virgilCodeLarge = Font.custom(virgilMonoFontFamily, size: 16).weight(.regular)

    /// Code: 14px / 0.875rem, JetBrains Mono, weight 400
    static let virgilCode = Font.custom(virgilMonoFontFamily, size: 14).weight(.regular)

    /// Code Small: 12px / 0.75rem, JetBrains Mono, weight 400
    static let virgilCodeSmall = Font.custom(virgilMonoFontFamily, size: 12).weight(.regular)
}

// MARK: - Line Height Extension

extension View {
    /// Virgilデザインシステムのline-heightを適用
    /// - Parameter lineHeight: 行の高さ (1.5 = 150%)
    func virgilLineHeight(_ lineHeight: CGFloat) -> some View {
        self.lineSpacing(lineHeight - 1.0)
    }
}

// MARK: - Typography Presets

struct VirgilTypography {
    /// Display Large: 48px, line-height 1.2, weight 700
    static let displayLarge = (
        font: Font.virgilDisplayLarge,
        lineHeight: 1.2
    )

    /// Display Medium: 40px, line-height 1.2, weight 600
    static let displayMedium = (
        font: Font.virgilDisplayMedium,
        lineHeight: 1.2
    )

    /// Display Small: 32px, line-height 1.3, weight 600
    static let displaySmall = (
        font: Font.virgilDisplaySmall,
        lineHeight: 1.3
    )

    /// Heading 1: 32px, line-height 1.3, weight 600
    static let h1 = (
        font: Font.virgilHeading1,
        lineHeight: 1.3
    )

    /// Heading 2: 24px, line-height 1.4, weight 600
    static let h2 = (
        font: Font.virgilHeading2,
        lineHeight: 1.4
    )

    /// Heading 3: 20px, line-height 1.4, weight 500
    static let h3 = (
        font: Font.virgilHeading3,
        lineHeight: 1.4
    )

    /// Heading 4: 18px, line-height 1.5, weight 500
    static let h4 = (
        font: Font.virgilHeading4,
        lineHeight: 1.5
    )

    /// Body Large: 18px, line-height 1.6, weight 400
    static let bodyLarge = (
        font: Font.virgilBodyLarge,
        lineHeight: 1.6
    )

    /// Body: 16px, line-height 1.6, weight 400
    static let body = (
        font: Font.virgilBody,
        lineHeight: 1.6
    )

    /// Body Small: 14px, line-height 1.5, weight 400
    static let bodySmall = (
        font: Font.virgilBodySmall,
        lineHeight: 1.5
    )

    /// Label Large: 14px, line-height 1.4, weight 500
    static let labelLarge = (
        font: Font.virgilLabelLarge,
        lineHeight: 1.4
    )

    /// Label: 12px, line-height 1.4, weight 500
    static let label = (
        font: Font.virgilLabel,
        lineHeight: 1.4
    )

    /// Label Small: 11px, line-height 1.3, weight 500
    static let labelSmall = (
        font: Font.virgilLabelSmall,
        lineHeight: 1.3
    )

    /// Code Large: 16px, line-height 1.5, JetBrains Mono
    static let codeLarge = (
        font: Font.virgilCodeLarge,
        lineHeight: 1.5
    )

    /// Code: 14px, line-height 1.5, JetBrains Mono
    static let code = (
        font: Font.virgilCode,
        lineHeight: 1.5
    )

    /// Code Small: 12px, line-height 1.4, JetBrains Mono
    static let codeSmall = (
        font: Font.virgilCodeSmall,
        lineHeight: 1.4
    )
}
