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
        components.day = 17
        components.hour = 20
        components.minute = 0
        
        guard let unlockDate = Calendar.current.date(from: components) else {
            // If we can't create the unlock date, show all categories
            return QuestionCategory.allCases
        }
        
        // If current time is before unlock date, filter out .spicy and .closeness36
        if now < unlockDate {
            return QuestionCategory.allCases.filter { category in
                category != .spicy && category != .closeness36
            }
        }
        
        // After unlock date, show all categories
        return QuestionCategory.allCases
    }
}
