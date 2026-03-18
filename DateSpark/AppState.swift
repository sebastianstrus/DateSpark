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

    // User-created custom questions (persisted)
    var customQuestions: [Question] {
        didSet { persistCustomQuestions() }
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

        if let data = UserDefaults.standard.data(forKey: Keys.custom),
           let qs = try? JSONDecoder().decode([Question].self, from: data) {
            self.customQuestions = qs
        } else {
            self.customQuestions = []
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

    // MARK: - Custom Questions API

    func addCustomQuestion(text: String, depth: QuestionDepth = .light) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let q = Question(text: trimmed, category: .custom, depth: depth)
        var updated = customQuestions
        updated.insert(q, at: 0)
        customQuestions = updated
    }

    func removeCustomQuestion(_ question: Question) {
        var updated = customQuestions
        if let idx = updated.firstIndex(where: { $0.id == question.id }) {
            updated.remove(at: idx)
            customQuestions = updated
        }
    }

    // MARK: - Private

    private func persistFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteQuestions) {
            UserDefaults.standard.set(encoded, forKey: Keys.favorites)
        }
    }

    private func persistCustomQuestions() {
        if let encoded = try? JSONEncoder().encode(customQuestions) {
            UserDefaults.standard.set(encoded, forKey: Keys.custom)
        }
    }

    private enum Keys {
        static let onboarding = "hasCompletedOnboarding"
        static let favorites  = "favoriteQuestionIDs"
        static let custom     = "customQuestions"
    }
}
