//
//  CardioDetailView.swift
//  AWStest
//
//  心臓の健康詳細ページ
//

import SwiftUI

struct CardioDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("❤️")
                        .font(.system(size: 48))

                    Text("85")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("CARDIAC HEALTH")
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
                    HealthKitMetric(name: "安静時心拍", value: "58bpm", status: "最適"),
                    HealthKitMetric(name: "HRV", value: "68ms", status: "優秀"),
                    HealthKitMetric(name: "血圧", value: "118/75", status: "最適"),
                    HealthKitMetric(name: "VO2max", value: "42 ml/kg/min", status: "良好"),
                    HealthKitMetric(name: "有酸素運動時間", value: "150分/週", status: "最適")
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
        .floatingChatButton()
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
