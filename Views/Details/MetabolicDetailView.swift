//
//  MetabolicDetailView.swift
//  AWStest
//
//  ダイエット（代謝機能）詳細ページ
//

import SwiftUI

struct MetabolicDetailView: View {
    @Environment(\.dismiss) var dismiss
    // [DUMMY] 代謝スコアと各セクションは仮の固定値

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("⚡️")
                        .font(.system(size: 24))

                    Text("85")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("METABOLIC FUNCTION")
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

                    Text("あなたの代謝機能スコアは良好です。バランスの取れた食事と適度な運動が、健康的な代謝機能の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [72, 75, 78, 80, 83, 85])  // [DUMMY] 過去6ヶ月のスコア
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
                            name: "FTO rs9939609",
                            description: "肥満リスク：標準型",
                            impact: "標準",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "TCF7L2 rs7903146",
                            description: "2型糖尿病リスク：低",
                            impact: "保護型",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "UCP1 rs1800592",
                            description: "脂肪燃焼効率：高",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "ADRB2 rs1042714",
                            description: "代謝応答性：良好",
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
                        BloodMarkerRow(name: "HbA1c", value: "5.2%", status: "最適")
                        BloodMarkerRow(name: "GA", value: "14.5%", status: "良好")
                        BloodMarkerRow(name: "1,5-AG", value: "18.5 μg/mL", status: "最適")
                        BloodMarkerRow(name: "TG", value: "85 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "65 mg/dL", status: "良好")
                        BloodMarkerRow(name: "LDL", value: "95 mg/dL", status: "最適")
                        BloodMarkerRow(name: "TCHO", value: "180 mg/dL", status: "正常範囲")
                        BloodMarkerRow(name: "ApoB", value: "75 mg/dL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "短鎖脂肪酸産生・代謝改善",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Prevotella/Bacteroides比",
                        description: "炭水化物代謝バランス",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "体重", value: "68kg", status: "最適"),
                    HealthKitMetric(name: "BMI", value: "22.5", status: "最適"),
                    HealthKitMetric(name: "消費カロリー", value: "2,350kcal", status: "良好"),
                    HealthKitMetric(name: "歩数", value: "8,500歩", status: "良好"),
                    HealthKitMetric(name: "ワークアウト時間", value: "45分", status: "優秀")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🍽️",
                            title: "食事管理",
                            description: "タンパク質を体重×1.6g/日摂取",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "有酸素運動",
                            description: "週3回30分のゾーン2トレーニング",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "💪",
                            title: "筋力トレーニング",
                            description: "週2回の全身トレーニング",
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
        .navigationTitle("ダイエット")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
    }
}

// MARK: - Preview

#if DEBUG
struct MetabolicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MetabolicDetailView()
        }
    }
}
#endif
