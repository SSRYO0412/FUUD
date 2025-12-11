//
//  Colors.swift
//  AWStest
//
//  Virgilデザインシステム - カラーパレット定義 (HTML版完全一致)
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors (HTML版完全一致)

    /// Accent Blue: #0088CC
    static let virgilPrimary = Color(hex: "0088CC")

    /// Optimal Green: #00C853
    static let virgilSuccess = Color(hex: "00C853")

    /// Reference Yellow: #FFCB05
    static let virgilWarning = Color(hex: "FFCB05")

    /// Risk Red: #ED1C24
    static let virgilError = Color(hex: "ED1C24")

    /// Info Blue: #0088CC
    static let virgilInfo = Color(hex: "0088CC")

    // MARK: - Neutral Colors (HTML版完全一致)

    /// Off-White Background: #FAFAFA
    static let virgilBackground = Color(hex: "FAFAFA")

    /// Pure White Surface: #FFFFFF
    static let virgilSurface = Color(hex: "FFFFFF")

    /// Black: #000000
    static let virgilBlack = Color(hex: "000000")

    // MARK: - Gray Scale (HTML版完全一致)

    /// Gray 100: #F8F8F8
    static let virgilGray100 = Color(hex: "F8F8F8")

    /// Gray 200: #E8E8E8
    static let virgilGray200 = Color(hex: "E8E8E8")

    /// Gray 300: #D1D1D1
    static let virgilGray300 = Color(hex: "D1D1D1")

    /// Gray 400: #9CA3AF
    static let virgilGray400 = Color(hex: "9CA3AF")

    /// Gray 500: #6B7280
    static let virgilGray500 = Color(hex: "6B7280")

    /// Gray 600: #4B5563
    static let virgilGray600 = Color(hex: "4B5563")

    /// Gray 700: #374151
    static let virgilGray700 = Color(hex: "374151")

    /// Gray 800: #1F2937
    static let virgilGray800 = Color(hex: "1F2937")

    /// Gray 900: #111827
    static let virgilGray900 = Color(hex: "111827")

    // MARK: - Text Colors (HTML版完全一致)

    /// Primary Text: #111827 (Gray 900)
    static let virgilTextPrimary = Color(hex: "111827")

    /// Secondary Text: #6B7280 (Gray 500)
    static let virgilTextSecondary = Color(hex: "6B7280")

    /// Tertiary Text: #9CA3AF (Gray 400)
    static let virgilTextTertiary = Color(hex: "9CA3AF")

    /// Disabled Text: #D1D1D1 (Gray 300)
    static let virgilTextDisabled = Color(hex: "D1D1D1")

    // MARK: - Glassmorphism Colors (HTML版完全一致)

    /// Glass Background: rgba(255, 255, 255, 0.1)
    static let virgilGlassBackground = Color.white.opacity(0.1)

    /// Glass Border: rgba(255, 255, 255, 0.2)
    static let virgilGlassBorder = Color.white.opacity(0.2)

    // MARK: - Lifesum Program Colors

    /// Lifesum Dark Green: #2D4739
    static let lifesumDarkGreen = Color(hex: "2D4739")

    /// Lifesum Light Green: #4A7C59
    static let lifesumLightGreen = Color(hex: "4A7C59")

    /// Lifesum Cream: #F5F2EB
    static let lifesumCream = Color(hex: "F5F2EB")
}

// MARK: - Hex Color Extension

extension Color {
    /// SwiftUI Color from Hex String
    /// - Parameter hex: 6桁のHEX文字列 (例: "0088CC" または "#0088CC")
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
