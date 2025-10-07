//
//  Colors.swift
//  AWStest
//
//  Virgilデザインシステム - カラーパレット定義
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    /// Primary Color: #667EEA
    static let virgilPrimary = Color(hex: "667EEA")

    /// Primary Hover: #5568D3
    static let virgilPrimaryHover = Color(hex: "5568D3")

    // MARK: - Background Colors

    /// Main Background: #0A0E27
    static let virgilBackground = Color(hex: "0A0E27")

    /// Card Background (with transparency): rgba(255, 255, 255, 0.05)
    static let virgilCardBackground = Color.white.opacity(0.05)

    // MARK: - Text Colors

    /// Primary Text: #FFFFFF
    static let virgilTextPrimary = Color.white

    /// Secondary Text: rgba(255, 255, 255, 0.6)
    static let virgilTextSecondary = Color.white.opacity(0.6)

    /// Tertiary Text: rgba(255, 255, 255, 0.4)
    static let virgilTextTertiary = Color.white.opacity(0.4)

    // MARK: - Accent Colors

    /// Success/Positive: #10B981
    static let virgilSuccess = Color(hex: "10B981")

    /// Warning/Alert: #F59E0B
    static let virgilWarning = Color(hex: "F59E0B")

    /// Error/Danger: #EF4444
    static let virgilError = Color(hex: "EF4444")

    /// Info/Neutral: #3B82F6
    static let virgilInfo = Color(hex: "3B82F6")

    // MARK: - Border Colors

    /// Standard Border: rgba(255, 255, 255, 0.1)
    static let virgilBorder = Color.white.opacity(0.1)

    /// Hover Border: rgba(102, 126, 234, 0.5)
    static let virgilBorderHover = Color(hex: "667EEA").opacity(0.5)

    // MARK: - Glassmorphism Colors

    /// Glass Background: rgba(255, 255, 255, 0.1)
    static let virgilGlassBackground = Color.white.opacity(0.1)

    /// Glass Border: rgba(255, 255, 255, 0.2)
    static let virgilGlassBorder = Color.white.opacity(0.2)
}

// MARK: - Hex Color Extension

extension Color {
    /// SwiftUI Color from Hex String
    /// - Parameter hex: 6桁のHEX文字列 (例: "667EEA")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
