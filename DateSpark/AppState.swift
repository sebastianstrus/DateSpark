import SwiftUI
import Observation

@MainActor
@Observable
final class AppState {

    // MARK: - Persisted state

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    // Must be reassigned (not mutated in place) for @Observable to fire.
    var favoriteQuestions: [Question] {
        didSet { persistFavorites() }
    }

    // MARK: - Init

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)

        if let data = UserDefaults.standard.data(forKey: Keys.favorites),
           let qs = try? JSONDecoder().decode([Question].self, from: data) {
            self.favoriteQuestions = qs
        } else {
            self.favoriteQuestions = []
        }
    }

    // MARK: - Favorites API

    func toggleFavorite(_ question: Question) {
        var updated = favoriteQuestions
        if let idx = updated.firstIndex(where: { $0.id == question.id }) {
            updated.remove(at: idx)
        } else {
            updated.append(question)
        }
        favoriteQuestions = updated
    }

    func isFavorite(_ question: Question) -> Bool {
        favoriteQuestions.contains(where: { $0.id == question.id })
    }

    func clearAllFavorites() {
        favoriteQuestions = []        // full reassignment
    }

    // MARK: - Private

    private func persistFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteQuestions) {
            UserDefaults.standard.set(encoded, forKey: Keys.favorites)
        }
    }

    private enum Keys {
        static let onboarding = "hasCompletedOnboarding"
        static let favorites  = "favoriteQuestionIDs"
    }
}
