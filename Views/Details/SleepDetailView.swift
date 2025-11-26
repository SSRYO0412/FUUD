//
//  SleepDetailView.swift
//  AWStest
//
//  睡眠詳細ページ
//

import SwiftUI

struct SleepDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared
    // [DUMMY] 睡眠指標や関連データはテスト用の固定値

    // MARK: - Category Data
    private let categoryName = "睡眠"
    private let categoryId: CategoryId = .sleep

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // [DUMMY] カテゴリー関連遺伝子データ
    private let sleepGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "PER3 VNTR", variant: "VNTR", risk: "最適", description: "概日リズム：安定型"),
        (name: "CLOCK 3111T/C", variant: "3111T/C", risk: "良好", description: "睡眠パターン：夜型傾向軽度"),
        (name: "ADORA2A", variant: "ADORA2A", risk: "良好", description: "カフェイン感受性：中程度")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let sleepBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "Melatonin", value: "12", unit: "pg/mL", range: "10-15", status: "最適"),
        (name: "Cortisol (朝)", value: "15", unit: "μg/dL", range: "10-20", status: "良好"),
        (name: "Magnesium", value: "2.3", unit: "mg/dL", range: "1.8-2.6", status: "最適"),
        (name: "Vitamin D", value: "45", unit: "ng/mL", range: "30-100", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let sleepHealthKit: [(name: String, value: String, status: String)] = [
        (name: "睡眠時間", value: "7h 12m", status: "最適"),
        (name: "深睡眠", value: "2h 30m", status: "優秀"),
        (name: "レム睡眠", value: "1h 48m", status: "良好"),
        (name: "睡眠効率", value: "89%", status: "優秀"),
        (name: "HRV", value: "70ms", status: "優秀")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("😴")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("SLEEP QUALITY")
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

                    Text("あなたの睡眠スコアは優秀です。規則正しい就寝時間と質の高い睡眠が、心身の健康維持に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [84, 86, 87, 88, 89, 90])  // [DUMMY] 過去6ヶ月のスコア
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

                        // [DUMMY] 共有ボタン追加
                        Button(action: shareGenes) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
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

                        // [DUMMY] 共有ボタン追加
                        Button(action: shareBloodMarkers) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
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

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
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
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "睡眠時間", value: "7h 12m", status: "最適"),
                    HealthKitSectionMetric(name: "深睡眠", value: "2h 30m", status: "優秀"),
                    HealthKitSectionMetric(name: "レム睡眠", value: "1h 48m", status: "良好"),
                    HealthKitSectionMetric(name: "睡眠効率", value: "89%", status: "優秀"),
                    HealthKitSectionMetric(name: "HRV", value: "70ms", status: "優秀")
                ])
                */

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
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("睡眠")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            // [DUMMY] NavigationBarに共有ボタン追加
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
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY] コピー通知トースト
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: sleepGenes,
            relatedBloodMarkers: sleepBloodMarkers,
            relatedHealthKit: sleepHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: sleepGenes,
            relatedBloodMarkers: sleepBloodMarkers,
            relatedHealthKit: sleepHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: sleepGenes,
            relatedBloodMarkers: sleepBloodMarkers,
            relatedHealthKit: sleepHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
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
