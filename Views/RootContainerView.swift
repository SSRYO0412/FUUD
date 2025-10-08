//
//  RootContainerView.swift
//  AWStest
//
//  Virgilデザインのルートコンテナ - カスタムボトムナビゲーション
//

import SwiftUI

struct RootContainerView: View {
    @State private var selectedTab: NavigationTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.virgilBackground
                .ignoresSafeArea()

            // Content
            TabContentView(selectedTab: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Bottom Navigation Bar
            CustomBottomNavBar(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Tab Content View

private struct TabContentView: View {
    let selectedTab: NavigationTab

    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView()
            case .data:
                DataView()
            case .profile:
                ProfileView()
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Preview

#if DEBUG
struct RootContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RootContainerView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
