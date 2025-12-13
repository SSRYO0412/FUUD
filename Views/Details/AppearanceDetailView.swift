//
//  AppearanceDetailView.swift
//  AWStest
//
//  見た目の健康詳細ページ
//

import SwiftUI

struct AppearanceDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared
    // 見た目の健康データはUI検証用の固定値

    // MARK: - Category Data
    private let categoryName = "見た目の健康"
    private let categoryId: CategoryId = .appearance

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // カテゴリー関連遺伝子データ
    private let appearanceGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "MTHFR C677T", variant: "C677T", risk: "良好", description: "葉酸代謝・肌質への影響"),
        (name: "VDR FokI", variant: "FokI", risk: "最適", description: "ビタミンD受容体・肌健康"),
        (name: "SOD2 Val16Ala", variant: "Val16Ala", risk: "優秀", description: "抗酸化能力・アンチエイジング"),
        (name: "COL1A1", variant: "COL1A1", risk: "良好", description: "コラーゲン生成能力")
    ]

    // カテゴリー関連血液マーカーデータ
    private let appearanceBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "ALB", value: "4.5", unit: "g/dL", range: "3.8-5.2", status: "最適"),
        (name: "TP", value: "7.2", unit: "g/dL", range: "6.5-8.2", status: "最適"),
        (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-200", status: "良好"),
        (name: "Zn", value: "95", unit: "μg/dL", range: "80-120", status: "最適"),
        (name: "CRP", value: "0.3", unit: "mg/L", range: "<1.0", status: "最適"),
        (name: "GGT", value: "22", unit: "U/L", range: "10-50", status: "最適"),
        (name: "HbA1c", value: "5.2", unit: "%", range: "4.0-5.6", status: "最適")
    ]

    // カテゴリー関連HealthKitデータ
    private let appearanceHealthKit: [(name: String, value: String, status: String)] = [
        (name: "VO2max", value: "42 ml/kg/min", status: "良好"),
        (name: "睡眠効率", value: "89%", status: "優秀"),
        (name: "歩行速度", value: "5.2 km/h", status: "最適"),
        (name: "HRV", value: "68ms", status: "良好"),
        (name: "水分摂取", value: "2.2L", status: "最適")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("✨")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("APPEARANCE HEALTH")
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

                    Text("あなたの見た目の健康スコアは優秀です。バランスの取れた栄養摂取と適切なスキンケアが、若々しい外見の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な美容と健康の維持が期待できます。")  // AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [80, 82, 84, 85, 87, 88])  // 過去6ヶ月のスコア
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

                        Button(action: shareGenes) { // 遺伝子セクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "MTHFR C677T",
                            description: "葉酸代謝・肌質への影響",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "VDR FokI",
                            description: "ビタミンD受容体・肌健康",
                            impact: "最適",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "SOD2 Val16Ala",
                            description: "抗酸化能力・アンチエイジング",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "COL1A1",
                            description: "コラーゲン生成能力",
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

                        Button(action: shareBloodMarkers) { // 血液マーカーセクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "ALB", value: "4.5 g/dL", status: "最適")
                        BloodMarkerRow(name: "TP", value: "7.2 g/dL", status: "最適")
                        BloodMarkerRow(name: "Ferritin", value: "95 ng/mL", status: "良好")
                        BloodMarkerRow(name: "Zn", value: "95 μg/dL", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.3 mg/L", status: "最適")
                        BloodMarkerRow(name: "GGT", value: "22 U/L", status: "最適")
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
                        name: "Bifidobacterium",
                        description: "プロバイオティクス・腸‐肌軸",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Lactobacillus",
                        description: "乳酸菌・肌バリア機能",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "Akkermansia",
                        description: "腸管バリア・炎症抑制",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "VO2max", value: "42 ml/kg/min", status: "良好"),
                    HealthKitSectionMetric(name: "睡眠効率", value: "89%", status: "優秀"),
                    HealthKitSectionMetric(name: "歩行速度", value: "5.2 km/h", status: "最適"),
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "良好"),
                    HealthKitSectionMetric(name: "水分摂取", value: "2.2L", status: "最適")
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
                            icon: "💧",
                            title: "水分補給",
                            description: "1日2L以上の水分摂取を継続",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "😴",
                            title: "質の高い睡眠",
                            description: "7-8時間の睡眠と深睡眠90分以上",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "抗酸化食品",
                            description: "ビタミンC・Eを豊富に含む食品摂取",
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
        .navigationTitle("見た目の健康")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // NavigationBar共有ボタン
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
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // コピー完了トースト表示
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: appearanceGenes,
            relatedBloodMarkers: appearanceBloodMarkers,
            relatedHealthKit: appearanceHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: appearanceGenes,
            relatedBloodMarkers: appearanceBloodMarkers,
            relatedHealthKit: appearanceHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: appearanceGenes,
            relatedBloodMarkers: appearanceBloodMarkers,
            relatedHealthKit: appearanceHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct AppearanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppearanceDetailView()
        }
    }
}
#endif
