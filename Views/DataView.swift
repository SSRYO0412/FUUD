//
//  DataView.swift
//  AWStest
//
//  DATA画面 - HTML版完全一致
//

import SwiftUI

struct DataView: View {
    @State private var selectedTab: DataTab = .lifestyle

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
    case lifestyle = "LIFESTYLE"
    case blood = "BLOOD"
    case microbiome = "MICROBIOME"

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
    // [DUMMY] 血液スコア表示は暫定値。バックエンド連携後に動的化予定
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("BLOOD BIOMARKERS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text("87") // [DUMMY] 仮スコア値
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
    // [DUMMY] 多様性スコアと菌種リストはモックデータ
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
            // Diversity Score
            VStack(spacing: VirgilSpacing.md) {
                Text("85") // [DUMMY] モックの多様性スコア
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
                BacteriaRow(name: "Faecalibacterium", percentage: "18.5%") // [DUMMY] モックの菌種データ
                BacteriaRow(name: "Bifidobacterium", percentage: "15.2%") // [DUMMY] モックの菌種データ
                BacteriaRow(name: "Akkermansia", percentage: "12.8%") // [DUMMY] モックの菌種データ
            }
        }
    }
}

private struct BacteriaRow: View {
    let name: String
    let percentage: String
    // [DUMMY] 腸内細菌の構成比は仮の固定値

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
                // [DUMMY] スコア値は仮データ、API連携後に実データ使用
                LifeScoreCard(emoji: "🧠", title: "脳の認知機能", score: 92) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "⚡️", title: "ダイエット", score: 85) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "✨", title: "見た目の健康", score: 88) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "😴", title: "睡眠", score: 90) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "💪", title: "疲労回復", score: 87) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "🌸", title: "肌", score: 86) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "🛡️", title: "抗酸化", score: 84) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "🧘", title: "ストレス", score: 82) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "🏃", title: "運動能力", score: 89) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "❤️", title: "性的な健康", score: 83) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "⚡", title: "活力", score: 91) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "❤️‍🩹", title: "心臓の健康", score: 88) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "🫘", title: "肝機能", score: 85) // [DUMMY] ライフスコアの仮値
                LifeScoreCard(emoji: "📊", title: "生活習慣", score: 87) // [DUMMY] ライフスコアの仮値
            }
        }
    }
}

private struct LifeScoreCard: View {
    let emoji: String
    let title: String
    let score: Int
    @State private var showCopyToast = false // [DUMMY] コピー通知トースト表示状態

    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                HStack {
                    Text(emoji)
                        .font(.system(size: 17.6))  // 16 * 1.1
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))  // 10 * 1.1
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                }

                Text("\(score)")
                    .font(.system(size: 26.4, weight: .black))  // 24 * 1.1
                    .foregroundColor(Color(hex: "#00C853"))

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 3.3)  // 3 * 1.1

                        Rectangle()
                            .fill(Color(hex: "#00C853"))
                            .frame(width: geometry.size.width * CGFloat(score) / 100, height: 3.3)  // 3 * 1.1
                    }
                    }
                    .frame(height: 3.3)  // 3 * 1.1
                }
                .padding(VirgilSpacing.md * 1.1)  // padding 10%拡大
                .virgilGlassCard()
                .onLongPressGesture(minimumDuration: 0.5) {
                    // [DUMMY] ライフスコアカード長押し時にプロンプト生成＆コピー
                    let prompt = PromptGenerator.generateLifeScorePrompt(
                        category: title,
                        score: score,
                        emoji: emoji
                    )
                    CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
                }

                LongPressHint(helpText: "\(title)のスコアです。タップすると詳細な分析が表示されます。")
                    .padding(8)
            }
        }
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast)
    }

    @ViewBuilder
    private var destinationView: some View {
        // タイトル完全一致で分岐（1文字でも違うと遷移失敗するため注意）
        switch title {
        case "脳の認知機能":
            CognitiveDetailView()
        case "ダイエット":
            MetabolicDetailView()
        case "見た目の健康":
            AppearanceDetailView()
        case "睡眠":
            SleepDetailView()
        case "疲労回復":
            RecoveryDetailView()
        case "肌":
            SkinDetailView()
        case "抗酸化":
            AntioxidantDetailView()
        case "ストレス":
            StressDetailView()
        case "運動能力":
            AthleticDetailView()
        case "性的な健康":
            SexualHealthDetailView()
        case "活力":
            VitalityDetailView()
        case "心臓の健康":
            CardioDetailView()
        case "肝機能":
            LiverDetailView()
        case "生活習慣":
            LifestyleHabitsDetailView()
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
