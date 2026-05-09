// Models.swift — pure data layer, NO SwiftUI import.
// Keeping this file SwiftUI-free guarantees QuestionCategory, QuestionDepth,
// and Question are fully Sendable with zero @MainActor contamination,
// which is required for Swift 6 strict concurrency.
import Foundation

// MARK: - QuestionCategory
enum QuestionCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case iceBreakers    = "Ice Breakers"
    case dreams         = "Dreams & Goals"
    case childhood      = "Childhood"
    case deepThoughts   = "Deep Thoughts"
    case funAndSilly    = "Fun & Silly"
    case travel         = "Travel"
    case loveAndLife    = "Love & Life"
    case hypothetical   = "Hypothetical"
    case spicy          = "Spicy"
    case closeness36    = "The 36 Experience"
    case custom         = "My Questions"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .iceBreakers:  "flame.fill"
        case .dreams:       "star.fill"
        case .childhood:    "balloon.fill"
        case .deepThoughts: "moon.stars.fill"
        case .funAndSilly:  "face.smiling.fill"
        case .travel:       "airplane"
        case .loveAndLife:  "heart.fill"
        case .hypothetical: "questionmark.bubble.fill"
        case .spicy:        "flame.circle.fill"
        case .closeness36:  "person.2.fill" // Icon representing connection
        case .custom:       "pencil"
        }
    }

    var gradientHex: (String, String) {
        switch self {
        case .iceBreakers:  ("FF6B6B", "FF8E53")
        case .dreams:       ("A78BFA", "7C3AED")
        case .childhood:    ("34D399", "059669")
        case .deepThoughts: ("60A5FA", "1D4ED8")
        case .funAndSilly:  ("FBBF24", "D97706")
        case .travel:       ("F472B6", "BE185D")
        case .loveAndLife:  ("FB7185", "E11D48")
        case .hypothetical: ("38BDF8", "0284C7")
        case .spicy:        ("8B5CF6", "EC4899")
        case .closeness36:  ("D4AF37", "C5B358") // Metallic Gold to Muted Bronze
        case .custom:       ("A3E635", "16A34A")
        }
    }

    var description: String {
        switch self {
        case .iceBreakers:  "Easy, light questions to warm up"
        case .dreams:       "Discover each other's ambitions"
        case .childhood:    "Fun memories from growing up"
        case .deepThoughts: "Get philosophical together"
        case .funAndSilly:  "Laugh and be playful"
        case .travel:       "Adventures near and far"
        case .loveAndLife:  "What matters most to you?"
        case .hypothetical: "What if...?"
        case .spicy:        "Turn up the heat and flirt"
        case .closeness36:  "Scientific path to falling in love"
        case .custom:       "Your personal prompts"
        }
    }
}

// MARK: - QuestionDepth

enum QuestionDepth: String, Codable, Sendable {
    case light  = "Light"
    case medium = "Medium"
    case deep   = "Deep"

    /// Hex string — resolved to Color in the @MainActor display extension.
    var colorHex: String {
        switch self {
        case .light:  "34D399"
        case .medium: "FBBF24"
        case .deep:   "FB7185"
        }
    }
}

// MARK: - Question

struct Question: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let text: String
    let category: QuestionCategory
    let depth: QuestionDepth

    init(id: UUID = UUID(), text: String, category: QuestionCategory, depth: QuestionDepth) {
        self.id       = id
        self.text     = text
        self.category = category
        self.depth    = depth
    }
}

// MARK: - Safe Array Subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
