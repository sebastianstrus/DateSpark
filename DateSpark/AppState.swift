import SwiftUI
import Observation

/// Central application state using Swift 6's `@Observable` macro.
/// Marked `@MainActor` so all mutations are on the main actor — no extra
/// synchronisation needed from SwiftUI views.
@MainActor
@Observable
final class AppState {

    // MARK: - Persisted state

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    private(set) var favoriteQuestionIDs: Set<UUID> {
        didSet { persistFavorites() }
    }

    // MARK: - Init

    init() {
        let completed = UserDefaults.standard.bool(forKey: Keys.onboarding)
        self.hasCompletedOnboarding = completed

        if let data = UserDefaults.standard.data(forKey: Keys.favorites),
           let ids = try? JSONDecoder().decode([UUID].self, from: data) {
            self.favoriteQuestionIDs = Set(ids)
        } else {
            self.favoriteQuestionIDs = []
        }
    }

    // MARK: - Favorites API

    func toggleFavorite(_ question: Question) {
        if favoriteQuestionIDs.contains(question.id) {
            favoriteQuestionIDs.remove(question.id)
        } else {
            favoriteQuestionIDs.insert(question.id)
        }
    }

    func isFavorite(_ question: Question) -> Bool {
        favoriteQuestionIDs.contains(question.id)
    }

    func clearAllFavorites() {
        favoriteQuestionIDs.removeAll()
    }

    // MARK: - Private helpers

    private func persistFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favoriteQuestionIDs)) {
            UserDefaults.standard.set(encoded, forKey: Keys.favorites)
        }
    }

    private enum Keys {
        static let onboarding = "hasCompletedOnboarding"
        static let favorites  = "favoriteQuestionIDs"
    }
}
