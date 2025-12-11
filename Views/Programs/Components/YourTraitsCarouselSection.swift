//
//  YourTraitsCarouselSection.swift
//  FUUD
//
//  Your Traits + おすすめプログラムのカルーセル表示
//  Phase 6: UI統合
//

import SwiftUI

// MARK: - Your Traits Carousel Section

struct YourTraitsCarouselSection: View {
    @ObservedObject var traitsViewModel: YourTraitsViewModel
    @ObservedObject var recommender: ProgramRecommender
    @State private var currentPage = 0
    var onProgramTap: (DietProgram) -> Void

    private var totalPages: Int {
        let recommendationCount = recommender.recommendations?.topRecommendations.count ?? 0
        return 1 + recommendationCount // YourTraits + おすすめ数
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // セクションタイトル + ページインジケーター
            HStack {
                Text(sectionTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()

                if totalPages > 1 {
                    PageIndicatorView(currentPage: currentPage, totalPages: totalPages)
                }
            }
            .padding(.horizontal, VirgilSpacing.md)

            // カルーセル本体
            TabView(selection: $currentPage) {
                // Page 0: YourTraits
                UnifiedTraitsCard(
                    geneTraits: traitsViewModel.traitsData.geneTraits,
                    bloodSummary: traitsViewModel.traitsData.bloodSummary,
                    weightGoal: traitsViewModel.traitsData.weightGoal,
                    hasGeneData: traitsViewModel.traitsData.hasGeneData,
                    hasBloodData: traitsViewModel.traitsData.hasBloodData,
                    hasWeightData: traitsViewModel.traitsData.hasWeightData
                )
                .padding(.horizontal, VirgilSpacing.md)
                .tag(0)

                // Page 1-3: おすすめプログラム
                if let recommendations = recommender.recommendations?.topRecommendations {
                    ForEach(Array(recommendations.enumerated()), id: \.element.id) { index, recommendation in
                        RecommendedProgramCard(
                            recommendation: recommendation,
                            rank: index + 1,
                            onTap: { onProgramTap(recommendation.program) }
                        )
                        .padding(.horizontal, VirgilSpacing.md)
                        .tag(index + 1)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 260) // カードの高さに合わせる
        }
    }

    private var sectionTitle: String {
        if currentPage == 0 {
            return "YOUR TRAITS"
        } else {
            return "RECOMMENDED FOR YOU"
        }
    }
}

// MARK: - Page Indicator

struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.lifesumDarkGreen : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Recommended Program Card

struct RecommendedProgramCard: View {
    let recommendation: ProgramRecommendation
    let rank: Int
    let onTap: () -> Void

    private var program: DietProgram {
        recommendation.program
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // 画像セクション
                ZStack(alignment: .topLeading) {
                    // プログラム画像
                    Image(program.imageAssetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                        .background(
                            LinearGradient(
                                colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // ランクバッジ
                    RankBadge(rank: rank)
                        .padding(8)
                }

                // コンテンツセクション
                VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                    // カテゴリ + 難易度
                    HStack(spacing: 6) {
                        Text(program.category.displayNameJa)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(categoryColor)

                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Text(program.difficulty.displayNameJa)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // プログラム名
                    Text(program.nameJa)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    // おすすめ理由
                    if !recommendation.reasons.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("おすすめの理由")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)

                            HStack(spacing: 6) {
                                ForEach(Array(recommendation.reasons.prefix(2).enumerated()), id: \.offset) { _, reason in
                                    ReasonChip(reason: reason)
                                }
                            }
                        }
                    }
                }
                .padding(VirgilSpacing.md)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .liquidGlassCard()
        }
        .buttonStyle(.plain)
    }

    private var categoryColor: Color {
        switch program.category {
        case .biohacking: return .purple
        case .balanced: return .lifesumDarkGreen
        case .fasting: return .orange
        case .highProtein: return .blue
        case .lowCarb: return .teal
        }
    }
}

// MARK: - Rank Badge

struct RankBadge: View {
    let rank: Int

    var body: some View {
        HStack(spacing: 2) {
            Text("#")
                .font(.system(size: 10, weight: .bold))
            Text("\(rank)")
                .font(.system(size: 14, weight: .black))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color.lifesumDarkGreen, Color.lifesumLightGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(6)
    }
}

// MARK: - Reason Chip

struct ReasonChip: View {
    let reason: ProgramRecommendationReason

    var body: some View {
        HStack(spacing: 3) {
            Text(reasonIcon)
                .font(.system(size: 10))
            Text(shortReasonText)
                .font(.system(size: 9, weight: .medium))
                .lineLimit(1)
        }
        .foregroundColor(reasonColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(reasonColor.opacity(0.1))
        .cornerRadius(4)
    }

    private var reasonIcon: String {
        switch reason.category {
        case .blood: return "🩸"
        case .gene: return "🧬"
        case .lifestyle: return "🏃"
        case .goal: return "🎯"
        }
    }

    private var reasonColor: Color {
        switch reason.category {
        case .blood: return .virgilWarning
        case .gene: return .purple
        case .lifestyle: return .blue
        case .goal: return .lifesumDarkGreen
        }
    }

    private var shortReasonText: String {
        switch reason {
        case .highHbA1c: return "血糖ケア"
        case .highTG: return "中性脂肪"
        case .highLDL: return "コレステロール"
        case .elevatedCRP: return "炎症ケア"
        case .lowFerritin: return "鉄分確保"
        case .poorCarbMetabolismGene: return "低糖質向き"
        case .goodCarbMetabolismGene: return "糖質OK"
        case .poorFatMetabolismGene: return "低脂質向き"
        case .goodFatOxidationGene: return "脂肪燃焼◎"
        case .goodProteinResponseGene: return "高タンパク◎"
        case .runnerLifestyle: return "持久力重視"
        case .strengthLifestyle: return "筋肉維持"
        case .fastingPreferred: return "断食OK"
        case .fastingNotPreferred: return "断食なし"
        case .lowStressApproachPreferred: return "無理なく"
        case .goalMatch: return "目標一致"
        case .paceMatch: return "ペース一致"
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // プレビュー用のダミーカード
            RecommendedProgramCard(
                recommendation: ProgramRecommendation(
                    program: DietProgramCatalog.programs.first!,
                    score: 85,
                    reasons: [.goalMatch, .highHbA1c, .goodProteinResponseGene]
                ),
                rank: 1,
                onTap: {}
            )
            .padding(.horizontal, 16)

            RecommendedProgramCard(
                recommendation: ProgramRecommendation(
                    program: DietProgramCatalog.programs[1],
                    score: 72,
                    reasons: [.paceMatch, .goodCarbMetabolismGene]
                ),
                rank: 2,
                onTap: {}
            )
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }
    .background(Color(.systemBackground))
}
