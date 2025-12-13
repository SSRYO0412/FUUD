//
//  VitalityDetailView.swift
//  AWStest
//
//  活力詳細ページ
//

import SwiftUI

struct VitalityDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared

    // MARK: - Category Data
    private let categoryName = "活力"
    private let categoryId: CategoryId = .vitality

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // 活力関連遺伝子データ
    private let vitalityGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "PPARGC1A", variant: "PPARGC1A", risk: "優秀", description: "ミトコンドリア生合成・エネルギー産生"),
        (name: "NRF1", variant: "NRF1", risk: "優秀", description: "抗酸化・細胞エネルギー代謝"),
        (name: "SIRT1", variant: "SIRT1", risk: "良好", description: "長寿遺伝子・代謝調節")
    ]

    // 活力関連血液マーカーデータ
    private let vitalityBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "Ferritin", value: "98", unit: "ng/mL", range: "30-400", status: "最適"),
        (name: "TKB", value: "0.8", unit: "mg/dL", range: "0.4-1.5", status: "良好"),
        (name: "LAC", value: "11", unit: "mg/dL", range: "4-16", status: "最適"),
        (name: "ALB", value: "4.6", unit: "g/dL", range: "4.1-5.1", status: "最適"),
        (name: "TP", value: "7.2", unit: "g/dL", range: "6.6-8.1", status: "正常範囲"),
        (name: "HbA1c", value: "5.2", unit: "%", range: "<5.6", status: "最適")
    ]

    // 活力関連HealthKitデータ
    private let vitalityHealthKit: [(name: String, value: String, status: String)] = [
        (name: "HRV", value: "72ms", status: "優秀"),
        (name: "安静時心拍", value: "58bpm", status: "最適"),
        (name: "睡眠効率", value: "88%", status: "優秀"),
        (name: "日中活動量", value: "450kcal", status: "良好"),
        (name: "立ち上がり回数", value: "12回/日", status: "最適")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("⚡️")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("VITALITY")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Tuuning Intelligence
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("🧠")
                            .font(.system(size: 16))
                        Text("TUUNING INTELLIGENCE")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text("あなたの活力スコアは優秀です。適切なエネルギー管理と栄養補給が、日々の活力維持に寄与しています。引き続き現在の習慣を維持することで、長期的な活力維持が期待できます。")  // AIコメント、API連携後に実データ使用
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.virgilTextPrimary)
                        .lineSpacing(4)
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Score Graph
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("SCORE TREND")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    ScoreTrendGraph(scores: [84, 86, 88, 89, 90, 91])  // 過去6ヶ月のスコア
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Related Genes - MVP: 遺伝子情報を非表示
                /*
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("🧬")
                            .font(.system(size: 16))
                        Text("RELATED GENES")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        Spacer()

                        Button(action: shareGenes) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "PPARGC1A",
                            description: "ミトコンドリア生合成・エネルギー産生",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "NRF1",
                            description: "抗酸化・細胞エネルギー代謝",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "SIRT1",
                            description: "長寿遺伝子・代謝調節",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()
                */

                // Related Blood Markers
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("💉")
                            .font(.system(size: 16))
                        Text("RELATED BLOOD MARKERS")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        Spacer()

                        Button(action: shareBloodMarkers) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "Ferritin", value: "98 ng/mL", status: "最適")
                        BloodMarkerRow(name: "TKB", value: "0.8 mg/dL", status: "良好")
                        BloodMarkerRow(name: "LAC", value: "11 mg/dL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.6 g/dL", status: "最適")
                        BloodMarkerRow(name: "TP", value: "7.2 g/dL", status: "正常範囲")
                        BloodMarkerRow(name: "HbA1c", value: "5.2%", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "短鎖脂肪酸・エネルギー代謝促進",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Akkermansia muciniphila",
                        description: "腸粘膜保護・代謝改善",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Bifidobacterium",
                        description: "腸内環境改善・免疫調節",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "HRV", value: "72ms", status: "優秀"),
                    HealthKitSectionMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitSectionMetric(name: "睡眠効率", value: "88%", status: "優秀"),
                    HealthKitSectionMetric(name: "日中活動量", value: "450kcal", status: "良好"),
                    HealthKitSectionMetric(name: "立ち上がり回数", value: "12回/日", status: "最適")
                ])
                */

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🏃",
                            title: "朝の有酸素運動",
                            description: "20分のジョギングでミトコンドリア活性化",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "抗酸化食材摂取",
                            description: "ベリー類・緑黄色野菜で酸化ストレス軽減",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "⏰",
                            title: "生活リズム最適化",
                            description: "6時起床・22時就寝で概日リズム調整",
                            priority: "中"
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.md)
            .padding(.bottom, 100)
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("活力")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
            }
        }
        .task {
            // 初回表示時にスコア計算
            if lifestyleScoreService.categoryScores.isEmpty {
                await lifestyleScoreService.calculateAllScores()
            }
        }
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast)
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: vitalityGenes,
            relatedBloodMarkers: vitalityBloodMarkers,
            relatedHealthKit: vitalityHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: vitalityGenes,
            relatedBloodMarkers: vitalityBloodMarkers,
            relatedHealthKit: vitalityHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: vitalityGenes,
            relatedBloodMarkers: vitalityBloodMarkers,
            relatedHealthKit: vitalityHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct VitalityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VitalityDetailView()
        }
    }
}
#endif
