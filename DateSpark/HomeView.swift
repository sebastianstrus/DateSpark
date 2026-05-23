import SwiftUI

@MainActor
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showWheel        = false
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var questions:        [Question]        = []
    @State private var currentIndex      = 0
    @State private var keptQuestions:    [Question]        = []

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()

            GlowOrb(
                color: Color.dsGold.opacity(0.06),
                size: 360,
                blur: 100)
                .offset(x: 100, y: -100)
                .ignoresSafeArea()

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
                    SessionRecapView(keptQuestions: keptQuestions, onRestart: restartDeck)
                } else {
                    QuestionCardDeckView(
                        questions: questions,
                        currentIndex: $currentIndex,
                        onKeepQuestion: { question in
                            keptQuestions.append(question)
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 90)

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
                .frame(maxWidth: horizontalSizeClass == .regular ? 650 : 500)
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
        if category == .custom {
            questions        = appState.customQuestions.shuffled()
        } else {
            questions        = DataProvider.shared.shuffledQuestionsForDisplay(
                for: category,
                isPremium: appState.isPremium
            )
        }
        currentIndex     = 0
        keptQuestions    = []
    }
    private func clearCategory() {
        selectedCategory = nil; questions = []; currentIndex = 0; keptQuestions = []
    }
    private func restartDeck() {
        // The 36 Experience should not shuffle on restart
        if selectedCategory != .closeness36 {
            questions = questions.shuffled()
        }
        currentIndex = 0
        keptQuestions = []
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
                            Text(cat.localizedName)
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
                    Button(action: { 
                        HapticManager.shared.buttonTap()
                        onClear() 
                    }) {
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

                Button(action: { 
                    HapticManager.shared.buttonTap()
                    onSpin() 
                }) {
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

                        Text("Spin the wheel to discover a category,\nor browse all ten themes.")
                            .font(.dsLabel(15, weight: .regular))
                            .foregroundColor(Color.dsSecondary)
                            .lineSpacing(6)
                    }

                    Button(action: { 
                        HapticManager.shared.buttonTap()
                        onSpin() 
                    }) {
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

// MARK: - Session Recap

@MainActor
struct SessionRecapView: View {
    let keptQuestions: [Question]
    let onRestart: () -> Void
    @Environment(AppState.self) private var appState
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session\nComplete")
                            .font(.dsDisplay(36, weight: .light))
                            .foregroundColor(Color.dsPrimary)
                            .lineSpacing(8)

                        LinearGradient.dsGoldGradient
                            .frame(width: 40, height: 0.8)
                    }

                    if keptQuestions.isEmpty {
                        Text("You didn't keep any questions this time. Shuffle and try again, or explore a new theme.")
                            .font(.dsLabel(15, weight: .regular))
                            .foregroundColor(Color.dsSecondary)
                            .lineSpacing(6)
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(LinearGradient.dsGoldGradient)
                                Text("You kept \(keptQuestions.count) question")
                                    .font(.dsLabel(13, weight: .medium))
                                    .foregroundColor(Color.dsPrimary)
                            }

                            Text("Questions you saved from this session:")
                                .font(.dsLabel(13, weight: .regular))
                                .foregroundColor(Color.dsSecondary)
                        }

                        // List of kept questions
                        VStack(spacing: 12) {
                            ForEach(Array(keptQuestions.enumerated()), id: \.element.id) { index, question in
                                RecapQuestionCard(question: question, index: index + 1)
                            }
                        }
                        .padding(.top, 10)
                    }

                    VStack(spacing: 12) {
                        Button(action: { 
                            HapticManager.shared.buttonTap()
                            onRestart() 
                        }) {
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
                        
                        // Show upgrade prompt for non-premium users
                        if !appState.isPremium {
                            Button(action: { 
                                HapticManager.shared.buttonTap()
                                showPaywall = true 
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 11, weight: .light))
                                    Text("Unlock 1400+ Questions")
                                        .font(.dsDisplay(17, weight: .regular))
                                }
                                .foregroundColor(Color.dsPrimary)
                                .padding(.horizontal, 26)
                                .padding(.vertical, 15)
                                .background(Color.dsSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(LinearGradient.dsGoldGradient, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 40)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Recap Question Card

@MainActor
struct RecapQuestionCard: View {
    let question: Question
    let index: Int
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Index number
            Text("\(index)")
                .font(.dsMono(11))
                .foregroundColor(Color.dsTertiary)
                .frame(width: 24, alignment: .trailing)
                .monospacedDigit()

            VStack(alignment: .leading, spacing: 8) {
                // Question text
                Text(question.localizedText)
                    .font(.dsLabel(15, weight: .regular))
                    .foregroundColor(Color.dsPrimary)
                    .lineSpacing(4)

                // Category and depth tags
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(question.category.accentColor)
                            .frame(width: 4, height: 4)
                        Text(question.category.localizedName)
                            .font(.dsLabel(8))
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(question.category.accentColor.opacity(0.9))
                    }

                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(question.depth.color)
                            .frame(width: 10, height: 1)
                        Text(question.depth.localizedName)
                            .font(.dsLabel(8))
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(question.depth.color.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    // Share button
                    Button {
                        HapticManager.shared.buttonTap()
                        if let image = QuestionSharingHelper.generateImage(for: question) {
                            shareImage = image
                            showShareSheet = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(Color.dsTertiary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.06), Color.white.opacity(0.01)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        )
        .shareSheet(isPresented: $showShareSheet, items: shareImage != nil ? [shareImage!] : [])
    }
}

