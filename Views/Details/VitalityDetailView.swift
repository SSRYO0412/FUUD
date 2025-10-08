//
//  VitalityDetailView.swift
//  AWStest
//
//  活力詳細ページ
//

import SwiftUI

struct VitalityDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("⚡️")
                        .font(.system(size: 48))

                    Text("91")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("VITALITY")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.xl)
                .virgilGlassCard()

                // Score Graph
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("SCORE TREND")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    ScoreTrendGraph(scores: [84, 86, 88, 89, 90, 91])  // [DUMMY] 過去6ヶ月のスコア
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
                        BloodMarkerRow(name: "Ferritin", value: "98 ng/mL", status: "最適")
                        BloodMarkerRow(name: "TKB", value: "0.8 mg/dL", status: "良好")
                        BloodMarkerRow(name: "LAC", value: "11 mg/dL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.6 g/dL", status: "最適")
                        BloodMarkerRow(name: "TP", value: "7.2 g/dL", status: "正常範囲")
                        BloodMarkerRow(name: "HbA1c", value: "5.2%", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
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

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "HRV", value: "72ms", status: "優秀"),
                    HealthKitMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitMetric(name: "睡眠効率", value: "88%", status: "優秀"),
                    HealthKitMetric(name: "日中活動量", value: "450kcal", status: "良好"),
                    HealthKitMetric(name: "立ち上がり回数", value: "12回/日", status: "最適")
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
        .navigationTitle("活力")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
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
