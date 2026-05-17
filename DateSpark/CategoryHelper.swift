// CategoryHelper.swift
// Helper to check if certain categories should be shown based on the current date/time

import Foundation

enum CategoryHelper {
    
    /// Returns the list of available categories based on the current date and time.
    /// Before May 16, 2026 at 16:00, hides .spicy and .closeness36 categories.
    static func availableCategories() -> [QuestionCategory] {
        let now = Date()
        
        // Create the unlock date: May 16, 2026 at 16:00 (4:00 PM)
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 23
        components.hour = 14
        components.minute = 30
        
        
        guard let unlockDate = Calendar.current.date(from: components) else {
            return QuestionCategory.allCases.filter { category in
                category != .verySpicy && category != .spicy && category != .closeness36
            }
        }
        
        return QuestionCategory.allCases.filter { category in
            now < unlockDate ? category != .verySpicy : category != .spicy
        }
    }
}
