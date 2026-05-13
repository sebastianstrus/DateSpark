import SwiftUI

@main
struct DateSparkApp: App {

    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear {
                    // Sync SoundManager with AppState on launch
                    SoundManager.shared.isSoundEnabled = appState.soundEnabled
                }
        }
    }
}
