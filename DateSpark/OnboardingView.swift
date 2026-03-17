import SwiftUI

struct OnboardingPage: Identifiable, Sendable {
    let id        = UUID()
    let number:     String
    let eyebrow:    String
    let title:      String
    let body:       String
    let symbol:     String
}

@MainActor
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(number: "01", eyebrow: "Welcome",    title: "Deeper\nConversations", body: "Thoughtfully crafted questions designed to move past small talk — for first dates, old friends, and every meaningful encounter.", symbol: "quote.bubble"),
        OnboardingPage(number: "02", eyebrow: "Discover",   title: "Eight\nCategories",    body: "From gentle ice-breakers to profound questions about love and life. Spin the wheel or choose your own direction.", symbol: "circle.grid.2x2"),
        OnboardingPage(number: "03", eyebrow: "Navigate",   title: "Swipe\nFreely",        body: "Swipe right when a question resonates. Swipe left to pass. Every card is a doorway — open the ones that call to you.", symbol: "hand.draw"),
        OnboardingPage(number: "04", eyebrow: "Collect",    title: "Build Your\nCollection", body: "Bookmark questions that spark something real. Return to your collection whenever you need the right words.", symbol: "bookmark"),
    ]

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            // Corner atmospheric light
            GlowOrb(color: Color.dsGold.opacity(0.08), size: 350, blur: 100)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 80, y: -80)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // DATESPARK wordmark top
                HStack {
                    Text("DATESPARK")
                        .font(.dsLabel(10))
                        .tracking(4)
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                // Bottom controls
                VStack(spacing: 24) {
                    // Progress indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            if i == currentPage {
                                LinearGradient.dsGoldGradient
                                    .frame(width: 28, height: 2)
                                    .clipShape(Capsule())
                            } else {
                                Color.dsTertiary
                                    .frame(width: 8, height: 2)
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                    }
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                    .padding(.horizontal, 32)

                    // CTA button
                    Button(action: handleCTA) {
                        HStack(spacing: 12) {
                            Text(currentPage == pages.count - 1 ? "Begin" : "Continue")
                                .font(.dsDisplay(20, weight: .regular))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .light))
                        }
                        .foregroundColor(Color.dsBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            ZStack {
                                Color.dsPrimary
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 52)
            }
        }
    }

    private func handleCTA() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            appState.hasCompletedOnboarding = true
        }
    }
}

@MainActor
struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 28) {
                // Large decorative number
                Text(page.number)
                    .font(.system(size: 100, weight: .ultraLight, design: .serif))
                    .foregroundStyle(LinearGradient.dsGoldGradient)
                    .opacity(0.35)
                    .offset(y: appeared ? 0 : 20)

                VStack(alignment: .leading, spacing: 16) {
                    // Eyebrow
                    HStack(spacing: 10) {
                        LinearGradient.dsGoldGradient
                            .frame(width: 20, height: 1)
                        Text(page.eyebrow.uppercased())
                            .font(.dsLabel(10))
                            .tracking(3.5)
                            .foregroundStyle(LinearGradient.dsGoldGradient)
                    }

                    // Title
                    Text(page.title)
                        .font(.dsDisplay(38, weight: .light))
                        .foregroundColor(Color.dsPrimary)
                        .lineSpacing(8)

                    // Body
                    Text(page.body)
                        .font(.dsLabel(16, weight: .regular))
                        .foregroundColor(Color.dsSecondary)
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) { appeared = true }
        }
        .onDisappear { appeared = false }
    }
}
