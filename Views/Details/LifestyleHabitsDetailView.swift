//
//  LifestyleHabitsDetailView.swift
//  AWStest
//
//  生活習慣詳細ページ
//

import SwiftUI

struct LifestyleHabitsDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト

    // MARK: - Category Data
    private let categoryName = "生活習慣"

    // [DUMMY] 生活習慣関連遺伝子データ
    private let lifestyleGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "FTO", variant: "FTO", risk: "良好", description: "食欲調節・肥満リスク"),
        (name: "APOE", variant: "APOE", risk: "優秀", description: "脂質代謝・認知機能"),
        (name: "ALDH2", variant: "ALDH2", risk: "優秀", description: "アルコール代謝")
    ]

    // [DUMMY] 生活習慣関連血液マーカーデータ
    private let lifestyleBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "HbA1c", value: "5.4", unit: "%", range: "4.6-6.2", status: "最適"),
        (name: "1,5-AG", value: "18", unit: "μg/mL", range: "14-26", status: "良好"),
        (name: "TG", value: "92", unit: "mg/dL", range: "<150", status: "最適"),
        (name: "HDL", value: "65", unit: "mg/dL", range: ">40", status: "優秀"),
        (name: "LDL", value: "105", unit: "mg/dL", range: "<120", status: "良好"),
        (name: "ApoB", value: "88", unit: "mg/dL", range: "<90", status: "最適"),
        (name: "UA", value: "5.8", unit: "mg/dL", range: "3.0-7.0", status: "正常範囲"),
        (name: "GGT", value: "28", unit: "U/L", range: "<50", status: "最適"),
        (name: "CRP", value: "0.08", unit: "mg/dL", range: "<0.3", status: "最適"),
        (name: "ALB", value: "4.4", unit: "g/dL", range: "3.8-5.3", status: "最適"),
        (name: "TP", value: "7.1", unit: "g/dL", range: "6.5-8.0", status: "正常範囲"),
        (name: "Ferritin", value: "88", unit: "ng/mL", range: "30-400", status: "良好")
    ]

    // [DUMMY] 生活習慣関連HealthKitデータ
    private let lifestyleHealthKit: [(name: String, value: String, status: String)] = [
        (name: "歩数", value: "10200歩/日", status: "優秀"),
        (name: "立ち時間", value: "10h/日", status: "最適"),
        (name: "ワークアウト分", value: "45分/日", status: "優秀"),
        (name: "睡眠効率", value: "86%", status: "良好"),
        (name: "HRV", value: "65ms", status: "良好")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("🌱")
                        .font(.system(size: 24))

                    Text("88")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("LIFESTYLE HABITS")
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

                    Text("あなたの生活習慣スコアは優秀です。規則正しい生活リズムと適度な運動が、遺伝子FTOの良好な発現とHbA1cの最適値に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [82, 84, 85, 86, 87, 88])  // [DUMMY] 過去6ヶ月のスコア
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

                        Button(action: shareGenes) { // [DUMMY]
                            Image(systemName: "doc.on.doc") // [DUMMY]
                                .font(.system(size: 14)) // [DUMMY]
                                .foregroundColor(.virgilTextSecondary) // [DUMMY]
                        } // [DUMMY]
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 遺伝子データ、API連携後に実データ使用
                        GeneCard(
                            name: "FTO",
                            description: "食欲調節・肥満リスク",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "APOE",
                            description: "脂質代謝・認知機能",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "ALDH2",
                            description: "アルコール代謝",
                            impact: "優秀",
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

                        Button(action: shareBloodMarkers) { // [DUMMY]
                            Image(systemName: "doc.on.doc") // [DUMMY]
                                .font(.system(size: 14)) // [DUMMY]
                                .foregroundColor(.virgilTextSecondary) // [DUMMY]
                        } // [DUMMY]
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "HbA1c", value: "5.4%", status: "最適")
                        BloodMarkerRow(name: "1,5-AG", value: "18 μg/mL", status: "良好")
                        BloodMarkerRow(name: "TG", value: "92 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "65 mg/dL", status: "優秀")
                        BloodMarkerRow(name: "LDL", value: "105 mg/dL", status: "良好")
                        BloodMarkerRow(name: "ApoB", value: "88 mg/dL", status: "最適")
                        BloodMarkerRow(name: "UA", value: "5.8 mg/dL", status: "正常範囲")
                        BloodMarkerRow(name: "GGT", value: "28 U/L", status: "最適")
                        BloodMarkerRow(name: "CRP", value: "0.08 mg/dL", status: "最適")
                        BloodMarkerRow(name: "ALB", value: "4.4 g/dL", status: "最適")
                        BloodMarkerRow(name: "TP", value: "7.1 g/dL", status: "正常範囲")
                        BloodMarkerRow(name: "Ferritin", value: "88 ng/mL", status: "良好")
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
                        description: "短鎖脂肪酸・代謝改善",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "多様性スコア",
                        description: "腸内フローラの多様性・健康度",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "F/B比",
                        description: "Firmicutes/Bacteroides比・肥満指標",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])
                */

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitSectionMetric(name: "歩数", value: "10200歩/日", status: "優秀"),
                    HealthKitSectionMetric(name: "立ち時間", value: "10h/日", status: "最適"),
                    HealthKitSectionMetric(name: "ワークアウト分", value: "45分/日", status: "優秀"),
                    HealthKitSectionMetric(name: "睡眠効率", value: "86%", status: "良好"),
                    HealthKitSectionMetric(name: "HRV", value: "65ms", status: "良好")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "⏰",
                            title: "規則正しい生活リズム",
                            description: "6時起床・22時就寝で概日リズム最適化",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "日常活動量アップ",
                            description: "階段利用・徒歩通勤で1日1万歩達成",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🥗",
                            title: "バランス食事",
                            description: "野菜・魚中心の地中海式食事法",
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
        .navigationTitle("生活習慣")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // [DUMMY]
            ToolbarItem(placement: .navigationBarTrailing) { // [DUMMY]
                Button(action: shareDetailView) { // [DUMMY]
                    Image(systemName: "square.and.arrow.up") // [DUMMY]
                        .font(.system(size: 16, weight: .medium)) // [DUMMY]
                        .foregroundColor(.virgilTextPrimary) // [DUMMY]
                } // [DUMMY]
            } // [DUMMY]
        } // [DUMMY]
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY]
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: lifestyleGenes,
            relatedBloodMarkers: lifestyleBloodMarkers,
            relatedHealthKit: lifestyleHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: lifestyleGenes,
            relatedBloodMarkers: lifestyleBloodMarkers,
            relatedHealthKit: lifestyleHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: lifestyleGenes,
            relatedBloodMarkers: lifestyleBloodMarkers,
            relatedHealthKit: lifestyleHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct LifestyleHabitsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LifestyleHabitsDetailView()
        }
    }
}
#endif
