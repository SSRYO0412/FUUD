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

                    Text("90")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("SLEEP QUALITY")
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
                            name: "PER3 VNTR",
                            description: "概日リズム：安定型",
                            impact: "最適",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "CLOCK 3111T/C",
                            description: "睡眠パターン：夜型傾向軽度",
                            impact: "良好",
                            color: Color(hex: "0088CC")
                        )

                        GeneCard(
                            name: "ADORA2A",
                            description: "カフェイン感受性：中程度",
                            impact: "良好",
                            color: Color(hex: "0088CC")
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
                        BloodMarkerRow(name: "Melatonin", value: "12 pg/mL", status: "最適")
                        BloodMarkerRow(name: "Cortisol (朝)", value: "15 μg/dL", status: "良好")
                        BloodMarkerRow(name: "Magnesium", value: "2.3 mg/dL", status: "最適")
                        BloodMarkerRow(name: "Vitamin D", value: "45 ng/mL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Sleep Stages
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("SLEEP STAGES")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
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
