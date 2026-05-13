import SwiftUI

// MARK: - Deck container

@MainActor
struct QuestionCardDeckView: View {
    let questions:    [Question]
    @Binding var currentIndex: Int
    let onKeepQuestion: (Question) -> Void

    @Environment(AppState.self) private var appState
    @State private var showTutorial = false

    private var visibleIndices: [Int] {
        Array((currentIndex..<min(currentIndex + 3, questions.count)).reversed())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress row
            HStack(spacing: 14) {
                SessionProgressBar(current: currentIndex, total: questions.count)
                Text("\(currentIndex)/\(questions.count)")
                    .font(.dsMono(11))
                    .foregroundColor(Color.dsTertiary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // Swipe hints
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 10, weight: .light))
                    Text("PASS")
                        .font(.dsLabel(9))
                        .tracking(2)
                }
                .foregroundColor(Color.dsTertiary)
                Spacer()
                HStack(spacing: 5) {
                    Text("KEEP")
                        .font(.dsLabel(9))
                        .tracking(2)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .light))
                }
                .foregroundColor(Color.dsTertiary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 10)

            // Card stack — fills remaining space, margin applied here
            ZStack {
                ForEach(visibleIndices, id: \.self) { index in
                    QuestionCardView(
                        question:      questions[index],
                        stackPosition: index - currentIndex,
                        isTop:         index == currentIndex,
                        onSwipeRight:  {
                            onKeepQuestion(questions[index])
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) { currentIndex += 1 }
                        },
                        onSwipeLeft:   {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) { currentIndex += 1 }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            Group {
                if showTutorial {
                    SwipeTutorialOverlay(isPresented: $showTutorial)
                        .transition(.opacity)
                        .onDisappear {
                            appState.hasSeenSwipeTutorial = true
                        }
                }
            }
        )
        .onAppear {
            if !appState.hasSeenSwipeTutorial {
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    withAnimation(.easeOut(duration: 0.3)) {
                        showTutorial = true
                    }
                }
            }
        }
    }
}

// MARK: - SwipeStatus

enum SwipeStatus: Sendable {
    case none, right, left
    var color: Color {
        switch self {
        case .none:  .clear
        case .right: Color.dsConfirm
        case .left:  Color.dsDecline
        }
    }
    var label: String {
        switch self { case .none: ""; case .right: "KEEP"; case .left: "PASS" }
    }
}

// MARK: - Single Card

@MainActor
struct QuestionCardView: View {
    let question:      Question
    let stackPosition: Int
    let isTop:         Bool
    let onSwipeRight:  () -> Void
    let onSwipeLeft:   () -> Void

    @Environment(AppState.self) private var appState
    @State private var dragOffset:        CGSize      = .zero
    @State private var swipeStatus:       SwipeStatus = .none
    @State private var favoriteAnimating: Bool        = false
    @State private var showShareSheet:    Bool        = false
    @State private var shareImage:        UIImage?    = nil

    private var cardScale: CGFloat  { 1.0 - CGFloat(stackPosition) * 0.04 }
    private var cardYOffset: CGFloat { CGFloat(stackPosition) * -12 }

