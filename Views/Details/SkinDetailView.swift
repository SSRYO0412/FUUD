//
//  SkinDetailView.swift
//  AWStest
//
//  肌詳細ページ
//

import SwiftUI

struct SkinDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    // [DUMMY] 肌関連のスコアや指標はモックデータ

    // MARK: - Category Data
    private let categoryName = "肌"

    // [DUMMY] カテゴリー関連遺伝子データ
    private let skinGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "FLG", variant: "FLG", risk: "良好", description: "肌バリア機能遺伝子"),
        (name: "MMP1", variant: "MMP1", risk: "最適", description: "コラーゲン分解酵素"),
        (name: "SOD2", variant: "SOD2", risk: "優秀", description: "抗酸化能力")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let skinBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "Zn", value: "95", unit: "μg/dL", range: "60-130", status: "最適"),
        (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "良好"),
        (name: "ALB", value: "4.5", unit: "g/dL", range: "4.0-5.0", status: "最適"),
        (name: "CRP", value: "0.3", unit: "mg/L", range: "<3.0", status: "最適"),
        (name: "GGT", value: "22", unit: "U/L", range: "0-73", status: "最適"),
        (name: "HbA1c", value: "5.2", unit: "%", range: "<5.6", status: "最適"),
        (name: "TP", value: "7.2", unit: "g/dL", range: "6.6-8.1", status: "良好"),
        (name: "pAlb", value: "28", unit: "mg/dL", range: "25-30", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let skinHealthKit: [(name: String, value: String, status: String)] = [
        (name: "深睡眠", value: "90分", status: "優秀"),
        (name: "HRV", value: "68ms", status: "良好"),
        (name: "安静時心拍", value: "58bpm", status: "最適"),
        (name: "水分摂取", value: "2.2L", status: "最適")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🌸")
                        .font(.system(size: 24))

                    Text("86")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("SKIN HEALTH")
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

                    Text("あなたの肌の健康スコアは良好です。適切なスキンケアと栄養摂取が、健康的な肌の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な美肌維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                // Related Genes
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
                            name: "FLG",
                            description: "肌バリア機能遺伝子",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "MMP1",
                            description: "コラーゲン分解酵素",
                            impact: "最適",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "SOD2",
                            description: "抗酸化能力",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

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
                        BloodMarkerRow(name: "Zn", value: "95 μg/dL", status: "最適")
                        BloodMarkerRow(name: "Ferritin", value: "95 ng/mL", status: "良好")
                        BloodMarkerRow(name: "ALB", value: "4.5 g/dL", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.3 mg/L", status: "最適")
                        BloodMarkerRow(name: "GGT", value: "22 U/L", status: "最適")
                        BloodMarkerRow(name: "HbA1c", value: "5.2%", status: "最適")
                        BloodMarkerRow(name: "TP", value: "7.2 g/dL", status: "良好")
                        BloodMarkerRow(name: "pAlb", value: "28 mg/dL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "Bifidobacterium",
                        description: "腸‐肌軸・免疫調整",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Lactobacillus",
                        description: "肌バリア機能強化",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "Akkermansia",
                        description: "炎症抑制・腸管バリア",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "深睡眠", value: "90分", status: "優秀"),
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "良好"),
                    HealthKitSectionMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitSectionMetric(name: "水分摂取", value: "2.2L", status: "最適")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "💧",
                            title: "保湿ケア",
                            description: "朝晩の保湿ケアを徹底",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "☀️",
                            title: "紫外線対策",
                            description: "SPF30以上の日焼け止めを毎日使用",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "ビタミン摂取",
                            description: "ビタミンC・E・亜鉛を含む食品",
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
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                OrbBackground()
                GridOverlay()
            }
        )
        .navigationTitle("肌")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // [DUMMY] NavigationBar共有ボタン
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
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
            relatedGenes: skinGenes,
            relatedBloodMarkers: skinBloodMarkers,
            relatedHealthKit: skinHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: skinGenes,
            relatedBloodMarkers: skinBloodMarkers,
            relatedHealthKit: skinHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: skinGenes,
            relatedBloodMarkers: skinBloodMarkers,
            relatedHealthKit: skinHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct SkinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SkinDetailView()
        }
    }
}
#endif
