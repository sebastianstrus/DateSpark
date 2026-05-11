import SwiftUI

// MARK: - Deck container

@MainActor
struct QuestionCardDeckView: View {
    let questions:    [Question]
    @Binding var currentIndex: Int
    let onKeepQuestion: (Question) -> Void

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
                Text(question.text)
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

