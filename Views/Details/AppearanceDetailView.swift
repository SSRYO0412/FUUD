//
//  AppearanceDetailView.swift
//  AWStest
//
//  見た目の健康詳細ページ
//

import SwiftUI

struct AppearanceDetailView: View {
    @Environment(\.dismiss) var dismiss
    // [DUMMY] 見た目の健康データはUI検証用の固定値

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("✨")
                        .font(.system(size: 24))

                    Text("88")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("APPEARANCE HEALTH")
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

                    Text("あなたの見た目の健康スコアは優秀です。バランスの取れた栄養摂取と適切なスキンケアが、若々しい外見の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な美容と健康の維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [80, 82, 84, 85, 87, 88])  // [DUMMY] 過去6ヶ月のスコア
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
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
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
                .virgilGlassCard()

                // Related Blood Markers
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("💉")
                            .font(.system(size: 16))
                        Text("RELATED BLOOD MARKERS")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
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
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
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

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "VO2max", value: "42 ml/kg/min", status: "良好"),
                    HealthKitMetric(name: "睡眠効率", value: "89%", status: "優秀"),
                    HealthKitMetric(name: "歩行速度", value: "5.2 km/h", status: "最適"),
                    HealthKitMetric(name: "HRV", value: "68ms", status: "良好"),
                    HealthKitMetric(name: "水分摂取", value: "2.2L", status: "最適")
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
        .navigationTitle("見た目の健康")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
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
