import SwiftUI

@MainActor
struct FavoritesView: View {
    @Environment(AppState.self) private var appState
    @State private var showClearAlert = false

    var body: some View {
        // Read favoriteQuestionIDs directly inside body so @Observable tracks it
        let favoriteQuestions = appState.favoriteQuestions
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            GlowOrb(color: Color.dsGold.opacity(0.07), size: 320, blur: 90)
                .offset(x: -80, y: -120).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SAVED")
                            .font(.dsLabel(9))
                            .tracking(4)
                            .foregroundStyle(LinearGradient.dsGoldGradient)
                        Text("Your collection")
                            .font(.dsDisplay(30, weight: .light))
                            .foregroundColor(Color.dsPrimary)
                    }
                    Spacer()
                    if !favoriteQuestions.isEmpty {
                        Button { 
                            HapticManager.shared.buttonTap()
                            showClearAlert = true 
                        } label: {
                            Text("Clear all")
                                .font(.dsLabel(12, weight: .regular))
                                .foregroundColor(Color.dsDecline.opacity(0.85))
                        }
                        .padding(.bottom, 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)

                HairlineDivider()

                if favoriteQuestions.isEmpty {
                    FavoritesEmptyView()
                } else {
                    // Count metadata
                    HStack(spacing: 8) {
                        LinearGradient.dsGoldGradient
                            .frame(width: 20, height: 1)
                        Text("\(favoriteQuestions.count) question\(favoriteQuestions.count == 1 ? "" : "s") saved")
                            .font(.dsLabel(11, weight: .regular))
                            .foregroundColor(Color.dsSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)

                    HairlineDivider(opacity: 0.4)

                    ScrollView(showsIndicators: false) {
                        let grouped    = Dictionary(grouping: favoriteQuestions, by: \.category)
                        let sortedKeys = grouped.keys.sorted { $0.rawValue < $1.rawValue }

                        VStack(spacing: 0) {
                            ForEach(sortedKeys, id: \.self) { cat in
                                if let qs = grouped[cat] {
                                    // Section header
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 1.5)
                                            .fill(LinearGradient(
                                                colors: [cat.accentColor, cat.accentColor.opacity(0.4)],
                                                startPoint: .top, endPoint: .bottom
                                            ))
                                            .frame(width: 3, height: 18)

                                        Text(cat.localizedName)
                                            .font(.dsLabel(9))
                                            .tracking(3)
                                            .foregroundColor(cat.accentColor)
                                            .textCase(.uppercase)

                                        Spacer()

                                        Text("\(qs.count)")
                                            .font(.dsMono(10))
                                            .foregroundColor(Color.dsTertiary)
                                        }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(Color.dsSurfaceHigh)

                                    HairlineDivider(opacity: 0.4)

                                    ForEach(qs) { question in
                                        FavoriteQuestionRow(question: question)
                                        HairlineDivider(opacity: 0.35)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 110)
                    }
                }
            }
        }
        .alert("Clear your collection?", isPresented: $showClearAlert) {
            Button("Remove all", role: .destructive) {
                withAnimation { appState.clearAllFavorites() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes all \(favoriteQuestions.count) saved questions.")
        }
    }
}

// MARK: - Favorite Row

@MainActor
struct FavoriteQuestionRow: View {
    let question: Question
    @Environment(AppState.self) private var appState
    @State private var offsetX:    CGFloat = 0
    @State private var showDelete: Bool    = false
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage? = nil

    var body: some View {
        ZStack(alignment: .trailing) {
            // Swipe action background
            HStack(spacing: 0) {
                Spacer()
                
                // Share button
                Button {
                    HapticManager.shared.buttonTap()
                    if let image = QuestionSharingHelper.generateImage(for: question) {
                        shareImage = image
                        showShareSheet = true
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .light))
                        Text("SHARE")
                            .font(.dsLabel(8))
                            .tracking(1.5)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(Color.dsGold)
                }
                
                // Delete button
                Button {
                    HapticManager.shared.warning()
                    withAnimation(.spring()) { appState.toggleFavorite(question) }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .light))
                        Text("REMOVE")
                            .font(.dsLabel(8))
                            .tracking(1.5)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .frame(maxHeight: .infinity)
                    .background(Color.dsDecline)
                }
            }
            .opacity(showDelete ? 1 : 0)

            // Main row
            HStack(alignment: .top, spacing: 0) {
                // Depth bar
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(LinearGradient(
                        colors: [question.depth.color, question.depth.color.opacity(0.3)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .frame(width: 3)
                    .frame(minHeight: 44)
                    .padding(.leading, 24)

                Spacer().frame(width: 18)

                VStack(alignment: .leading, spacing: 7) {
                    Text(question.localizedText)
                        .font(.dsLabel(15, weight: .regular))
                        .foregroundColor(Color.dsPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        Text(question.category.localizedName)
                            .font(.dsLabel(8))
                            .tracking(1.5)
                            .foregroundColor(question.category.accentColor)
                            .textCase(.uppercase)
                        Text("·")
                            .foregroundColor(Color.dsTertiary)
                        Text(question.depth.localizedName)
                            .font(.dsLabel(8))
                            .tracking(1.5)
                            .foregroundColor(question.depth.color.opacity(0.75))
                            .textCase(.uppercase)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 18)
            .background(Color.dsBackground)
            .offset(x: offsetX)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { v in
                        // Only respond to predominantly horizontal drags
                        let isHorizontalDrag = abs(v.translation.width) > abs(v.translation.height)
                        guard isHorizontalDrag && v.translation.width < 0 else { return }
                        withAnimation(.interactiveSpring()) {
                            offsetX = max(v.translation.width, -160)
                            showDelete = offsetX < -30
                        }
                    }
                    .onEnded { v in
                        let isHorizontalDrag = abs(v.translation.width) > abs(v.translation.height)
                        withAnimation(.spring()) {
                            if isHorizontalDrag && v.translation.width < -60 {
                                offsetX = -160
                                showDelete = true
                            } else {
                                offsetX = 0
                                showDelete = false
                            }
                        }
                    }
            )
            .shareSheet(isPresented: $showShareSheet, items: shareImage != nil ? [shareImage!] : [])
        }
    }
}

// MARK: - Empty State

@MainActor
struct FavoritesEmptyView: View {
    @State private var lineWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 28) {
                // Large decorative bookmark
                Image(systemName: "bookmark")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundStyle(LinearGradient.dsGoldGradient)
                    .opacity(0.6)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        LinearGradient.dsGoldGradient
                            .frame(width: lineWidth, height: 1)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: lineWidth)
                        Text("EMPTY")
                            .font(.dsLabel(9))
                            .tracking(3.5)
                            .foregroundStyle(LinearGradient.dsGoldGradient)
                    }

                    Text("Nothing saved\nyet.")
                        .font(.dsDisplay(34, weight: .light))
                        .foregroundColor(Color.dsPrimary)
                        .lineSpacing(8)

                    Text("Tap the bookmark on any question card to add it to your personal collection.")
                        .font(.dsLabel(15, weight: .regular))
                        .foregroundColor(Color.dsSecondary)
                        .lineSpacing(6)
                }
            }
            .padding(.horizontal, 36)
            Spacer()
        }
        .onAppear { lineWidth = 20 }
    }
}
