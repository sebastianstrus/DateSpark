import SwiftUI

// MARK: - Localization Extensions
// These extensions provide localized string keys for the pure Swift models.
// We keep Models.swift free of SwiftUI to maintain Sendable conformance.

@MainActor
extension QuestionCategory {
    /// Localized category name
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    /// Localized category description
    var localizedDescription: LocalizedStringKey {
        LocalizedStringKey(description)
    }
}

@MainActor
extension QuestionDepth {
    /// Localized depth level name
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}
