import SwiftUI

@MainActor
struct CategoriesView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedCategory: QuestionCategory? = nil

    var body: some View {
        ZStack {
            Color.dsBackground.ignoresSafeArea()
            GlowOrb(color: Color.dsGold.opacity(0.06), size: 360, blur: 100)
                .offset(x: 100, y: -100).ignoresSafeArea()

            if let category = selectedCategory {
                CategoryDetailView(category: category) { selectedCategory = nil }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
            } else {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CATEGORIES")
                            .font(.dsLabel(9))
                            .tracking(4)
                            .foregroundStyle(LinearGradient.dsGoldGradient)
                        Text("Eight themes")
                            .font(.dsDisplay(30, weight: .light))
                            .foregroundColor(Color.dsPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                    HairlineDivider()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(QuestionCategory.allCases.enumerated()), id: \.element.id) { index, cat in
                                CategoryRowView(category: cat, index: index + 1) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedCategory = cat
                                    }
                                }
                                if index < QuestionCategory.allCases.count - 1 {
                                    HairlineDivider(opacity: 0.5)
                                }
                            }
                        }
                        .padding(.bottom, 110)
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: selectedCategory)
    }
}

// MARK: - Category Row

@MainActor
struct CategoryRowView: View {
    let category: QuestionCategory
    let index:    Int
    let onTap:    () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Index
                Text(String(format: "%02d", index))
                    .font(.dsMono(11))
                    .foregroundColor(Color.dsTertiary)
                    .frame(width: 52)

                // Accent strip
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        LinearGradient(
                            colors: [category.accentColor, category.accentColor.opacity(0.4)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 44)

                Spacer().frame(width: 18)

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.rawValue)
                        .font(.dsDisplay(19, weight: .light))
                        .foregroundColor(Color.dsPrimary)
                    Text("\(DataProvider.shared.questions(for: category).count) questions")
                        .font(.dsLabel(11, weight: .regular))
                        .foregroundColor(Color.dsTertiary)
                }

                Spacer()

                // Arrow
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color.dsTertiary)
                    .padding(.trailing, 24)
            }
            .padding(.vertical, 20)
            .background(pressed ? Color.dsSurfaceHigh : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true  }
                .onEnded   { _ in pressed = false }
        )
    }
}

// MARK: - Category Detail

@MainActor
struct CategoryDetailView: View {
    let category: QuestionCategory
    let onBack:   () -> Void
    @Environment(AppState.self) private var appState

    private var questions: [Question] { DataProvider.shared.questions(for: category) }

    var body: some View {
        VStack(spacing: 0) {
            // Header with accent glow
            ZStack(alignment: .bottom) {
                // Subtle glow
                GlowOrb(color: category.accentColor.opacity(0.15), size: 300, blur: 80)
                    .offset(x: 60, y: -40)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 7) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 13, weight: .light))
                                Text("Back")
                                    .font(.dsLabel(14, weight: .regular))
                            }
                            .foregroundColor(Color.dsSecondary)
                        }
                        Spacer()
                        Circle()
                            .fill(category.accentColor)
                            .frame(width: 8, height: 8)
                            .padding(.trailing, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 16)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(category.rawValue.uppercased())
                            .font(.dsLabel(9))
                            .tracking(3.5)
                            .foregroundColor(category.accentColor)
                        Text(category.description)
                            .font(.dsDisplay(26, weight: .light))
                            .foregroundColor(Color.dsPrimary)
                            .lineSpacing(5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }

            HairlineDivider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        QuestionListRow(question: question, index: index + 1)
                        HairlineDivider(opacity: 0.4)
                    }
                }
                .padding(.bottom, 110)
            }
        }
        .background(Color.dsBackground)
    }
}

// MARK: - Question List Row

@MainActor
struct QuestionListRow: View {
    let question: Question
    let index:    Int
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(String(format: "%02d", index))
                .font(.dsMono(10))
                .foregroundColor(Color.dsTertiary)
                .padding(.top, 3)
                .frame(width: 52)

            VStack(alignment: .leading, spacing: 8) {
                Text(question.text)
                    .font(.dsLabel(16, weight: .regular))
                    .foregroundColor(Color.dsPrimary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(question.depth.color)
                        .frame(width: 16, height: 1.5)
                    Text(question.depth.rawValue.uppercased())
                        .font(.dsLabel(8))
                        .tracking(2)
                        .foregroundColor(question.depth.color.opacity(0.8))
                }
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    appState.toggleFavorite(question)
                }
            } label: {
                Image(systemName: appState.isFavorite(question) ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(
                        appState.isFavorite(question)
                        ? LinearGradient.dsGoldGradient
                        : LinearGradient(colors: [Color.dsTertiary], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 44, height: 44)
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}
