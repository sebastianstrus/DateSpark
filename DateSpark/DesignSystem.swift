// DesignSystem.swift
// Rich, atmospheric adult design system.
// Palette: deep charcoal · warm ivory · burnished gold · jewel accents

import SwiftUI

// MARK: - Color(hex:) — always included here, nowhere else

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Palette

extension Color {
    // Backgrounds
    static let dsBackground  = Color(hex: "111110")   // warm near-black
    static let dsSurface     = Color(hex: "1A1917")   // card surface
    static let dsSurfaceHigh = Color(hex: "232220")   // elevated surface
    static let dsBorder      = Color(hex: "323028")   // warm border

    // Text
    static let dsPrimary     = Color(hex: "F2ECD8")   // warm parchment
    static let dsSecondary   = Color(hex: "9C9280")   // warm mid-grey
    static let dsTertiary    = Color(hex: "524E46")   // dim warm grey

    // Gold system — rich, not flat
    static let dsGold        = Color(hex: "C9A96E")   // burnished gold
    static let dsGoldBright  = Color(hex: "E8C98A")   // highlight gold
    static let dsGoldDim     = Color(hex: "5C4A2A")   // deep gold shadow

    // Swipe states
    static let dsConfirm     = Color(hex: "7AAE84")   // sage green
    static let dsDecline     = Color(hex: "AE7A7A")   // muted rose
}

// MARK: - Category accents — distinct jewel tones, readable on dark

@MainActor
extension QuestionCategory {
    var accentColor: Color {
        switch self {
        case .iceBreakers:  Color(hex: "D4956A")  // terracotta
        case .dreams:       Color(hex: "8A96C8")  // periwinkle
        case .childhood:    Color(hex: "7AB893")  // sage
        case .deepThoughts: Color(hex: "6A9EC8")  // slate blue
        case .funAndSilly:  Color(hex: "D4B86A")  // amber
        case .travel:       Color(hex: "C87A9E")  // dusty rose
        case .loveAndLife:  Color(hex: "C87A7A")  // terracotta rose
        case .hypothetical: Color(hex: "7ABCC8")  // teal
        case .spicy:        Color(hex: "9B6B9D")  // deep plum
        case .custom:       Color(hex: "6FBF73")  // fresh green
        }
    }

    var gradient: [Color] { [accentColor, accentColor.opacity(0.5)] }
}

// MARK: - Depth colours

@MainActor
extension QuestionDepth {
    var color: Color {
        switch self {
        case .light:  Color(hex: "7AAE84")
        case .medium: Color(hex: "C9A96E")
        case .deep:   Color(hex: "AE7A7A")
        }
    }
}

// MARK: - Typography

extension Font {
    static func dsDisplay(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func dsLabel(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func dsMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

// MARK: - Shared components

struct HairlineDivider: View {
    var opacity: Double = 1.0
    var body: some View {
        Rectangle()
            .fill(Color.dsBorder.opacity(opacity))
            .frame(height: 0.5)
    }
}

// Glowing orb for atmospheric backgrounds
struct GlowOrb: View {
    let color: Color
    let size: CGFloat
    let blur: CGFloat
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: blur)
            .allowsHitTesting(false)
    }
}

// Gold gradient used on accents.
// Raw sRGB values are used directly — avoids referencing @MainActor-isolated
// Color statics from a nonisolated LinearGradient extension context.
extension LinearGradient {
    static var dsGoldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.sRGB, red: 0.910, green: 0.788, blue: 0.541, opacity: 1), // #E8C98A dsGoldBright
                Color(.sRGB, red: 0.788, green: 0.663, blue: 0.431, opacity: 1), // #C9A96E dsGold
                Color(.sRGB, red: 0.627, green: 0.471, blue: 0.251, opacity: 1), // #A07840 deep gold
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
