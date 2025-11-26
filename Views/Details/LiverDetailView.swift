//
//  LiverDetailView.swift
//  AWStest
//
//  肝機能詳細ページ
//

import SwiftUI

struct LiverDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared

    // MARK: - Category Data
    private let categoryName = "肝機能"
    private let categoryId: CategoryId = .liver

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // [DUMMY] 肝機能関連遺伝子データ
    private let liverGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "PNPLA3", variant: "PNPLA3", risk: "良好", description: "脂肪肝リスク・脂質代謝"),
        (name: "ALDH2", variant: "ALDH2", risk: "優秀", description: "アルコール代謝・アセトアルデヒド分解")
    ]

    // [DUMMY] 肝機能関連血液マーカーデータ
    private let liverBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "AST", value: "22", unit: "U/L", range: "10-40", status: "最適"),
        (name: "ALT", value: "18", unit: "U/L", range: "5-45", status: "最適"),
        (name: "GGT", value: "25", unit: "U/L", range: "0-50", status: "最適"),
        (name: "ALP", value: "195", unit: "U/L", range: "100-325", status: "正常範囲"),
        (name: "T-Bil", value: "0.9", unit: "mg/dL", range: "0.2-1.2", status: "最適"),
        (name: "D-Bil", value: "0.2", unit: "mg/dL", range: "0.0-0.4", status: "最適"),
        (name: "ALB", value: "4.5", unit: "g/dL", range: "3.8-5.3", status: "最適"),
        (name: "TG", value: "88", unit: "mg/dL", range: "30-150", status: "最適")
    ]

    // [DUMMY] 肝機能関連HealthKitデータ
    private let liverHealthKit: [(name: String, value: String, status: String)] = [
        (name: "飲酒ログ", value: "週2日", status: "良好"),
        (name: "体重推移", value: "-0.5kg/月", status: "最適"),
        (name: "睡眠タイミング", value: "22:30-6:00", status: "優秀"),
        (name: "歩数", value: "9500歩/日", status: "良好")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🫀")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("LIVER FUNCTION")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Tuuning Intelligence
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("🧠")
                            .font(.system(size: 16))
                        Text("TUUNING INTELLIGENCE")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text("あなたの肝機能スコアは良好です。適度な飲酒制限とバランスの取れた食事が、肝臓の健康維持に寄与しています。引き続き現在の習慣を維持することで、長期的な肝機能の維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.virgilTextPrimary)
                        .lineSpacing(4)
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Score Graph
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("SCORE TREND")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    ScoreTrendGraph(scores: [78, 80, 82, 84, 85, 86])  // [DUMMY] 過去6ヶ月のスコア
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

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
                            name: "PNPLA3",
                            description: "脂肪肝リスク・脂質代謝",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "ALDH2",
                            description: "アルコール代謝・アセトアルデヒド分解",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()
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
                        BloodMarkerRow(name: "AST", value: "22 U/L", status: "最適")
                        BloodMarkerRow(name: "ALT", value: "18 U/L", status: "最適")
                        BloodMarkerRow(name: "GGT", value: "25 U/L", status: "最適")
                        BloodMarkerRow(name: "ALP", value: "195 U/L", status: "正常範囲")
                        BloodMarkerRow(name: "T-Bil", value: "0.9 mg/dL", status: "最適")
                        BloodMarkerRow(name: "D-Bil", value: "0.2 mg/dL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.5 g/dL", status: "最適")
                        BloodMarkerRow(name: "TG", value: "88 mg/dL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "胆汁酸代謝菌",
                        description: "胆汁酸再吸収・肝臓保護",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "エタノール産生菌",
                        description: "内因性アルコール産生・肝負担指標",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・健康度",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "飲酒ログ", value: "週2日", status: "良好"),
                    HealthKitSectionMetric(name: "体重推移", value: "-0.5kg/月", status: "最適"),
                    HealthKitSectionMetric(name: "睡眠タイミング", value: "22:30-6:00", status: "優秀"),
                    HealthKitSectionMetric(name: "歩数", value: "9500歩/日", status: "良好")
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
                            icon: "🚫",
                            title: "週2休肝日確保",
                            description: "連続飲酒を避け、肝臓の回復時間を確保",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "抗酸化食材摂取",
                            description: "ブロッコリー・緑茶で肝保護",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "有酸素運動",
                            description: "週3回30分のウォーキングで脂肪肝予防",
                            priority: "中"
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.md)
            .padding(.bottom, 100)
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("肝機能")
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
            relatedGenes: liverGenes,
            relatedBloodMarkers: liverBloodMarkers,
            relatedHealthKit: liverHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: liverGenes,
            relatedBloodMarkers: liverBloodMarkers,
            relatedHealthKit: liverHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: liverGenes,
            relatedBloodMarkers: liverBloodMarkers,
            relatedHealthKit: liverHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct LiverDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LiverDetailView()
        }
    }
}
#endif
