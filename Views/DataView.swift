//
//  DataView.swift
//  AWStest
//
//  DATA画面 - HTML版完全一致
//

import SwiftUI

struct DataView: View {
    @State private var selectedTab: DataTab = .blood

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Background Orbs
                OrbBackground()

                ScrollView {
                    VStack(spacing: VirgilSpacing.md) {
                        // Tab Navigation
                        HStack(spacing: VirgilSpacing.sm) {
                        ForEach(DataTab.allCases) { tab in
                            TabButton(
                                tab: tab,
                                isSelected: selectedTab == tab,
                                action: { selectedTab = tab }
                            )
                        }
                    }
                    .padding(VirgilSpacing.xs)
                    .background(
                        Color.white.opacity(0.08)
                    )
                    .cornerRadius(VirgilSpacing.radiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: VirgilSpacing.radiusLarge)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                    // Tab Content
                    Group {
                        switch selectedTab {
                        case .blood:
                            BloodTab()
                        case .microbiome:
                            MicrobiomeTab()
                        case .lifestyle:
                            LifestyleTab()
                        }
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.sm)
                }
            }
            .navigationTitle("data")
            .floatingChatButton()
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Data Tab Enum

enum DataTab: String, CaseIterable, Identifiable {
    case blood = "BLOOD"
    case microbiome = "MICROBIOME"
    case lifestyle = "LIFESTYLE"

    var id: String { rawValue }
}

// MARK: - Tab Button

private struct TabButton: View {
    let tab: DataTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tab.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isSelected ? Color.white : Color.gray)
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.sm)
                .background(isSelected ? Color.black : Color.clear)
                .cornerRadius(VirgilSpacing.radiusMedium)
        }
    }
}

// MARK: - Blood Tab

private struct BloodTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("BLOOD BIOMARKERS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text("87")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#00C853"))
            }
            .padding(.bottom, VirgilSpacing.sm)

            BloodTestView()
        }
    }
}

// MARK: - Microbiome Tab

private struct MicrobiomeTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
            // Diversity Score
            VStack(spacing: VirgilSpacing.md) {
                Text("85")
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#00C853"), Color(hex: "#0088CC")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("DIVERSITY SCORE")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(VirgilSpacing.xl)
            .virgilGlassCard()

            // Bacteria List
            VStack(spacing: VirgilSpacing.sm) {
                BacteriaRow(name: "Faecalibacterium", percentage: "18.5%")
                BacteriaRow(name: "Bifidobacterium", percentage: "15.2%")
                BacteriaRow(name: "Akkermansia", percentage: "12.8%")
            }
        }
    }
}

private struct BacteriaRow: View {
    let name: String
    let percentage: String

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 10, weight: .medium))
                .italic()
            Spacer()
            Text(percentage)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(VirgilSpacing.radiusMedium)
    }
}

// MARK: - Lifestyle Tab

private struct LifestyleTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("LIFESTYLE SCORES")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: VirgilSpacing.sm) {
                LifeScoreCard(emoji: "🧠", title: "認知機能", score: 92)
                LifeScoreCard(emoji: "💪", title: "筋力", score: 88)
                LifeScoreCard(emoji: "❤️", title: "心肺機能", score: 85)
                LifeScoreCard(emoji: "😴", title: "睡眠", score: 90)
            }
        }
    }
}

private struct LifeScoreCard: View {
    let emoji: String
    let title: String
    let score: Int

    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                HStack {
                    Text(emoji)
                        .font(.system(size: 16))
                    Text(title)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                }

                Text("\(score)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color(hex: "#00C853"))

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 3)

                        Rectangle()
                            .fill(Color(hex: "#00C853"))
                            .frame(width: geometry.size.width * CGFloat(score) / 100, height: 3)
                    }
                    }
                    .frame(height: 3)
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                LongPressHint(helpText: "\(title)のスコアです。タップすると詳細な分析が表示されます。")
                    .padding(8)
            }
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch title {
        case "認知機能":
            CognitiveDetailView()
        case "筋力":
            StrengthDetailView()
        case "心肺機能":
            CardioDetailView()
        case "睡眠":
            SleepDetailView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
#endif
