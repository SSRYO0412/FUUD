//
//  LifestyleHabitsDetailView.swift
//  AWStest
//
//  生活習慣詳細ページ
//

import SwiftUI

struct LifestyleHabitsDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("🌱")
                        .font(.system(size: 48))

                    Text("88")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("LIFESTYLE HABITS")
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

                    ScoreTrendGraph(scores: [82, 84, 85, 86, 87, 88])  // [DUMMY] 過去6ヶ月のスコア
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
                            name: "FTO",
                            description: "食欲調節・肥満リスク",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "APOE",
                            description: "脂質代謝・認知機能",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "ALDH2",
                            description: "アルコール代謝",
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
                        BloodMarkerRow(name: "HbA1c", value: "5.4%", status: "最適")
                        BloodMarkerRow(name: "1,5-AG", value: "18 μg/mL", status: "良好")
                        BloodMarkerRow(name: "TG", value: "92 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "65 mg/dL", status: "優秀")
                        BloodMarkerRow(name: "LDL", value: "105 mg/dL", status: "良好")
                        BloodMarkerRow(name: "ApoB", value: "88 mg/dL", status: "最適")
                        BloodMarkerRow(name: "UA", value: "5.8 mg/dL", status: "正常範囲")
                        BloodMarkerRow(name: "GGT", value: "28 U/L", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.08 mg/dL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.4 g/dL", status: "最適")
                        BloodMarkerRow(name: "TP", value: "7.1 g/dL", status: "正常範囲")
                        BloodMarkerRow(name: "Ferritin", value: "88 ng/mL", status: "良好")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "短鎖脂肪酸・代謝改善",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・健康度",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "F/B比",
                        description: "Firmicutes/Bacteroides比・肥満指標",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "歩数", value: "10200歩/日", status: "優秀"),
                    HealthKitMetric(name: "立ち時間", value: "10h/日", status: "最適"),
                    HealthKitMetric(name: "ワークアウト分", value: "45分/日", status: "優秀"),
                    HealthKitMetric(name: "睡眠効率", value: "86%", status: "良好"),
                    HealthKitMetric(name: "HRV", value: "65ms", status: "良好")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "⏰",
                            title: "規則正しい生活リズム",
                            description: "6時起床・22時就寝で概日リズム最適化",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "日常活動量アップ",
                            description: "階段利用・徒歩通勤で1日1万歩達成",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "バランス食事",
                            description: "野菜・魚中心の地中海式食事法",
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
        .navigationTitle("生活習慣")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
    }
}

// MARK: - Preview

#if DEBUG
struct LifestyleHabitsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LifestyleHabitsDetailView()
        }
    }
}
#endif
