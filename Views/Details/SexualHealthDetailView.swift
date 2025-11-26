//
//  SexualHealthDetailView.swift
//  AWStest
//
//  性的な健康詳細ページ
//

import SwiftUI

struct SexualHealthDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared
    // [DUMMY] 性的健康に関するスコア・指標はモック

    // MARK: - Category Data
    private let categoryName = "性的な健康"
    private let categoryId: CategoryId = .sexual

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // [DUMMY] カテゴリー関連遺伝子データ
    private let sexualHealthGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "AR", variant: "AR", risk: "良好", description: "アンドロゲン受容体・テストステロン感受性"),
        (name: "ESR1", variant: "ESR1", risk: "優秀", description: "エストロゲン受容体・ホルモンバランス"),
        (name: "NOS3", variant: "NOS3", risk: "優秀", description: "一酸化窒素合成・血流調節")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let sexualHealthBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "ApoB", value: "85", unit: "mg/dL", range: "<100", status: "最適"),
        (name: "Lp(a)", value: "18", unit: "mg/dL", range: "<30", status: "最適"),
        (name: "TG", value: "95", unit: "mg/dL", range: "<150", status: "最適"),
        (name: "HDL", value: "62", unit: "mg/dL", range: ">40", status: "良好"),
        (name: "LDL", value: "98", unit: "mg/dL", range: "<100", status: "最適"),
        (name: "HbA1c", value: "5.3", unit: "%", range: "<5.7", status: "最適"),
        (name: "CRP", value: "0.05", unit: "mg/dL", range: "<0.3", status: "最適"),
        (name: "Ferritin", value: "92", unit: "ng/mL", range: "30-400", status: "最適"),
        (name: "Zn", value: "95", unit: "μg/dL", range: "80-130", status: "良好")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let sexualHealthHealthKit: [(name: String, value: String, status: String)] = [
        (name: "睡眠の質", value: "85%", status: "優秀"),
        (name: "深睡眠", value: "1h 45m", status: "良好"),
        (name: "HRV", value: "68ms", status: "優秀"),
        (name: "体重", value: "72.5kg", status: "最適"),
        (name: "月経周期", value: "28日", status: "正常範囲")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("❤️")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("SEXUAL HEALTH")
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

                    Text("あなたの性的健康スコアは良好です。バランスの取れたホルモンレベルと健康的な生活習慣が、性機能の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [80, 82, 84, 85, 86, 87])  // [DUMMY] 過去6ヶ月のスコア
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

                        Spacer() // [DUMMY]

                        Button(action: shareGenes) { // [DUMMY]
                            Image(systemName: "doc.on.doc") // [DUMMY]
                                .font(.system(size: 14)) // [DUMMY]
                                .foregroundColor(.virgilTextSecondary) // [DUMMY]
                        } // [DUMMY]
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "AR",
                            description: "アンドロゲン受容体・テストステロン感受性",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "ESR1",
                            description: "エストロゲン受容体・ホルモンバランス",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "NOS3",
                            description: "一酸化窒素合成・血流調節",
                            impact: "優秀",
                            color: Color(hex: "00C853")
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

                        Spacer() // [DUMMY]

                        Button(action: shareBloodMarkers) { // [DUMMY]
                            Image(systemName: "doc.on.doc") // [DUMMY]
                                .font(.system(size: 14)) // [DUMMY]
                                .foregroundColor(.virgilTextSecondary) // [DUMMY]
                        } // [DUMMY]
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "ApoB", value: "85 mg/dL", status: "最適")
                        BloodMarkerRow(name: "Lp(a)", value: "18 mg/dL", status: "最適")
                        BloodMarkerRow(name: "TG", value: "95 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "62 mg/dL", status: "良好")
                        BloodMarkerRow(name: "LDL", value: "98 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HbA1c", value: "5.3%", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.05 mg/dL", status: "最適")
                        BloodMarkerRow(name: "Ferritin", value: "92 ng/mL", status: "最適")
                        BloodMarkerRow(name: "Zn", value: "95 μg/dL", status: "良好")
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "Estrobolome",
                        description: "エストロゲン代謝・ホルモンバランス",
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
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・健康度",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "睡眠の質", value: "85%", status: "優秀"),
                    HealthKitSectionMetric(name: "深睡眠", value: "1h 45m", status: "良好"),
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "優秀"),
                    HealthKitSectionMetric(name: "体重", value: "72.5kg", status: "最適"),
                    HealthKitSectionMetric(name: "月経周期", value: "28日", status: "正常範囲")
                ])
                */

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "💪",
                            title: "レジスタンストレーニング",
                            description: "週3回の筋力トレーニングでホルモン分泌促進",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "😴",
                            title: "深睡眠の確保",
                            description: "22時就寝で成長ホルモン分泌最適化",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "亜鉛・ビタミンD摂取",
                            description: "牡蠣・ナッツ類でホルモン原料確保",
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
        .navigationTitle("性的な健康")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // [DUMMY]
            ToolbarItem(placement: .navigationBarTrailing) { // [DUMMY]
                Button(action: shareDetailView) { // [DUMMY]
                    Image(systemName: "square.and.arrow.up") // [DUMMY]
                        .font(.system(size: 16, weight: .medium)) // [DUMMY]
                        .foregroundColor(.virgilTextPrimary) // [DUMMY]
                } // [DUMMY]
            } // [DUMMY]
        } // [DUMMY]
        .task {
            // 初回表示時にスコア計算
            if lifestyleScoreService.categoryScores.isEmpty {
                await lifestyleScoreService.calculateAllScores()
            }
        }
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY]
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: sexualHealthGenes,
            relatedBloodMarkers: sexualHealthBloodMarkers,
            relatedHealthKit: sexualHealthHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: sexualHealthGenes,
            relatedBloodMarkers: sexualHealthBloodMarkers,
            relatedHealthKit: sexualHealthHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: sexualHealthGenes,
            relatedBloodMarkers: sexualHealthBloodMarkers,
            relatedHealthKit: sexualHealthHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct SexualHealthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SexualHealthDetailView()
        }
    }
}
#endif
