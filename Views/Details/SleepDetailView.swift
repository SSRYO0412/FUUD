//
//  SleepDetailView.swift
//  AWStest
//
//  睡眠詳細ページ
//

import SwiftUI

struct SleepDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("😴")
                        .font(.system(size: 48))

                    Text("90")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("SLEEP QUALITY")
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

                    ScoreTrendGraph(scores: [84, 86, 87, 88, 89, 90])  // [DUMMY] 過去6ヶ月のスコア
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
                            name: "PER3 VNTR",
                            description: "概日リズム：安定型",
                            impact: "最適",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "CLOCK 3111T/C",
                            description: "睡眠パターン：夜型傾向軽度",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "ADORA2A",
                            description: "カフェイン感受性：中程度",
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
                        BloodMarkerRow(name: "Melatonin", value: "12 pg/mL", status: "最適")
                        BloodMarkerRow(name: "Cortisol (朝)", value: "15 μg/dL", status: "良好")
                        BloodMarkerRow(name: "Magnesium", value: "2.3 mg/dL", status: "最適")
                        BloodMarkerRow(name: "Vitamin D", value: "45 ng/mL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "Lactobacillus",
                        description: "GABA産生・睡眠の質向上",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Bifidobacterium",
                        description: "セロトニン前駆体産生・メラトニン合成",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・概日リズム調整",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "睡眠時間", value: "7h 12m", status: "最適"),
                    HealthKitMetric(name: "深睡眠", value: "2h 30m", status: "優秀"),
                    HealthKitMetric(name: "レム睡眠", value: "1h 48m", status: "良好"),
                    HealthKitMetric(name: "睡眠効率", value: "89%", status: "優秀"),
                    HealthKitMetric(name: "HRV", value: "70ms", status: "優秀")
                ])

                // Sleep Stages
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("SLEEP STAGES")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 睡眠ステージデータ、API連携後に実データ使用
                        SleepStageRow(stage: "深睡眠", duration: "2.5時間", percentage: 35)
                        SleepStageRow(stage: "レム睡眠", duration: "1.8時間", percentage: 25)
                        SleepStageRow(stage: "浅睡眠", duration: "2.9時間", percentage: 40)
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🌙",
                            title: "就寝時刻の固定",
                            description: "毎日22:30-23:00の間に就寝",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "📱",
                            title: "ブルーライト制限",
                            description: "就寝2時間前からデバイス使用を控える",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🧘",
                            title: "就寝前ルーティン",
                            description: "瞑想・ストレッチで副交感神経を優位に",
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
        .navigationTitle("睡眠")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
    }
}

// MARK: - Sleep Stage Row

struct SleepStageRow: View {
    let stage: String
    let duration: String
    let percentage: Int

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack {
                Text(stage)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Text(duration)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(Color(hex: "0088CC"))
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#if DEBUG
struct SleepDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SleepDetailView()
        }
    }
}
#endif
