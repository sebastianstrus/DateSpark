import SwiftUI

@MainActor
struct SettingsView: View {
    @Environment(AppState.self) private var appState
    
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
                        // Language Selector
                        SettingsSection(title: "Language") {
                            Button {
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
                                    set: { appState.soundEnabled = $0 }
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
                                    if let url = URL(string: "https://sebastianstrus.com/documents/datespark/privacy-policy.html") {
                                        UIApplication.shared.open(url)
                                    }
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
                                    if let url = URL(string: "https://sebastianstrus.com/documents/datespark/terms-of-use.html") {
                                        UIApplication.shared.open(url)
                                    }
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
