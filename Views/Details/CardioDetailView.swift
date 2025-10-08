//
//  CardioDetailView.swift
//  AWStest
//
//  心肺機能詳細ページ
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

                    Text("85")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("CARDIO FITNESS")
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
                            name: "ACE I/D",
                            description: "心肺持久力：ID型（良好）",
                            impact: "良好",
                            color: Color(hex: "0088CC")
                        )

                        GeneCard(
                            name: "PPARGC1A Gly482Ser",
                            description: "ミトコンドリア生成：最適",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "NOS3 -786T>C",
                            description: "血管拡張能：良好",
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
                        BloodMarkerRow(name: "VO2max", value: "42 mL/kg/min", status: "良好")
                        BloodMarkerRow(name: "Resting HR", value: "58 bpm", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "65 mg/dL", status: "良好")
                        BloodMarkerRow(name: "Triglycerides", value: "85 mg/dL", status: "最適")
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
                            icon: "🏃",
                            title: "有酸素運動",
                            description: "週3回、30分以上の中強度運動",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "⚡",
                            title: "HIIT導入",
                            description: "週1-2回の高強度インターバルトレーニング",
                            priority: "中"
                        )

                        RecommendationCard(
                            icon: "🫀",
                            title: "心拍変動モニタリング",
                            description: "毎朝のHRV測定で回復状態を確認",
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
        .navigationTitle("心肺機能")
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
