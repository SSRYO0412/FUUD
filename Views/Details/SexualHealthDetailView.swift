//
//  SexualHealthDetailView.swift
//  AWStest
//
//  性的な健康詳細ページ
//

import SwiftUI

struct SexualHealthDetailView: View {
    @Environment(\.dismiss) var dismiss
    // [DUMMY] 性的健康に関するスコア・指標はモック

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("❤️")
                        .font(.system(size: 24))

                    Text("87")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("SEXUAL HEALTH")
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

                    Text("あなたの性的健康スコアは良好です。バランスの取れたホルモンレベルと健康的な生活習慣が、性機能の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [80, 82, 84, 85, 86, 87])  // [DUMMY] 過去6ヶ月のスコア
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
                .virgilGlassCard()

                // Related Microbiome
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

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "睡眠の質", value: "85%", status: "優秀"),
                    HealthKitMetric(name: "深睡眠", value: "1h 45m", status: "良好"),
                    HealthKitMetric(name: "HRV", value: "68ms", status: "優秀"),
                    HealthKitMetric(name: "体重", value: "72.5kg", status: "最適"),
                    HealthKitMetric(name: "月経周期", value: "28日", status: "正常範囲")
                ])

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
        .navigationTitle("性的な健康")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
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
