//
//  AthleticDetailView.swift
//  AWStest
//
//  運動能力詳細ページ
//

import SwiftUI

struct AthleticDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    // [DUMMY] 表示スコアと関連データは仮の固定値

    // MARK: - Category Data
    private let categoryName = "運動能力"

    // [DUMMY] カテゴリー関連遺伝子データ
    private let athleticGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "ACTN3 R577X", variant: "R577X", risk: "優秀", description: "速筋型・瞬発力優位"),
        (name: "ACE I/D", variant: "I/D", risk: "良好", description: "持久力型・有酸素能力")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let athleticBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "CK", value: "120", unit: "U/L", range: "30-200", status: "最適"),
        (name: "Mb", value: "45", unit: "ng/mL", range: "20-80", status: "良好"),
        (name: "LAC", value: "12", unit: "mg/dL", range: "5-20", status: "最適"),
        (name: "TKB", value: "0.8", unit: "mg/dL", range: "0.2-1.2", status: "良好"),
        (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let athleticHealthKit: [(name: String, value: String, status: String)] = [
        (name: "VO2max", value: "48 ml/kg/min", status: "優秀"),
        (name: "最高心拍", value: "185bpm", status: "最適"),
        (name: "心拍回復", value: "35bpm/1min", status: "優秀"),
        (name: "走行ペース", value: "5:20/km", status: "良好"),
        (name: "トレーニング負荷", value: "適正", status: "最適")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🏃")
                        .font(.system(size: 24))

                    Text("89")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("ATHLETIC PERFORMANCE")
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

                    Text("あなたの運動能力スコアは優秀です。適切なトレーニングと栄養補給が、パフォーマンスの向上に寄与しています。引き続き現在の習慣を維持することで、長期的な運動能力の維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [81, 83, 85, 86, 88, 89])  // [DUMMY] 過去6ヶ月のスコア
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

                        Button(action: shareGenes) { // [DUMMY] 遺伝子セクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "ACTN3 R577X",
                            description: "速筋型・瞬発力優位",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "ACE I/D",
                            description: "持久力型・有酸素能力",
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

                        Button(action: shareBloodMarkers) { // [DUMMY] 血液マーカーセクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "CK", value: "120 U/L", status: "最適")
                        BloodMarkerRow(name: "Mb", value: "45 ng/mL", status: "良好")
                        BloodMarkerRow(name: "LAC", value: "12 mg/dL", status: "最適")
                        BloodMarkerRow(name: "TKB", value: "0.8 mg/dL", status: "良好")
                        BloodMarkerRow(name: "Ferritin", value: "95 ng/mL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome - MVP: 腸内細菌情報を非表示
                /*
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "持久力向上・エネルギー代謝",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "乳酸代謝菌",
                        description: "疲労物質除去・回復促進",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])
                */

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "VO2max", value: "48 ml/kg/min", status: "優秀"),
                    HealthKitSectionMetric(name: "最高心拍", value: "185bpm", status: "最適"),
                    HealthKitSectionMetric(name: "心拍回復", value: "35bpm/1min", status: "優秀"),
                    HealthKitSectionMetric(name: "走行ペース", value: "5:20/km", status: "良好"),
                    HealthKitSectionMetric(name: "トレーニング負荷", value: "適正", status: "最適")
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
                            title: "インターバルトレーニング",
                            description: "週2回のHIITで瞬発力向上",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "💪",
                            title: "筋力強化",
                            description: "週3回の全身レジスタンストレーニング",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "😴",
                            title: "回復時間確保",
                            description: "高強度トレーニング後48時間の回復",
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
        .navigationTitle("運動能力")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // [DUMMY] NavigationBarに全体共有ボタン追加
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
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
            relatedGenes: athleticGenes,
            relatedBloodMarkers: athleticBloodMarkers,
            relatedHealthKit: athleticHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: athleticGenes,
            relatedBloodMarkers: athleticBloodMarkers,
            relatedHealthKit: athleticHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: athleticGenes,
            relatedBloodMarkers: athleticBloodMarkers,
            relatedHealthKit: athleticHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct AthleticDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AthleticDetailView()
        }
    }
}
#endif
