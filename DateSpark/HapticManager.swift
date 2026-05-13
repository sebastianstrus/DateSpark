import UIKit
import SwiftUI

/// Centralized haptic feedback manager for the app
@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    private let impactLight      = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium     = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy      = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft       = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid      = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for lower latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Basic Haptics
    
    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }
    
    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }
    
    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }
    
    func soft() {
        impactSoft.impactOccurred()
        impactSoft.prepare()
    }
    
    func rigid() {
        impactRigid.impactOccurred()
        impactRigid.prepare()
    }
    
    func selection() {
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
    }
    
    // MARK: - Notification Haptics
    
    func success() {
        notificationFeedback.notificationOccurred(.success)
        notificationFeedback.prepare()
    }
    
    func warning() {
        notificationFeedback.notificationOccurred(.warning)
        notificationFeedback.prepare()
    }
    
    func error() {
        notificationFeedback.notificationOccurred(.error)
        notificationFeedback.prepare()
    }
    
    // MARK: - Custom Patterns
    
    /// Intensive haptic pattern for wheel spinning
    func wheelSpinTick() {
        impactRigid.impactOccurred(intensity: 0.7)
        impactRigid.prepare()
    }
    
    /// Success pattern when wheel lands on a category
    func wheelLanded() {
        Task {
            medium()
            try? await Task.sleep(for: .milliseconds(100))
            heavy()
        }
    }
    
    /// Card swipe feedback based on direction
    func cardSwipeKeep() {
        success()
    }
    
    func cardSwipePass() {
        light()
    }
    
    /// Card drag threshold reached
    func cardSwipeThresholdReached() {
        selection()
    }
    
    /// Favorite toggle
    func favoriteToggled(isFavorite: Bool) {
        if isFavorite {
            success()
        } else {
            soft()
        }
    }
    
    /// Button tap
    func buttonTap() {
        soft()
    }
    
    /// Tab change
    func tabChanged() {
        selection()
    }
}
