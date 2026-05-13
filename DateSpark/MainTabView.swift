import SwiftUI

@MainActor
struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
                        TabView(selection: $selectedTab) {
                            HomeView()
                                .tag(0)
                                .environment(appState)
                            CategoriesView()
                                .tag(1)
                                .environment(appState)
                            FavoritesView()
                                .tag(2)
                                .environment(appState)
                            SettingsView()
                                .tag(3)
                                .environment(appState)
                         }

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

@MainActor
struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private struct TabItem: Sendable {
        let icon: String; let labelKey: String
    }
    private let tabs: [TabItem] = [
        TabItem(icon: "flame",           labelKey: "Spark"),
        TabItem(icon: "square.grid.2x2", labelKey: "Categories"),
        TabItem(icon: "bookmark",        labelKey: "Saved"),
        TabItem(icon: "gearshape",       labelKey: "Settings"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top fade
            LinearGradient(
                colors: [Color.clear, Color.dsBackground.opacity(0.96)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 20)
            .allowsHitTesting(false)

            ZStack {
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
                            HapticManager.shared.tabChanged()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedTab = index
                            }
                        } label: {
                            VStack(spacing: 5) {
                                ZStack {
                                    if selectedTab == index {
                                        Circle()
                                            .fill(Color.dsGold.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                            .blur(radius: 8)
                                    }
                                    Image(systemName: selectedTab == index ? "\(tab.icon).fill" : tab.icon)
                                        .font(.system(size: 20, weight: selectedTab == index ? .regular : .light))
                                        .foregroundStyle(
                                            selectedTab == index
                                            ? AnyShapeStyle(LinearGradient.dsGoldGradient)
                                            : AnyShapeStyle(Color.dsTertiary)
                                        )
                                        .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                                }

                                Text(LocalizedStringKey(tab.labelKey))
                                    .font(.dsLabel(8))
                                    .tracking(1.5)
                                    .textCase(.uppercase)
                                    .foregroundStyle(
                                        selectedTab == index
                                        ? AnyShapeStyle(LinearGradient.dsGoldGradient)
                                        : AnyShapeStyle(Color.dsTertiary)
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