    var body: some View {
        // Access favoriteQuestionIDs directly inside body so @Observable tracks it
        let isFav = appState.isFavorite(question)
        ZStack(alignment: .topLeading) {
            // Card surface
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.09), Color.white.opacity(0.02)],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 12)
                .shadow(color: question.category.accentColor.opacity(isTop ? 0.08 : 0), radius: 40)

            // Category colour wash
            LinearGradient(
                colors: [question.category.accentColor.opacity(0.06), Color.clear],
                startPoint: .topLeading, endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(
                    colors: [question.category.accentColor, question.category.accentColor.opacity(0.3)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 3)
                .padding(.vertical, 28)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Content — VStack with fixed padding, no Spacers pushing content off-screen
            VStack(alignment: .leading, spacing: 0) {

                // ── Top meta ──────────────────────────────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(question.category.accentColor)
                                .frame(width: 5, height: 5)
                            Text(question.category.localizedName)
                                .font(.dsLabel(9))
                                .tracking(2.5)
                                .foregroundColor(question.category.accentColor)
                                .textCase(.uppercase)
                        }
                        HStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(question.depth.color)
                                .frame(width: 14, height: 1.5)
                            Text(question.depth.localizedName)
                                .font(.dsLabel(8))
                                .tracking(2)
                                .foregroundColor(question.depth.color.opacity(0.85))
                                .textCase(.uppercase)
                        }
                    }
                    Spacer()
                    Text(String(format: "%02d", stackPosition == 0 ? 1 : stackPosition + 1))
                        .font(.system(size: 28, weight: .ultraLight, design: .serif))
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                        .opacity(0.35)
                }
                .padding(.top, 22)
                .padding(.horizontal, 22)

                // ── Divider ───────────────────────────────────────────────
                LinearGradient.dsGoldGradient
                    .frame(height: 0.5)
                    .opacity(0.2)
                    .padding(.horizontal, 22)
                    .padding(.top, 14)

                // ── Question text ─────────────────────────────────────────
                // Fills remaining space; font scales down if text is very long
                Text(question.localizedText)
                    .font(.dsDisplay(24, weight: .light))
                    .foregroundColor(Color.dsPrimary)
                    .lineSpacing(7)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.75)   // shrinks font rather than clipping
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                // ── Bottom bar ────────────────────────────────────────────
                HStack(spacing: 0) {
                    // Share button
                    Button {
                        if let image = QuestionSharingHelper.generateImage(for: question) {
                            shareImage = image
                            showShareSheet = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .light))
                            .foregroundColor(Color.dsTertiary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer().frame(width: 4)
                    
                    LinearGradient.dsGoldGradient
                        .frame(height: 0.5)
                        .opacity(0.2)

                    Spacer().frame(width: 8)

                    // Bookmark button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                            favoriteAnimating = true
                            appState.toggleFavorite(question)
                        }
                        Task {
                            try? await Task.sleep(for: .milliseconds(300))
                            favoriteAnimating = false
                        }
                    } label: {
                        ZStack {
                            if isFav {
                                Circle()
                                    .fill(Color.dsGold.opacity(0.12))
                                    .frame(width: 38, height: 38)
                            }
                            Image(systemName: isFav ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(
                                    isFav
                                    ? AnyShapeStyle(LinearGradient.dsGoldGradient)
                                    : AnyShapeStyle(Color.dsTertiary)
                                )
                                .scaleEffect(favoriteAnimating ? 1.25 : 1.0)
                        }
                        .frame(width: 44, height: 44)
                    }
                }
                .padding(.leading, 6)
                .padding(.trailing, 6)
                .padding(.bottom, 14)
            }

            // Swipe overlay
            if swipeStatus != .none {
                RoundedRectangle(cornerRadius: 12)
                    .fill(swipeStatus.color.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(swipeStatus.color.opacity(0.75), lineWidth: 1.5)
                    )
                VStack {
                    HStack {
                        if swipeStatus == .left {
                            SwipeLabel(status: swipeStatus).padding(20); Spacer()
                        } else {
                            Spacer(); SwipeLabel(status: swipeStatus).padding(20)
                        }
                    }
                    Spacer()
                }
            }
        }
        .scaleEffect(isTop ? 1.0 : cardScale)
        .offset(y: isTop ? 0 : cardYOffset)
        .offset(x: isTop ? dragOffset.width : 0)
        .rotationEffect(isTop ? .degrees(dragOffset.width / 22) : .zero)
        .gesture(isTop ? dragGesture : nil)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: stackPosition)
        .shareSheet(isPresented: $showShareSheet, items: shareImage != nil ? [shareImage!] : [])
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                dragOffset  = v.translation
                swipeStatus = v.translation.width > 50 ? .right : v.translation.width < -50 ? .left : .none
            }
            .onEnded { v in
                if      v.translation.width >  100 { animateOut(direction:  1) }
                else if v.translation.width < -100 { animateOut(direction: -1) }
                else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset = .zero; swipeStatus = .none
                    }
                }
            }
    }

    private func animateOut(direction: CGFloat) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
            dragOffset = CGSize(width: direction * 680, height: 0)
        }
        Task {
            try? await Task.sleep(for: .milliseconds(280))
            direction > 0 ? onSwipeRight() : onSwipeLeft()
            dragOffset = .zero; swipeStatus = .none
        }
    }
}

// MARK: - Swipe Label

struct SwipeLabel: View {
    let status: SwipeStatus
    var body: some View {
        Text(status.label)
            .font(.dsLabel(11))
            .tracking(3.5)
            .foregroundColor(status.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(status.color.opacity(0.8), lineWidth: 1)
            )
            .rotationEffect(.degrees(status == .right ? -8 : 8))
    }
}

// MARK: - Progress Bar

