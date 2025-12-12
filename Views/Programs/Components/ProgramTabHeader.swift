//
//  ProgramTabHeader.swift
//  FUUD
//
//  共通ヘッダー + タブUI
//  Phase 6-UI: ProgramContainerView用
//

import SwiftUI

// MARK: - Program Tab

enum ProgramTab: String, CaseIterable {
    case today = "TODAY"
    case progress = "PROGRESS"

    var displayName: String {
        rawValue
    }
}

// MARK: - Program Tab Header

struct ProgramTabHeader: View {
    let programName: String
    let currentDay: Int
    let totalDays: Int
    let progressPercentage: Double
    @Binding var selectedTab: ProgramTab
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                // Dark green background
                Color.lifesumDarkGreen
                    .frame(height: 200)

                // Content
                VStack(spacing: VirgilSpacing.md) {
                    // Navigation Bar
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("戻る")
                            }
                            .foregroundColor(.white)
                        }

                        Spacer()

                        // Settings placeholder
                        Button {
                            // TODO: Settings
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, 50)

                    // Program Name
                    Text(programName)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    // Progress
                    VStack(spacing: VirgilSpacing.sm) {
                        // Day Counter
                        HStack {
                            Text("Day \(currentDay) / \(totalDays)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)

                            Spacer()

                            Text(String(format: "%.1f%%", progressPercentage))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, VirgilSpacing.md)

                        // Progress Bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)

                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * CGFloat(progressPercentage / 100), height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, VirgilSpacing.md)
                    }

                    // Tab Selector
                    tabSelector
                        .padding(.top, VirgilSpacing.sm)
                }
            }
            .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProgramTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
        .padding(.horizontal, VirgilSpacing.md)
        .padding(.bottom, VirgilSpacing.md)
    }

    private func tabButton(for tab: ProgramTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            Text(tab.displayName)
                .font(.system(size: 14, weight: selectedTab == tab ? .bold : .medium))
                .foregroundColor(selectedTab == tab ? .lifesumDarkGreen : .white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedTab == tab ?
                    Color.white :
                    Color.clear
                )
                .cornerRadius(6)
        }
        .padding(2)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ProgramTabHeader(
            programName: "低糖質ダイエット28日",
            currentDay: 7,
            totalDays: 45,
            progressPercentage: 15.6,
            selectedTab: .constant(.today),
            onBack: {}
        )

        Spacer()
    }
    .background(Color(.systemBackground))
}
