import SwiftUI

@MainActor
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()      .tag(0)
                CategoriesView().tag(1)
                FavoritesView() .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

@MainActor
struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private struct TabItem: Sendable {
        let icon: String; let label: String
    }
    private let tabs: [TabItem] = [
        TabItem(icon: "flame",           label: "Spark"),
        TabItem(icon: "square.grid.2x2", label: "Categories"),
        TabItem(icon: "bookmark",        label: "Saved"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top gradient fade
            LinearGradient(
                colors: [Color.clear, Color.dsBackground.opacity(0.96)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 20)

            ZStack {
                // Frosted background
                Color.dsSurface
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.04), Color.clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedTab = index
                            }
                        } label: {
                            VStack(spacing: 5) {
                                ZStack {
                                    if selectedTab == index {
                                        // Active glow
                                        Circle()
                                            .fill(Color.dsGold.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                            .blur(radius: 8)
                                    }
                                    Image(systemName: selectedTab == index ? "\(tab.icon).fill" : tab.icon)
                                        .font(.system(size: 20, weight: selectedTab == index ? .regular : .light))
                                        .foregroundStyle(
                                            selectedTab == index
                                            ? LinearGradient.dsGoldGradient
                                            : LinearGradient(colors: [Color.dsTertiary], startPoint: .top, endPoint: .bottom)
                                        )
                                        .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                                }

                                Text(tab.label.uppercased())
                                    .font(.dsLabel(8))
                                    .tracking(1.5)
                                    .foregroundStyle(
                                        selectedTab == index
                                        ? LinearGradient.dsGoldGradient
                                        : LinearGradient(colors: [Color.dsTertiary], startPoint: .top, endPoint: .bottom)
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                            .padding(.bottom, 28)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                        }
                    }
                }
            }
            .frame(height: 72)
            .overlay(HairlineDivider(), alignment: .top)
        }
    }
}
