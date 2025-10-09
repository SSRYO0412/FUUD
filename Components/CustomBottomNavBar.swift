//
//  CustomBottomNavBar.swift
//  AWStest
//
//  Virgilデザインのカスタムボトムナビゲーションバー
//

import SwiftUI

struct CustomBottomNavBar: View {
    @Binding var selectedTab: NavigationTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationTab.allCases) { tab in
                TabButton(
                    tab: tab,
                    selectedTab: $selectedTab,
                    animation: animation
                )
            }
        }
        .padding(.horizontal, VirgilSpacing.md)
        .padding(.vertical, VirgilSpacing.sm)
        .virgilGlassBottomBar()
    }
}

// MARK: - Tab Button

private struct TabButton: View {
    let tab: NavigationTab
    @Binding var selectedTab: NavigationTab
    var animation: Namespace.ID

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: VirgilSpacing.xs) {
                // Icon
                Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                    .font(.system(size: VirgilSpacing.iconSizeMedium))
                    .foregroundColor(isSelected ? tab.accentColor : .virgilTextSecondary)
                    .frame(height: VirgilSpacing.iconSizeMedium)

                // Label
                Text(tab.title)
                    .font(.virgilLabelSmall)
                    .foregroundColor(isSelected ? tab.accentColor : .virgilTextSecondary)

                // Active Indicator
                if isSelected {
                    Capsule()
                        .fill(tab.accentColor)
                        .frame(width: 32, height: 4)
                        .matchedGeometryEffect(id: "TAB_INDICATOR", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 32, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, VirgilSpacing.xs)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
struct CustomBottomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomBottomNavBar(selectedTab: .constant(.home)) // [DUMMY] プレビュー用に固定タブを設定
        }
        .background(Color.virgilBackground)
    }
}
#endif
