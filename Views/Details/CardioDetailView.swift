//
//  CardioDetailView.swift
//  AWStest
//
//  心臓の健康詳細ページ
//

import SwiftUI

struct CardioDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    // [DUMMY] 心血管関連の数値と指標はモック

    // MARK: - Category Data
    private let categoryName = "心臓の健康"

    // [DUMMY] カテゴリー関連遺伝子データ
    private let cardioGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "APOE", variant: "APOE", risk: "良好", description: "コレステロール代謝・動脈硬化リスク"),
        (name: "ACE I/D", variant: "ACE I/D", risk: "良好", description: "血圧調節・心筋機能"),
        (name: "NOS3", variant: "NOS3", risk: "優秀", description: "血管内皮機能・一酸化窒素産生")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let cardioBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "ApoB", value: "82", unit: "mg/dL", range: "<90", status: "最適"),
        (name: "Lp(a)", value: "15", unit: "mg/dL", range: "<30", status: "最適"),
        (name: "TG", value: "85", unit: "mg/dL", range: "<150", status: "最適"),
        (name: "HDL", value: "68", unit: "mg/dL", range: ">40", status: "優秀"),
        (name: "LDL", value: "95", unit: "mg/dL", range: "<100", status: "最適"),
        (name: "HbA1c", value: "5.2", unit: "%", range: "<5.7", status: "最適"),
        (name: "CRP", value: "0.04", unit: "mg/dL", range: "<0.1", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let cardioHealthKit: [(name: String, value: String, status: String)] = [
        (name: "安静時心拍", value: "58bpm", status: "最適"),
        (name: "HRV", value: "68ms", status: "優秀"),
        (name: "血圧", value: "118/75", status: "最適"),
        (name: "VO2max", value: "42 ml/kg/min", status: "良好"),
        (name: "有酸素運動時間", value: "150分/週", status: "最適")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("❤️")
                        .font(.system(size: 24))

                    Text("85")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("CARDIAC HEALTH")
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

                    Text("あなたの心臓の健康スコアは良好です。適度な有酸素運動とバランスの取れた食事が、心血管系の健康維持に寄与しています。引き続き現在の習慣を維持することで、長期的な心臓の健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [78, 80, 82, 83, 84, 85])  // [DUMMY] 過去6ヶ月のスコア
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

                        // [DUMMY] 遺伝子セクション共有ボタン
                        Button(action: shareGenes) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "APOE",
                            description: "コレステロール代謝・動脈硬化リスク",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "ACE I/D",
                            description: "血圧調節・心筋機能",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "NOS3",
                            description: "血管内皮機能・一酸化窒素産生",
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

                        // [DUMMY] 血液マーカーセクション共有ボタン
                        Button(action: shareBloodMarkers) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "ApoB", value: "82 mg/dL", status: "最適")
                        BloodMarkerRow(name: "Lp(a)", value: "15 mg/dL", status: "最適")
                        BloodMarkerRow(name: "TG", value: "85 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "68 mg/dL", status: "優秀")
                        BloodMarkerRow(name: "LDL", value: "95 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HbA1c", value: "5.2%", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.04 mg/dL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "Akkermansia muciniphila",
                        description: "腸粘膜保護・動脈硬化予防",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "血圧調節・炎症抑制",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・心血管保護",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "優秀"),
                    HealthKitSectionMetric(name: "血圧", value: "118/75", status: "最適"),
                    HealthKitSectionMetric(name: "VO2max", value: "42 ml/kg/min", status: "良好"),
                    HealthKitSectionMetric(name: "有酸素運動時間", value: "150分/週", status: "最適")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🏃",
                            title: "有酸素運動",
                            description: "週150分の中強度運動で心血管保護",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "抗酸化食材摂取",
                            description: "オメガ3・食物繊維で動脈硬化予防",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🫀",
                            title: "HRVモニタリング",
                            description: "毎朝のHRV測定で自律神経バランス確認",
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
        .navigationTitle("心臓の健康")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // [DUMMY] DetailView全体共有ボタン
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
            }
        }
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY] コピー通知トースト
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: cardioGenes,
            relatedBloodMarkers: cardioBloodMarkers,
            relatedHealthKit: cardioHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: cardioGenes,
            relatedBloodMarkers: cardioBloodMarkers,
            relatedHealthKit: cardioHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: cardioGenes,
            relatedBloodMarkers: cardioBloodMarkers,
            relatedHealthKit: cardioHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct CardioDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardioDetailView()
        }
    }
}
#endif
