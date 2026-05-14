import SwiftUI

@MainActor
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            
            // Atmospheric glow
            GlowOrb(color: Color.dsGold.opacity(0.12), size: 400, blur: 120)
                .offset(x: 80, y: -180)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Color.dsSecondary)
                            .frame(width: 36, height: 36)
                            .background(Color.dsSurfaceHigh)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 24) {
                            // Badge
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10))
                                Text("PREMIUM")
                                    .font(.dsLabel(9))
                                    .tracking(3.5)
                            }
                            .foregroundStyle(LinearGradient.dsGoldGradient)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.dsGold.opacity(0.1))
                            .clipShape(Capsule())
                            
                            // Title
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Unlock every\nquestion")
                                    .font(.dsDisplay(38, weight: .light))
                                    .foregroundColor(Color.dsPrimary)
                                    .lineSpacing(6)
                                
                                Text("One payment. Lifetime access.")
                                    .font(.dsLabel(15, weight: .regular))
                                    .foregroundColor(Color.dsSecondary)
                            }
                            
                            // Features list
                            VStack(spacing: 16) {
                                FeatureRow(
                                    icon: "infinity",
                                    title: "1400+ Premium Questions",
                                    description: "Access all categories and depth levels"
                                )
                                
                                FeatureRow(
                                    icon: "sparkles",
                                    title: "Unlimited Custom Questions",
                                    description: "Create and save your own prompts"
                                )
                                
                                FeatureRow(
                                    icon: "arrow.clockwise",
                                    title: "Future Updates Included",
                                    description: "New questions added regularly"
                                )
                                
                                FeatureRow(
                                    icon: "bookmark.fill",
                                    title: "Save Unlimited Favorites",
                                    description: "Build your perfect collection"
                                )
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                // Bottom CTA section
                VStack(spacing: 12) {
                    // Purchase button
                    Button(action: handlePurchase) {
                        HStack(spacing: 12) {
                            if isProcessing {
                                ProgressView()
                                    .tint(Color.dsBackground)
                            } else {
                                Text("Unlock Premium")
                                    .font(.dsDisplay(19, weight: .regular))
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 13, weight: .light))
                            }
                        }
                        .foregroundColor(Color.dsBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            ZStack {
                                LinearGradient.dsGoldGradient
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.dsGold.opacity(0.4), radius: 16, x: 0, y: 8)
                    }
                    .disabled(isProcessing)
                    
                    // Price label
                    Text(purchaseManager.formattedPrice)
                        .font(.dsLabel(13, weight: .medium))
                        .foregroundColor(Color.dsSecondary)
                    
                    // Restore purchases
                    Button(action: handleRestore) {
                        Text("Restore Purchases")
                            .font(.dsLabel(12, weight: .regular))
                            .foregroundColor(Color.dsTertiary)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.dsBackground.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Actions
    
    private func handlePurchase() {
        isProcessing = true
        HapticManager.shared.buttonTap()
        
        Task {
            do {
                try await purchaseManager.purchase()
                HapticManager.shared.success()
                dismiss()
            } catch PurchaseError.userCancelled {
                // User cancelled - don't show error
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                HapticManager.shared.error()
            }
            isProcessing = false
        }
    }
    
    private func handleRestore() {
        isProcessing = true
        HapticManager.shared.buttonTap()
        
        Task {
            do {
                try await purchaseManager.restorePurchases()
                if purchaseManager.isPremium {
                    HapticManager.shared.success()
                    dismiss()
                } else {
                    errorMessage = "No previous purchases found"
                    showError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                HapticManager.shared.error()
            }
            isProcessing = false
        }
    }
}

// MARK: - Feature Row

@MainActor
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(LinearGradient.dsGoldGradient)
                .frame(width: 44, height: 44)
                .background(Color.dsGold.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.dsLabel(15, weight: .medium))
                    .foregroundColor(Color.dsPrimary)
                
                Text(description)
                    .font(.dsLabel(13, weight: .regular))
                    .foregroundColor(Color.dsSecondary)
                    .lineSpacing(3)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview Helper

extension PurchaseManager {
    static var preview: PurchaseManager {
        let manager = PurchaseManager.shared
        return manager
    }
}
