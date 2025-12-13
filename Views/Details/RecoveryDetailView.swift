//
//  RecoveryDetailView.swift
//  AWStest
//
//  疲労回復詳細ページ
//

import SwiftUI

struct RecoveryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // 共有ボタン用コピー通知トースト
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared
    // 回復指標データはUI検証用の固定値

    // MARK: - Category Data
    private let categoryName = "疲労回復"
    private let categoryId: CategoryId = .recovery

    // スコア取得用computed property
    private var currentScore: Int {
        lifestyleScoreService.getScore(for: categoryId) ?? 50
    }

    // カテゴリー関連遺伝子データ
    private let recoveryGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "ACTN3 R577X", variant: "R577X", risk: "優秀", description: "筋肉回復能力・速筋型"),
        (name: "PPARGC1A Gly482Ser", variant: "Gly482Ser", risk: "良好", description: "ミトコンドリア機能・持久力")
    ]

    // カテゴリー関連血液マーカーデータ
    private let recoveryBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "CK", value: "120", unit: "U/L", range: "60-400", status: "最適"),
        (name: "Mb", value: "45", unit: "ng/mL", range: "28-72", status: "良好"),
        (name: "LAC", value: "12", unit: "mg/dL", range: "5-20", status: "最適"),
        (name: "TKB", value: "0.8", unit: "mg/dL", range: "0.2-1.2", status: "良好"),
        (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "最適"),
        (name: "ALB", value: "4.5", unit: "g/dL", range: "3.8-5.3", status: "最適"),
        (name: "Mg", value: "2.2", unit: "mg/dL", range: "1.8-2.6", status: "良好")
    ]

    // カテゴリー関連HealthKitデータ
    private let recoveryHealthKit: [(name: String, value: String, status: String)] = [
        (name: "心拍回復 (HRR)", value: "35bpm/1min", status: "優秀"),
        (name: "トレーニング負荷", value: "適正", status: "良好"),
        (name: "ワークアウト強度", value: "中", status: "最適"),
        (name: "HRV", value: "68ms", status: "良好")
    ]

    var body: some View{
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("💪")
                        .font(.system(size: 24))

                    Text("\(currentScore)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("RECOVERY")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Tuuning Intelligence
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    HStack {
                        Text("🧠")
                            .font(.system(size: 16))
                        Text("TUUNING INTELLIGENCE")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text("あなたの疲労回復スコアは良好です。適切な休息と栄養補給が、効率的な回復に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // AIコメント、API連携後に実データ使用
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.virgilTextPrimary)
                        .lineSpacing(4)
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Score Graph
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("SCORE TREND")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    ScoreTrendGraph(scores: [79, 81, 83, 84, 86, 87])  // 過去6ヶ月のスコア
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

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

                        Button(action: shareGenes) { // 遺伝子セクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "ACTN3 R577X",
                            description: "筋肉回復能力・速筋型",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "PPARGC1A Gly482Ser",
                            description: "ミトコンドリア機能・持久力",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()
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

                        Button(action: shareBloodMarkers) { // 血液マーカーセクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "CK", value: "120 U/L", status: "最適")
                        BloodMarkerRow(name: "Mb", value: "45 ng/mL", status: "良好")
                        BloodMarkerRow(name: "LAC", value: "12 mg/dL", status: "最適")
                        BloodMarkerRow(name: "TKB", value: "0.8 mg/dL", status: "良好")
                        BloodMarkerRow(name: "Ferritin", value: "95 ng/mL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.5 g/dL", status: "最適")
                        BloodMarkerRow(name: "Mg", value: "2.2 mg/dL", status: "良好")
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "乳酸代謝菌",
                        description: "乳酸除去・筋肉回復促進",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "短鎖脂肪酸・抗炎症作用",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])
                */

                // Related HealthKit - MVP: HealthKit情報を非表示
                /*
                HealthKitSection(metrics: [
                    // HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "心拍回復 (HRR)", value: "35bpm/1min", status: "優秀"),
                    HealthKitSectionMetric(name: "トレーニング負荷", value: "適正", status: "良好"),
                    HealthKitSectionMetric(name: "ワークアウト強度", value: "中", status: "最適"),
                    HealthKitSectionMetric(name: "HRV", value: "68ms", status: "良好")
                ])
                */

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "😴",
                            title: "睡眠最適化",
                            description: "トレーニング後8時間以上の睡眠確保",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🧊",
                            title: "アイシング",
                            description: "高強度トレーニング後15分のアイシング",
                            priority: "中"
                        )

                        RecommendationCard(
                            icon: "🥩",
                            title: "タンパク質摂取",
                            description: "運動後30分以内にタンパク質20g摂取",
                            priority: "高"
                        )
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.md)
            .padding(.bottom, 100)
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("疲労回復")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // ナビゲーションバー共有ボタン
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
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // コピー完了トースト通知
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: recoveryGenes,
            relatedBloodMarkers: recoveryBloodMarkers,
            relatedHealthKit: recoveryHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: recoveryGenes,
            relatedBloodMarkers: recoveryBloodMarkers,
            relatedHealthKit: recoveryHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: recoveryGenes,
            relatedBloodMarkers: recoveryBloodMarkers,
            relatedHealthKit: recoveryHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct RecoveryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryDetailView()
        }
    }
}
#endif
