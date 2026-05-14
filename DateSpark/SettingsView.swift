import SwiftUI

@MainActor
struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    
    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SETTINGS")
                                .font(.dsLabel(9))
                                .tracking(4)
                                .foregroundStyle(LinearGradient.dsGoldGradient)
                            Text("Preferences")
                                .font(.dsDisplay(28, weight: .light))
                                .foregroundColor(Color.dsPrimary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    HairlineDivider()
                    
                    VStack(spacing: 24) {
                        // Premium Status / Unlock
                        if appState.isPremium {
                            SettingsSection(title: "Premium") {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 12))
                                                .foregroundStyle(LinearGradient.dsGoldGradient)
                                            Text("Premium Active")
                                                .font(.dsLabel(15, weight: .medium))
                                                .foregroundColor(Color.dsPrimary)
                                        }
                                        Text("Thank you for your support!")
                                            .font(.dsLabel(13))
                                            .foregroundColor(Color.dsSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(LinearGradient.dsGoldGradient)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.dsGold.opacity(0.08), Color.dsGold.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LinearGradient.dsGoldGradient.opacity(0.3), lineWidth: 1)
                                )
                            }
                        } else {
                            SettingsSection(title: "Premium") {
                                Button {
                                    HapticManager.shared.buttonTap()
                                    showPaywall = true
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "crown.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(LinearGradient.dsGoldGradient)
                                                Text("Unlock Premium")
                                                    .font(.dsLabel(15, weight: .medium))
                                                    .foregroundColor(Color.dsPrimary)
                                            }
                                            Text("1400+ questions • One-time payment")
                                                .font(.dsLabel(13))
                                                .foregroundColor(Color.dsSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(LinearGradient.dsGoldGradient)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(Color.dsSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(LinearGradient.dsGoldGradient.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Restore Purchases
                            Button {
                                HapticManager.shared.buttonTap()
                                handleRestorePurchases()
                            } label: {
                                HStack {
                                    Spacer()
                                    if isRestoring {
                                        ProgressView()
                                            .tint(Color.dsSecondary)
                                    } else {
                                        Text("Restore Purchases")
                                            .font(.dsLabel(13))
                                            .foregroundColor(Color.dsSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            .disabled(isRestoring)
                        }
                        
                        // Language Selector
                        SettingsSection(title: "Language") {
                            Button {
                                HapticManager.shared.buttonTap()
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("App Language")
                                            .font(.dsLabel(15))
                                            .foregroundColor(Color.dsPrimary)
                                        Text(Locale.current.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "en") ?? "English")
                                            .font(.dsLabel(13))
                                            .foregroundColor(Color.dsSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color.dsTertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.dsBorder, lineWidth: 0.8)
                                )
                            }
                        }
                        
                        // Sound Toggle
                        SettingsSection(title: "Sound") {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sound Effects")
                                        .font(.dsLabel(15))
                                        .foregroundColor(Color.dsPrimary)
                                    Text("Enable interaction sounds")
                                        .font(.dsLabel(13))
                                        .foregroundColor(Color.dsSecondary)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { appState.soundEnabled },
                                    set: { newValue in
                                        HapticManager.shared.selection()
                                        appState.soundEnabled = newValue
                                        SoundManager.shared.isSoundEnabled = newValue
                                    }
                                ))
                                .tint(Color.dsGold)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.dsSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.dsBorder, lineWidth: 0.8)
                            )
                        }
                        
                        // Intro Slides
                        SettingsSection(title: "Tutorial") {
                            Button {
                                HapticManager.shared.buttonTap()
                                appState.hasCompletedOnboarding = false
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("View Intro Slides")
                                            .font(.dsLabel(15))
                                            .foregroundColor(Color.dsPrimary)
                                        Text("Rewatch the tutorial")
                                            .font(.dsLabel(13))
                                            .foregroundColor(Color.dsSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color.dsTertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.dsBorder, lineWidth: 0.8)
                                )
                            }
                        }
                        
                        // Legal Section
                        SettingsSection(title: "Legal") {
                            VStack(spacing: 12) {
                                Button {
                                    HapticManager.shared.buttonTap()
                                    UIApplication.shared.open(AppConfiguration.privacyPolicyURL)
                                } label: {
                                    HStack {
                                        Text("Privacy Policy")
                                            .font(.dsBody(15))
                                            .foregroundColor(Color.dsPrimary)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color.dsTertiary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(Color.dsSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.dsBorder, lineWidth: 0.8)
                                    )
                                }
                                
                                Button {
                                    HapticManager.shared.buttonTap()
                                    UIApplication.shared.open(AppConfiguration.termsOfUseURL)
                                } label: {
                                    HStack {
                                        Text("Terms of Use")
                                            .font(.dsBody(15))
                                            .foregroundColor(Color.dsPrimary)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color.dsTertiary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(Color.dsSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.dsBorder, lineWidth: 0.8)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // App Version
                    VStack(spacing: 8) {
                        Text("DateSpark")
                            .font(.dsLabel(11, weight: .medium))
                            .foregroundColor(Color.dsTertiary)
                        Text("Version \(appVersion)")
                            .font(.dsLabel(11))
                            .foregroundColor(Color.dsTertiary.opacity(0.7))
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
    }
    
    private func handleRestorePurchases() {
        isRestoring = true
        
        Task {
            do {
                try await purchaseManager.restorePurchases()
                if purchaseManager.isPremium {
                    restoreMessage = "Premium successfully restored!"
                    HapticManager.shared.success()
                } else {
                    restoreMessage = "No previous purchases found."
                }
            } catch {
                restoreMessage = "Failed to restore purchases. Please try again."
                HapticManager.shared.error()
            }
            showRestoreAlert = true
            isRestoring = false
        }
    }
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
}

@MainActor
struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.dsLabel(10))
                .tracking(2)
                .foregroundColor(Color.dsSecondary)
                .padding(.leading, 4)
                .textCase(.uppercase)
            
            content
        }
    }
}
