//
//  CognitiveDetailView.swift
//  AWStest
//
//  認知機能詳細ページ
//

import SwiftUI

struct CognitiveDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared
    // [DUMMY] スコア・遺伝子・血液・推奨事項はモックデータ

    // MARK: - Category Data
    private let categoryName = "認知機能"
    private let categoryId: CategoryId = .cognition

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // [DUMMY] カテゴリー関連遺伝子データ
    private let cognitiveGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "APOE ε3/ε3", variant: "ε3/ε3", risk: "低", description: "アルツハイマー病リスク：低"),
        (name: "BDNF Val66Met", variant: "Val66Met", risk: "良好", description: "学習・記憶能力：優良"),
        (name: "COMT Val158Met", variant: "Val158Met", risk: "最適", description: "ドーパミン代謝：バランス型")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let cognitiveBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "Homocysteine", value: "8.2", unit: "μmol/L", range: "5-15", status: "最適"),
        (name: "Vitamin B12", value: "580", unit: "pg/mL", range: "200-900", status: "良好"),
        (name: "Folate", value: "12.5", unit: "ng/mL", range: "3-20", status: "最適"),
        (name: "Omega-3 Index", value: "8.2", unit: "%", range: ">8", status: "優秀")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let cognitiveHealthKit: [(name: String, value: String, status: String)] = [
        (name: "睡眠時間", value: "7.5時間", status: "最適"),
        (name: "深睡眠", value: "90分", status: "優秀"),
        (name: "HRV", value: "68ms", status: "良好"),
        (name: "安静時心拍", value: "58bpm", status: "最適")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🧠")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("COGNITIVE FUNCTION")
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

                    Text("あなたの認知機能スコアは優秀です。規則正しい生活リズムと適度な運動が、脳の健康維持に寄与しています。引き続き現在の習慣を維持することで、長期的な認知機能の維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [78, 82, 85, 88, 90, 92])  // [DUMMY] 過去6ヶ月のスコア
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Genes - MVP: 遺伝子情報を非表示
                /*
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("🧬")
                            .font(.system(size: 16))
                        Text("RELATED GENES")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        Spacer()

                        Button(action: shareGenes) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    // [DUMMY] 遺伝子パネルはモックデータ
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
                */

                // Related Blood Markers
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("💉")
                            .font(.system(size: 16))
                        Text("RELATED BLOOD MARKERS")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        Spacer()

                        Button(action: shareBloodMarkers) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    // [DUMMY] 血液マーカーはモックデータ
                    VStack(spacing: VirgilSpacing.sm) {
                        BloodMarkerRow(name: "Homocysteine", value: "8.2 μmol/L", status: "最適")
                        BloodMarkerRow(name: "Vitamin B12", value: "580 pg/mL", status: "良好")
                        BloodMarkerRow(name: "Folate", value: "12.5 ng/mL", status: "最適")
                        BloodMarkerRow(name: "Omega-3 Index", value: "8.2%", status: "優秀")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "Faecalibacterium",
                        description: "酪酸産生菌・腸内環境を改善",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Roseburia",
                        description: "酪酸産生菌・抗炎症作用",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    ),
                    MicrobiomeItem(
                        name: "Bifidobacterium",
                        description: "プロバイオティクス・免疫機能向上",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Akkermansia",
                        description: "腸管バリア機能強化",
                        impact: "最適",
                        color: Color(hex: "00C853")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "睡眠時間", value: "7.5時間", status: "最適"),
                    HealthKitSectionMetric(name: "深睡眠", value: "90分", status: "優秀"),
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "良好"),
                    HealthKitSectionMetric(name: "安静時心拍", value: "58bpm", status: "最適")
                ])
                */

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    // [DUMMY] 推奨アクションはモックデータ
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
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("認知機能")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
            }
        }
        .task {
            // 初回表示時にスコア計算
            if lifestyleScoreService.categoryScores.isEmpty {
                await lifestyleScoreService.calculateAllScores()
            }
        }
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast)
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: cognitiveGenes,
            relatedBloodMarkers: cognitiveBloodMarkers,
            relatedHealthKit: cognitiveHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: cognitiveGenes,
            relatedBloodMarkers: cognitiveBloodMarkers,
            relatedHealthKit: cognitiveHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: cognitiveGenes,
            relatedBloodMarkers: cognitiveBloodMarkers,
            relatedHealthKit: cognitiveHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Gene Card

struct GeneCard: View {
    let name: String
    let description: String
    let impact: String
    let color: Color
    @State private var showCopyToast = false // [DUMMY] コピー通知トースト表示状態

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
        .onLongPressGesture(minimumDuration: 0.5) {
            // [DUMMY] 遺伝子カード長押し時にハプティックフィードバック＆プロンプト生成
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            let prompt = PromptGenerator.generateGenePrompt(
                geneName: name,
                variant: name, // [DUMMY] バリアント情報が分離されていないため名前を使用
                riskLevel: impact,
                description: description
            )
            CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
        }
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast)
    }
}

// MARK: - Blood Marker Row

struct BloodMarkerRow: View {
    let name: String
    let value: String
    let status: String
    @State private var showCopyToast = false // [DUMMY] コピー通知トースト表示状態

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
        .onLongPressGesture(minimumDuration: 0.5) {
            // [DUMMY] 血液マーカー長押し時にハプティックフィードバック＆プロンプト生成
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            let prompt = PromptGenerator.generateBloodMarkerPrompt(
                markerName: name,
                value: value.components(separatedBy: " ").first ?? value,
                unit: value.components(separatedBy: " ").last ?? "",
                referenceRange: "基準値範囲", // [DUMMY] 基準値が構造化されていないため固定文言
                status: status
            )
            CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
        }
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast)
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
