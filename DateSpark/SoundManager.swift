import AVFoundation
import SwiftUI

/// Centralized sound manager for the app
@MainActor
final class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var wheelSpinPlayer: AVAudioPlayer?
    var isSoundEnabled: Bool = true
    
    private init() {
        // Sync with AppState's persisted sound preference
        // This will be overridden by the binding in SettingsView
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // Configure audio session to allow mixing with other audio
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Sound Control
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    // MARK: - Wheel Spin Sound
    func playWheelSpin() {
        guard isSoundEnabled,
              let url = Bundle.main.url(forResource: "wheel_spin", withExtension: "mp3") else {
            return
        }
        
        do {
            wheelSpinPlayer = try AVAudioPlayer(contentsOf: url)
            wheelSpinPlayer?.volume = 0.6
            wheelSpinPlayer?.play()
        } catch {
            print("Failed to play wheel spin sound: \(error)")
        }
    }
    
    func playSelected() {
        guard isSoundEnabled,
              let url = Bundle.main.url(forResource: "selected", withExtension: "mp3") else {
            return
        }
        
        do {
            wheelSpinPlayer = try AVAudioPlayer(contentsOf: url)
            wheelSpinPlayer?.volume = 0.2
            wheelSpinPlayer?.play()
        } catch {
            print("Failed to play wheel spin sound: \(error)")
        }
    }
    
    /// Stop the wheel spin sound
    func stopWheelSpin() {
        wheelSpinPlayer?.stop()
        wheelSpinPlayer = nil
    }
    
    /// Play a subtle tick sound during wheel spinning
    /// This creates rhythmic feedback as the wheel spins
    func playWheelTick() {
        guard isSoundEnabled else { return }
        
        // Use system sounds for now - you can replace with custom tick sound later
        AudioServicesPlaySystemSound(1104) // Subtle tick sound
    }
    
    // MARK: - UI Sounds
    
    /// Play a subtle success sound
    func playSuccess() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1519) // Peek notification
    }
    
    /// Play a soft button tap sound
    func playTap() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Key click
    }
}

// MARK: - View Extension for Easy Access

extension View {
    func withHaptic(_ haptic: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                haptic()
            }
        )
    }
}
