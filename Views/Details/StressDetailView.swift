//
//  StressDetailView.swift
//  AWStest
//
//  ストレス詳細ページ
//

import SwiftUI

struct StressDetailView: View {
    @Environment(\.dismiss) var dismiss
    // [DUMMY] ストレス関連データはモック

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🧘")
                        .font(.system(size: 24))

                    Text("82")  // [DUMMY] スコア、API連携後に実データ使用
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
                        BloodMarkerRow(name: "CRP", value: "0.3 mg/L", status: "最適")
                        BloodMarkerRow(name: "LAC", value: "12 mg/dL", status: "良好")
                        BloodMarkerRow(name: "1,5-AG", value: "18.5 μg/mL", status: "最適")
                        BloodMarkerRow(name: "GGT", value: "22 U/L", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
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

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "HRV", value: "68ms", status: "良好"),
                    HealthKitMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitMetric(name: "呼吸数", value: "14回/分", status: "最適"),
                    HealthKitMetric(name: "マインドフルネス時間", value: "10分/日", status: "良好")
                ])

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
        .navigationTitle("ストレス")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
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
