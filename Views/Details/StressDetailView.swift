//
//  StressDetailView.swift
//  AWStest
//
//  ストレス詳細ページ
//

import SwiftUI

struct StressDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared
    // [DUMMY] ストレス関連データはモック

    // MARK: - Category Data
    private let categoryName = "ストレス"
    private let categoryId: CategoryId = .stress

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // [DUMMY] カテゴリー関連遺伝子データ
    private let stressGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "NR3C1", variant: "NR3C1", risk: "注意", description: "コルチゾール受容体・ストレス応答"),
        (name: "COMT Val158Met", variant: "Val158Met", risk: "良好", description: "ドーパミン代謝・ストレス耐性"),
        (name: "SLC6A4", variant: "SLC6A4", risk: "標準", description: "セロトニントランスポーター")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let stressBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "CRP", value: "0.3", unit: "mg/L", range: "0-5", status: "最適"),
        (name: "LAC", value: "12", unit: "mg/dL", range: "4-16", status: "良好"),
        (name: "1,5-AG", value: "18.5", unit: "μg/mL", range: "14-30", status: "最適"),
        (name: "GGT", value: "22", unit: "U/L", range: "0-50", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let stressHealthKit: [(name: String, value: String, status: String)] = [
        (name: "HRV", value: "68ms", status: "良好"),
        (name: "安静時心拍", value: "58bpm", status: "最適"),
        (name: "呼吸数", value: "14回/分", status: "最適"),
        (name: "マインドフルネス時間", value: "10分/日", status: "良好")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🧘")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("STRESS MANAGEMENT")
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

                    Text("あなたのストレス管理スコアは良好です。適切なリラクゼーションと運動が、ストレスの軽減に寄与しています。引き続き現在の習慣を維持することで、長期的な心身の健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [74, 76, 78, 79, 81, 82])  // [DUMMY] 過去6ヶ月のスコア
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

                        Spacer()

                        Button(action: shareGenes) { // [DUMMY] 遺伝子セクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "NR3C1",
                            description: "コルチゾール受容体・ストレス応答",
                            impact: "注意",
                            color: Color(hex: "ED1C24")
                        )

                        GeneCard(
                            name: "COMT Val158Met",
                            description: "ドーパミン代謝・ストレス耐性",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "SLC6A4",
                            description: "セロトニントランスポーター",
                            impact: "標準",
                            color: Color(hex: "FFCB05")
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

                        Spacer()

                        Button(action: shareBloodMarkers) { // [DUMMY] 血液マーカーセクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "CRP", value: "0.3 mg/L", status: "最適")
                        BloodMarkerRow(name: "LAC", value: "12 mg/dL", status: "良好")
                        BloodMarkerRow(name: "1,5-AG", value: "18.5 μg/mL", status: "最適")
                        BloodMarkerRow(name: "GGT", value: "22 U/L", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "脳‐腸軸・抗ストレス",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "GABA関連菌",
                        description: "神経伝達物質生成",
                        impact: "注意",
                        color: Color(hex: "ED1C24")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "良好"),
                    HealthKitSectionMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitSectionMetric(name: "呼吸数", value: "14回/分", status: "最適"),
                    HealthKitSectionMetric(name: "マインドフルネス時間", value: "10分/日", status: "良好")
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
                            icon: "🧘",
                            title: "瞑想・マインドフルネス",
                            description: "毎日15分の瞑想を習慣化",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "😴",
                            title: "睡眠改善",
                            description: "規則的な就寝時間を守る",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏞️",
                            title: "自然との接触",
                            description: "週2回以上の自然環境での散歩",
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
        .navigationTitle("ストレス")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // [DUMMY] NavigationBar共有ボタン追加
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
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY] コピー完了トースト表示
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: stressGenes,
            relatedBloodMarkers: stressBloodMarkers,
            relatedHealthKit: stressHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: stressGenes,
            relatedBloodMarkers: stressBloodMarkers,
            relatedHealthKit: stressHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: stressGenes,
            relatedBloodMarkers: stressBloodMarkers,
            relatedHealthKit: stressHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct StressDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StressDetailView()
        }
    }
}
#endif
