//
//  LiverDetailView.swift
//  AWStest
//
//  肝機能詳細ページ
//

import SwiftUI

struct LiverDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("🫀")
                        .font(.system(size: 48))

                    Text("86")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("LIVER FUNCTION")
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
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "PNPLA3",
                            description: "脂肪肝リスク・脂質代謝",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "ALDH2",
                            description: "アルコール代謝・アセトアルデヒド分解",
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
                        BloodMarkerRow(name: "AST", value: "22 U/L", status: "最適")
                        BloodMarkerRow(name: "ALT", value: "18 U/L", status: "最適")
                        BloodMarkerRow(name: "GGT", value: "25 U/L", status: "最適")
                        BloodMarkerRow(name: "ALP", value: "195 U/L", status: "正常範囲")
                        BloodMarkerRow(name: "T-Bil", value: "0.9 mg/dL", status: "最適")
                        BloodMarkerRow(name: "D-Bil", value: "0.2 mg/dL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.5 g/dL", status: "最適")
                        BloodMarkerRow(name: "TG", value: "88 mg/dL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "胆汁酸代謝菌",
                        description: "胆汁酸再吸収・肝臓保護",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "エタノール産生菌",
                        description: "内因性アルコール産生・肝負担指標",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・健康度",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "飲酒ログ", value: "週2日", status: "良好"),
                    HealthKitMetric(name: "体重推移", value: "-0.5kg/月", status: "最適"),
                    HealthKitMetric(name: "睡眠タイミング", value: "22:30-6:00", status: "優秀"),
                    HealthKitMetric(name: "歩数", value: "9500歩/日", status: "良好")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🚫",
                            title: "週2休肝日確保",
                            description: "連続飲酒を避け、肝臓の回復時間を確保",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "抗酸化食材摂取",
                            description: "ブロッコリー・緑茶で肝保護",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "有酸素運動",
                            description: "週3回30分のウォーキングで脂肪肝予防",
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
        .navigationTitle("肝機能")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
    }
}

// MARK: - Preview

#if DEBUG
struct LiverDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LiverDetailView()
        }
    }
}
#endif
