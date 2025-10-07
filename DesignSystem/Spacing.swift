//
//  Spacing.swift
//  AWStest
//
//  Virgilデザインシステム - スペーシング定義
//

import SwiftUI

/// Virgilデザインシステムのスペーシングシステム
struct VirgilSpacing {
    // MARK: - Core Spacing Scale

    /// Extra Small: 4pt
    static let xs: CGFloat = 4

    /// Small: 8pt
    static let sm: CGFloat = 8

    /// Medium: 16pt
    static let md: CGFloat = 16

    /// Large: 24pt
    static let lg: CGFloat = 24

    /// Extra Large: 32pt
    static let xl: CGFloat = 32

    /// 2X Large: 40pt
    static let xl2: CGFloat = 40

    /// 3X Large: 48pt
    static let xl3: CGFloat = 48

    /// 4X Large: 64pt
    static let xl4: CGFloat = 64

    // MARK: - Component-Specific Spacing

    /// Card Padding: 16pt
    static let cardPadding: CGFloat = md

    /// Button Padding Horizontal: 24pt
    static let buttonPaddingH: CGFloat = lg

    /// Button Padding Vertical: 12pt
    static let buttonPaddingV: CGFloat = 12

    /// Section Spacing: 32pt
    static let sectionSpacing: CGFloat = xl

    /// Item Spacing: 16pt
    static let itemSpacing: CGFloat = md

    /// Icon Size Small: 16pt
    static let iconSizeSmall: CGFloat = md

    /// Icon Size Medium: 24pt
    static let iconSizeMedium: CGFloat = lg

    /// Icon Size Large: 32pt
    static let iconSizeLarge: CGFloat = xl

    // MARK: - Border Radius

    /// Border Radius Small: 8pt
    static let radiusSmall: CGFloat = sm

    /// Border Radius Medium: 12pt
    static let radiusMedium: CGFloat = 12

    /// Border Radius Large: 16pt
    static let radiusLarge: CGFloat = md

    /// Border Radius Extra Large: 24pt
    static let radiusXLarge: CGFloat = lg

    /// Border Radius Pill: 9999pt (完全な丸み)
    static let radiusPill: CGFloat = 9999
}

// MARK: - Padding Extensions

extension View {
    /// Virgilデザインシステムのスペーシングを適用 (all sides)
    func virgilPadding(_ spacing: CGFloat) -> some View {
        self.padding(spacing)
    }

    /// Virgilデザインシステムのスペーシングを適用 (horizontal)
    func virgilPaddingH(_ spacing: CGFloat) -> some View {
        self.padding(.horizontal, spacing)
    }

    /// Virgilデザインシステムのスペーシングを適用 (vertical)
    func virgilPaddingV(_ spacing: CGFloat) -> some View {
        self.padding(.vertical, spacing)
    }

    /// カードパディングを適用
    func virgilCardPadding() -> some View {
        self.padding(VirgilSpacing.cardPadding)
    }

    /// セクションスペーシングを適用
    func virgilSectionSpacing() -> some View {
        self.padding(.vertical, VirgilSpacing.sectionSpacing)
    }
}

// MARK: - Corner Radius Extensions

extension View {
    /// Virgilデザインシステムのborder radiusを適用
    func virgilRadius(_ radius: CGFloat) -> some View {
        self.cornerRadius(radius)
    }

    /// Small radius (8pt)
    func virgilRadiusSmall() -> some View {
        self.cornerRadius(VirgilSpacing.radiusSmall)
    }

    /// Medium radius (12pt)
    func virgilRadiusMedium() -> some View {
        self.cornerRadius(VirgilSpacing.radiusMedium)
    }

    /// Large radius (16pt)
    func virgilRadiusLarge() -> some View {
        self.cornerRadius(VirgilSpacing.radiusLarge)
    }

    /// Extra Large radius (24pt)
    func virgilRadiusXLarge() -> some View {
        self.cornerRadius(VirgilSpacing.radiusXLarge)
    }

    /// Pill radius (完全な丸み)
    func virgilRadiusPill() -> some View {
        self.cornerRadius(VirgilSpacing.radiusPill)
    }
}
