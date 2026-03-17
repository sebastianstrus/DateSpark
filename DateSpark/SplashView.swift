import SwiftUI

@MainActor
struct SplashView: View {
    @Binding var isShowing: Bool

    @State private var logoOpacity:  Double  = 0
    @State private var logoScale:    CGFloat = 0.85
    @State private var lineWidth:    CGFloat = 0
    @State private var textOpacity:  Double  = 0
    @State private var bgOpacity:    Double  = 1

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            // Atmospheric glow
            GlowOrb(color: Color.dsGold.opacity(0.12), size: 400, blur: 100)
                .offset(x: -60, y: -180)
            GlowOrb(color: Color(hex: "6A4E28").opacity(0.15), size: 300, blur: 80)
                .offset(x: 120, y: 200)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    // Monogram mark
                    ZStack {
                        Circle()
                            .stroke(LinearGradient.dsGoldGradient, lineWidth: 0.8)
                            .frame(width: 72, height: 72)

                        Text("DS")
                            .font(.system(size: 20, weight: .ultraLight, design: .serif))
                            .tracking(4)
                            .foregroundStyle(LinearGradient.dsGoldGradient)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    VStack(spacing: 16) {
                        // Wordmark
                        HStack(spacing: 0) {
                            Text("Date")
                                .font(.dsDisplay(44, weight: .ultraLight))
                                .foregroundColor(Color.dsPrimary)
                            Text("Spark")
                                .font(.dsDisplay(44, weight: .light))
                                .foregroundStyle(LinearGradient.dsGoldGradient)
                        }

                        // Expanding rule
                        LinearGradient.dsGoldGradient
                            .frame(width: lineWidth, height: 0.8)
                            .animation(.easeInOut(duration: 0.7).delay(0.9), value: lineWidth)

                        Text("conversations that matter")
                            .font(.dsLabel(12))
                            .tracking(3)
                            .foregroundColor(Color.dsSecondary)
                    }
                    .opacity(textOpacity)
                }

                Spacer()
            }
        }
        .opacity(bgOpacity)
        .task { await animateIn() }
    }

    private func animateIn() async {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            logoOpacity = 1
            logoScale   = 1
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.6)) {
            textOpacity = 1
        }
        // Trigger line expansion (driven by animation on value change)
        try? await Task.sleep(for: .milliseconds(600))
        lineWidth = 140

        try? await Task.sleep(for: .seconds(2.2))
        guard !Task.isCancelled else { return }
        withAnimation(.easeIn(duration: 0.5)) { bgOpacity = 0 }
        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else { return }
        isShowing = false
    }
}
