//
//  CognitiveDetailView.swift
//  AWStest
//
//  認知機能詳細ページ
//

import SwiftUI

struct CognitiveDetailView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.md) {
                    Text("🧠")
                        .font(.system(size: 48))

                    Text("92")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("COGNITIVE FUNCTION")
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

                    CognitiveScoreGraph()
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
                        GeneCard(
                            name: "APOE ε3/ε3",
                            description: "アルツハイマー病リスク：低",
                            impact: "保護型",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "BDNF Val66Met",
                            description: "学習・記憶能力：優良",
                            impact: "良好",
                            color: Color(hex: "0088CC")
                        )

                        GeneCard(
                            name: "COMT Val158Met",
                            description: "ドーパミン代謝：バランス型",
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
                        BloodMarkerRow(name: "Homocysteine", value: "8.2 μmol/L", status: "最適")
                        BloodMarkerRow(name: "Vitamin B12", value: "580 pg/mL", status: "良好")
                        BloodMarkerRow(name: "Folate", value: "12.5 ng/mL", status: "最適")
                        BloodMarkerRow(name: "Omega-3 Index", value: "8.2%", status: "優秀")
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
                            icon: "🥗",
                            title: "食事改善",
                            description: "オメガ3脂肪酸を週3回以上摂取",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🧘",
                            title: "瞑想習慣",
                            description: "毎日10分のマインドフルネス瞑想",
                            priority: "中"
                        )

                        RecommendationCard(
                            icon: "📚",
                            title: "認知トレーニング",
                            description: "週3回の記憶力・集中力トレーニング",
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
        .navigationTitle("認知機能")
        .navigationBarTitleDisplayMode(.large)
        .floatingChatButton()
    }
}

// MARK: - Cognitive Score Graph

struct CognitiveScoreGraph: View {
    private let scores = [78, 82, 85, 88, 90, 92]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                            .background(Color.gray.opacity(0.2))
                        Spacer()
                    }
                }

                // Score line
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(scores.count - 1)

                    for (index, score) in scores.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(score) / 100.0 * height)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color(hex: "00C853"), lineWidth: 3)

                // Data points
                HStack(spacing: 0) {
                    ForEach(scores.indices, id: \.self) { index in
                        VStack {
                            Spacer()
                            Circle()
                                .fill(Color(hex: "00C853"))
                                .frame(width: 8, height: 8)
                                .offset(y: -(CGFloat(scores[index]) / 100.0 * geometry.size.height))
                        }
                        if index < scores.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 150)
    }
}

// MARK: - Gene Card

struct GeneCard: View {
    let name: String
    let description: String
    let impact: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack {
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Text(impact)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.1))
                    .cornerRadius(4)
            }

            Text(description)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Blood Marker Row

struct BloodMarkerRow: View {
    let name: String
    let value: String
    let status: String

    // ステータスに応じた色分け (Optimal/最適=緑, Reference/正常範囲=黄, Risk/注意=赤)
    private var statusColor: Color {
        switch status {
        case "最適", "優秀", "Optimal", "Excellent":
            return Color(hex: "00C853")  // 緑
        case "良好", "正常範囲", "Reference", "Good", "Normal":
            return Color(hex: "FFCB05")  // 黄
        case "注意", "要注意", "Risk", "Warning":
            return Color(hex: "ED1C24")  // 赤
        default:
            return Color.gray
        }
    }

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            Text(status)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(statusColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(6)
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let icon: String
    let title: String
    let description: String
    let priority: String

    private var priorityColor: Color {
        switch priority {
        case "高": return Color(hex: "ED1C24")
        case "中": return Color(hex: "FFCB05")
        case "低": return Color(hex: "0088CC")
        default: return Color.gray
        }
    }

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            Text(icon)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                HStack {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)

                    Spacer()

                    Text(priority)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(priorityColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.1))
                        .cornerRadius(4)
                }

                Text(description)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#if DEBUG
struct CognitiveDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CognitiveDetailView()
        }
    }
}
#endif
