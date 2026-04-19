import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: AppTab = .startWorkout
    let store: MockWorkoutStore

    var body: some View {
        TabView(selection: $selectedTab) {
            tabNavigation(for: .history) {
                HistoryScreen(store: store)
            }

            tabNavigation(for: .startWorkout) {
                StartWorkoutScreen(store: store)
            }

            tabNavigation(for: .profile) {
                ProfileScreen()
            }
        }
        .tint(AppTheme.accent)
    }

    private func tabNavigation<Content: View>(
        for tab: AppTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            content()
        }
        .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
        }
        .tag(tab)
    }
}

#Preview {
    RootTabView(store: .sample)
}
