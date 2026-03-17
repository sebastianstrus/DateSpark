import SwiftUI

@MainActor
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showWheel        = false
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var questions:        [Question]        = []
    @State private var currentIndex      = 0

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            // Single persistent glow — colour animates on category change.
            // Using if/else here caused a full view swap that broke layout.
            GlowOrb(
                color: (selectedCategory?.accentColor ?? Color.dsGold).opacity(0.09),
                size: 420,
                blur: 110
            )
            .offset(x: 70, y: -220)
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 0.7), value: selectedCategory?.rawValue)

            VStack(spacing: 0) {
                HomeHeaderView(
                    selectedCategory: selectedCategory,
                    onSpin:  { withAnimation(.easeOut(duration: 0.3)) { showWheel = true } },
                    onClear: clearCategory
                )

                HairlineDivider()

                if questions.isEmpty {
                    HomeEmptyStateView(onSpin: { withAnimation(.easeOut(duration: 0.3)) { showWheel = true } })
                } else if currentIndex >= questions.count {
                    DeckFinishedView(onRestart: restartDeck)
                } else {
                    QuestionCardDeckView(questions: questions, currentIndex: $currentIndex)
                }
            }

            // Wheel overlay — transitions are driven by withAnimation at call sites
            if showWheel {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.25)) { showWheel = false }
                    }
                    .transition(.opacity)

                SpinWheelView { category in
                    withAnimation(.easeIn(duration: 0.25)) { showWheel = false }
                    loadQuestions(for: category)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 20)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.96).combined(with: .opacity),
                    removal:   .scale(scale: 0.96).combined(with: .opacity)
                ))
            }
        }
    }

    private func loadQuestions(for category: QuestionCategory) {
        selectedCategory = category
        questions        = DataProvider.shared.shuffledQuestions(for: category)
        currentIndex     = 0
    }
    private func clearCategory() {
        selectedCategory = nil; questions = []; currentIndex = 0
    }
    private func restartDeck() {
        questions = questions.shuffled(); currentIndex = 0
    }
}

// MARK: - Header

@MainActor
struct HomeHeaderView: View {
    let selectedCategory: QuestionCategory?
    let onSpin:  () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DATESPARK")
                    .font(.dsLabel(9))
                    .tracking(4)
                    .foregroundStyle(LinearGradient.dsGoldGradient)

                Group {
                    if let cat = selectedCategory {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(cat.accentColor)
                                .frame(width: 6, height: 6)
                            Text(cat.rawValue)
                                .font(.dsDisplay(22, weight: .light))
                                .foregroundColor(Color.dsPrimary)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal:   .opacity
                        ))
                    } else {
                        Text("Choose a category")
                            .font(.dsDisplay(22, weight: .light))
                            .foregroundColor(Color.dsTertiary)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedCategory?.rawValue)
            }

            Spacer()

            HStack(spacing: 10) {
                if selectedCategory != nil {
                    Button(action: onClear) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(Color.dsSecondary)
                            .frame(width: 38, height: 38)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.dsBorder, lineWidth: 0.8)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Button(action: onSpin) {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                        Text("SPIN")
                            .font(.dsLabel(11))
                            .tracking(2.5)
                    }
                    .foregroundColor(Color.dsBackground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(
                        ZStack {
                            LinearGradient.dsGoldGradient
                            LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.clear],
                                startPoint: .top, endPoint: .bottom
                            )
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: Color.dsGold.opacity(0.3), radius: 12, x: 0, y: 4)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCategory != nil)
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 18)
    }
}

// MARK: - Empty state

@MainActor
struct HomeEmptyStateView: View {
    let onSpin: () -> Void
    @State private var glowPulse = false
    @State private var lineWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 32) {
                    // Opening quote flourish
                    Text("\u{201C}")
                        .font(.system(size: 90, weight: .ultraLight, design: .serif))
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                        .opacity(0.5)
                        .frame(height: 50)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            LinearGradient.dsGoldGradient
                                .frame(width: lineWidth, height: 1)
                                .clipShape(Capsule())
                                .animation(.easeOut(duration: 0.7).delay(0.2), value: lineWidth)
                            Text("BEGIN HERE")
                                .font(.dsLabel(9))
                                .tracking(3.5)
                                .foregroundStyle(LinearGradient.dsGoldGradient)
                        }

                        Text("Where would\nyou like to begin?")
                            .font(.dsDisplay(34, weight: .light))
                            .foregroundColor(Color.dsPrimary)
                            .lineSpacing(8)

                        Text("Spin the wheel to discover a category,\nor browse all eight themes.")
                            .font(.dsLabel(15, weight: .regular))
                            .foregroundColor(Color.dsSecondary)
                            .lineSpacing(6)
                    }

                    Button(action: onSpin) {
                        HStack(spacing: 10) {
                            Text("Spin the Wheel")
                                .font(.dsDisplay(17, weight: .regular))
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .light))
                        }
                        .foregroundColor(Color.dsBackground)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 15)
                        .background(
                            ZStack {
                                LinearGradient.dsGoldGradient
                                LinearGradient(colors: [Color.white.opacity(0.1), Color.clear], startPoint: .top, endPoint: .bottom)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(color: Color.dsGold.opacity(0.35), radius: 16, x: 0, y: 6)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 36)

            Spacer()
        }
        .onAppear { lineWidth = 24 }
    }
}

// MARK: - Deck finished

@MainActor
struct DeckFinishedView: View {
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 28) {
                Text("That's\nAll of Them")
                    .font(.dsDisplay(36, weight: .light))
                    .foregroundColor(Color.dsPrimary)
                    .lineSpacing(8)

                LinearGradient.dsGoldGradient
                    .frame(width: 40, height: 0.8)

                Text("You've moved through every question in this category. Shuffle and start again, or explore a new theme.")
                    .font(.dsLabel(15, weight: .regular))
                    .foregroundColor(Color.dsSecondary)
                    .lineSpacing(6)

                Button(action: onRestart) {
                    HStack(spacing: 10) {
                        Text("Shuffle & Restart")
                            .font(.dsDisplay(17, weight: .regular))
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .light))
                    }
                    .foregroundColor(Color.dsBackground)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 15)
                    .background(
                        ZStack {
                            LinearGradient.dsGoldGradient
                            LinearGradient(colors: [Color.white.opacity(0.1), Color.clear], startPoint: .top, endPoint: .bottom)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(color: Color.dsGold.opacity(0.3), radius: 14, x: 0, y: 5)
                }
            }
            .padding(.horizontal, 36)
            Spacer()
        }
    }
}
