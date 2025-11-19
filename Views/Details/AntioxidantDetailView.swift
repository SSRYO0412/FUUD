//
//  AntioxidantDetailView.swift
//  AWStest
//
//  抗酸化詳細ページ
//

import SwiftUI

struct AntioxidantDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    // [DUMMY] 抗酸化指標の数値・関連データはモック

    // MARK: - Category Data
    private let categoryName = "抗酸化"

    // [DUMMY] カテゴリー関連遺伝子データ
    private let antioxidantGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "SOD2 Val16Ala", variant: "Val16Ala", risk: "優秀", description: "スーパーオキシド分解酵素"),
        (name: "GPX1 Pro198Leu", variant: "Pro198Leu", risk: "良好", description: "グルタチオンペルオキシダーゼ"),
        (name: "CAT", variant: "-", risk: "最適", description: "カタラーゼ活性")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let antioxidantBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "GGT", value: "22", unit: "U/L", range: "0-50", status: "最適"),
        (name: "UA", value: "5.2", unit: "mg/dL", range: "3.0-7.0", status: "最適"),
        (name: "CRP", value: "0.3", unit: "mg/L", range: "<1.0", status: "最適"),
        (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "良好"),
        (name: "Zn", value: "95", unit: "μg/dL", range: "80-130", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let antioxidantHealthKit: [(name: String, value: String, status: String)] = [
        (name: "高強度運動時間", value: "週150分", status: "最適"),
        (name: "睡眠時間", value: "7.5時間", status: "良好")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🛡️")
                        .font(.system(size: 24))

                    Text("84")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("ANTIOXIDANT")
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

                    Text("あなたの抗酸化スコアは良好です。抗酸化物質が豊富な食事が、細胞の健康維持に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [76, 78, 80, 81, 83, 84])  // [DUMMY] 過去6ヶ月のスコア
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
                            name: "SOD2 Val16Ala",
                            description: "スーパーオキシド分解酵素",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "GPX1 Pro198Leu",
                            description: "グルタチオンペルオキシダーゼ",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "CAT",
                            description: "カタラーゼ活性",
                            impact: "最適",
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
                        BloodMarkerRow(name: "GGT", value: "22 U/L", status: "最適")
                        BloodMarkerRow(name: "UA", value: "5.2 mg/dL", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.3 mg/L", status: "最適")
                        BloodMarkerRow(name: "Ferritin", value: "95 ng/mL", status: "良好")
                        BloodMarkerRow(name: "Zn", value: "95 μg/dL", status: "最適")
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
                        description: "抗炎症・抗酸化作用",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "ポリフェノール代謝菌",
                        description: "抗酸化物質生成",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラバランス",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    )
                ])
                */

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "高強度運動時間", value: "週150分", status: "最適"),
                    HealthKitSectionMetric(name: "睡眠時間", value: "7.5時間", status: "良好")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🥗",
                            title: "抗酸化食品",
                            description: "ベリー類・緑茶・ダークチョコレート摂取",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "適度な運動",
                            description: "過度な高強度運動を避ける",
                            priority: "中"
                        )

                        RecommendationCard(
                            icon: "💊",
                            title: "サプリメント",
                            description: "ビタミンC・E・セレンの補給",
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
        .navigationTitle("抗酸化")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            // [DUMMY] NavigationBar共有ボタン
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
            }
        }
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY] コピー完了トースト通知
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: antioxidantGenes,
            relatedBloodMarkers: antioxidantBloodMarkers,
            relatedHealthKit: antioxidantHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: antioxidantGenes,
            relatedBloodMarkers: antioxidantBloodMarkers,
            relatedHealthKit: antioxidantHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: antioxidantGenes,
            relatedBloodMarkers: antioxidantBloodMarkers,
            relatedHealthKit: antioxidantHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct AntioxidantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AntioxidantDetailView()
        }
    }
}
#endif
