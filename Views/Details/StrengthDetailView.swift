//
//  StrengthDetailView.swift
//  AWStest
//
//  筋力詳細ページ
//

import SwiftUI

struct StrengthDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("💪")
                        .font(.system(size: 48))

                    Text("88")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("MUSCLE STRENGTH")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.xl)
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
                        GeneCard(
                            name: "ACTN3 R577X",
                            description: "速筋繊維タイプ：RR型（パワー型）",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "ACE I/D",
                            description: "持久力遺伝子：ID型（バランス型）",
                            impact: "良好",
                            color: Color(hex: "0088CC")
                        )

                        GeneCard(
                            name: "MSTN K153R",
                            description: "筋肉量調節：良好",
                            impact: "最適",
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
                        BloodMarkerRow(name: "Testosterone", value: "650 ng/dL", status: "最適")
                        BloodMarkerRow(name: "Creatinine", value: "0.95 mg/dL", status: "良好")
                        BloodMarkerRow(name: "CK (CPK)", value: "180 U/L", status: "正常")
                        BloodMarkerRow(name: "Vitamin D", value: "45 ng/mL", status: "最適")
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
                        RecommendationCard(
                            icon: "🏋️",
                            title: "筋トレ強化",
                            description: "週3回、各部位を十分な負荷で刺激",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥩",
                            title: "タンパク質摂取",
                            description: "体重1kgあたり2g以上のタンパク質",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "😴",
                            title: "回復重視",
                            description: "筋トレ後48時間の十分な休養",
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
        .navigationTitle("筋力")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
    }
}

// MARK: - Preview

#if DEBUG
struct StrengthDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StrengthDetailView()
        }
    }
}
#endif
