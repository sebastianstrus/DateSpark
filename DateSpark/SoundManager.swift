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
    
    /// Play the spinning wheel sound
    /// Add your sound file to the project with name "wheel_spin.mp3" or "wheel_spin.wav"
    func playWheelSpin() {
        guard isSoundEnabled else { return }
        
        // Try to find the sound file in the bundle
        // Supports common audio formats: mp3, wav, m4a, caf
        let soundFileNames = ["wheel_spin", "wheel-spin", "spin", "wheel"]
        let extensions = ["mp3", "wav", "m4a", "caf", "aiff"]
        
        var soundURL: URL?
        
        for fileName in soundFileNames {
            for ext in extensions {
                if let url = Bundle.main.url(forResource: fileName, withExtension: ext) {
                    soundURL = url
                    break
                }
            }
            if soundURL != nil { break }
        }
        
        guard let url = soundURL else {
            print("Wheel spin sound file not found. Add a file named 'wheel_spin.mp3' (or similar) to the project.")
            return
        }
        
        do {
            wheelSpinPlayer = try AVAudioPlayer(contentsOf: url)
            wheelSpinPlayer?.numberOfLoops = 0 // Play once
            wheelSpinPlayer?.volume = 0.6
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