struct SessionProgressBar: View {
    let current: Int
    let total:   Int
    private var progress: CGFloat { total > 0 ? CGFloat(current) / CGFloat(total) : 0 }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.dsBorder).frame(height: 2)
                LinearGradient.dsGoldGradient
                    .clipShape(Capsule())
                    .frame(width: geo.size.width * progress, height: 2)
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 2)
    }
}

// MARK: - Swipe Tutorial Overlay

@MainActor
struct SwipeTutorialOverlay: View {
    @Binding var isPresented: Bool
    @State private var leftHandOpacity: Double = 0
    @State private var leftHandOffset: CGFloat = 0
    @State private var rightHandOpacity: Double = 0
    @State private var rightHandOffset: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var showLeftAnimation = true
    
    var body: some View {
        ZStack {
            // Semi-transparent background - less opaque to show the real card behind
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissTutorial()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Title and description at the top
                VStack(spacing: 16) {
                    Text("How to Play")
                        .font(.dsDisplay(28, weight: .light))
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                    
                    Text("Swipe left to pass, swipe right to keep\nThere will be recap at the end")
                        .font(.dsLabel(15, weight: .regular))
                        .foregroundColor(Color.dsSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .opacity(textOpacity)
                .padding(.bottom, 50)
                
                // Hand animations positioned over the real card
                ZStack {
                    // Left hand animation (Pass)
                    HStack {
                        VStack(spacing: 8) {
                            Image(systemName: "hand.point.left.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.dsDecline, Color.dsDecline.opacity(0.6)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .rotationEffect(.degrees(45))
                                .shadow(color: Color.dsDecline.opacity(0.6), radius: 16)
                                .padding(.trailing, 8)
                                
                            
                            Text("PASS")
                                .font(.dsLabel(16))
                                .tracking(3.5)
                                .foregroundColor(Color.dsDecline)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                        }
                        .opacity(leftHandOpacity)
                        .offset(x: leftHandOffset)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    
                    // Right hand animation (Keep)
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Image(systemName: "hand.point.right.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.dsConfirm, Color.dsConfirm.opacity(0.6)],
                                    startPoint: .topTrailing, endPoint: .bottomLeading
                                ))
                                .rotationEffect(.degrees(-45))
                                .shadow(color: Color.dsConfirm.opacity(0.6), radius: 16)
                                .padding(.leading, 8)
//
                            
                            Text("KEEP")
                                .font(.dsLabel(16))
                                .tracking(3.5)
                                .foregroundColor(Color.dsConfirm)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                        }
                        .opacity(rightHandOpacity)
                        .offset(x: rightHandOffset)
                    }
                    .padding(.horizontal, 40)
                }
                .frame(height: 200)
                
                Spacer()
                
                // Dismiss button at the bottom
                Button {
                    dismissTutorial()
                } label: {
                    Text("Got it")
                        .font(.dsDisplay(17, weight: .regular))
                        .foregroundColor(Color.dsBackground)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                LinearGradient.dsGoldGradient
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(color: Color.dsGold.opacity(0.35), radius: 16, x: 0, y: 6)
                }
                .opacity(textOpacity)
                .padding(.bottom, 80)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Fade in text
        withAnimation(.easeOut(duration: 0.5)) {
            textOpacity = 1.0
        }
        
        // Start continuous alternating hand animations
        animateHands()
    }
    
    private func animateHands() {
        if showLeftAnimation {
            // Animate left hand (Pass)
            withAnimation(.easeOut(duration: 0.4)) {
                leftHandOpacity = 1.0
                leftHandOffset = 0
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
                leftHandOffset = -80
            }
            
            withAnimation(.easeOut(duration: 0.3).delay(1.0)) {
                leftHandOpacity = 0
            }
            
            Task {
                try? await Task.sleep(for: .milliseconds(1500))
                showLeftAnimation = false
                animateHands()
            }
        } else {
            // Animate right hand (Keep)
            withAnimation(.easeOut(duration: 0.4)) {
                rightHandOpacity = 1.0
                rightHandOffset = 0
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
                rightHandOffset = 80
            }
            
            withAnimation(.easeOut(duration: 0.3).delay(1.0)) {
                rightHandOpacity = 0
            }
            
            Task {
                try? await Task.sleep(for: .milliseconds(1500))
                leftHandOffset = 0
                rightHandOffset = 0
                showLeftAnimation = true
                animateHands()
            }
        }
    }
    
    private func dismissTutorial() {
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
    }
}

