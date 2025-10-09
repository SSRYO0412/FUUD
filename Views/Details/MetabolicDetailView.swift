//
//  MetabolicDetailView.swift
//  AWStest
//
//  ダイエット（代謝機能）詳細ページ
//

import SwiftUI

struct MetabolicDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト
    // [DUMMY] 代謝スコアと各セクションは仮の固定値

    // MARK: - Category Data
    private let categoryName = "ダイエット"

    // [DUMMY] カテゴリー関連遺伝子データ
    private let metabolicGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "FTO rs9939609", variant: "rs9939609", risk: "標準", description: "肥満リスク：標準型"),
        (name: "TCF7L2 rs7903146", variant: "rs7903146", risk: "保護型", description: "2型糖尿病リスク：低"),
        (name: "UCP1 rs1800592", variant: "rs1800592", risk: "優秀", description: "脂肪燃焼効率：高"),
        (name: "ADRB2 rs1042714", variant: "rs1042714", risk: "良好", description: "代謝応答性：良好")
    ]

    // [DUMMY] カテゴリー関連血液マーカーデータ
    private let metabolicBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "HbA1c", value: "5.2", unit: "%", range: "4.0-6.0", status: "最適"),
        (name: "GA", value: "14.5", unit: "%", range: "11-16", status: "良好"),
        (name: "1,5-AG", value: "18.5", unit: "μg/mL", range: "14-30", status: "最適"),
        (name: "TG", value: "85", unit: "mg/dL", range: "<150", status: "最適"),
        (name: "HDL", value: "65", unit: "mg/dL", range: ">40", status: "良好"),
        (name: "LDL", value: "95", unit: "mg/dL", range: "<120", status: "最適"),
        (name: "TCHO", value: "180", unit: "mg/dL", range: "150-220", status: "正常範囲"),
        (name: "ApoB", value: "75", unit: "mg/dL", range: "<90", status: "最適")
    ]

    // [DUMMY] カテゴリー関連HealthKitデータ
    private let metabolicHealthKit: [(name: String, value: String, status: String)] = [
        (name: "体重", value: "68kg", status: "最適"),
        (name: "BMI", value: "22.5", status: "最適"),
        (name: "消費カロリー", value: "2,350kcal", status: "良好"),
        (name: "歩数", value: "8,500歩", status: "良好"),
        (name: "ワークアウト時間", value: "45分", status: "優秀")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("⚡️")
                        .font(.system(size: 24))

                    Text("85")  // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("METABOLIC FUNCTION")
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

                    Text("あなたの代謝機能スコアは良好です。バランスの取れた食事と適度な運動が、健康的な代謝機能の維持に寄与しています。引き続き現在の習慣を維持することで、長期的な健康維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
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

                    ScoreTrendGraph(scores: [72, 75, 78, 80, 83, 85])  // [DUMMY] 過去6ヶ月のスコア
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
                            name: "FTO rs9939609",
                            description: "肥満リスク：標準型",
                            impact: "標準",
                            color: Color(hex: "FFCB05")
                        )

                        GeneCard(
                            name: "TCF7L2 rs7903146",
                            description: "2型糖尿病リスク：低",
                            impact: "保護型",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "UCP1 rs1800592",
                            description: "脂肪燃焼効率：高",
                            impact: "優秀",
                            color: Color(hex: "00C853")
                        )

                        GeneCard(
                            name: "ADRB2 rs1042714",
                            description: "代謝応答性：良好",
                            impact: "良好",
                            color: Color(hex: "FFCB05")
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

                        Spacer()

                        Button(action: shareBloodMarkers) { // [DUMMY] 血液マーカーセクション共有ボタン
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.virgilTextSecondary)
                        }
                    }

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 血液マーカーデータ、API連携後に実データ使用
                        BloodMarkerRow(name: "HbA1c", value: "5.2%", status: "最適")
                        BloodMarkerRow(name: "GA", value: "14.5%", status: "良好")
                        BloodMarkerRow(name: "1,5-AG", value: "18.5 μg/mL", status: "最適")
                        BloodMarkerRow(name: "TG", value: "85 mg/dL", status: "最適")
                        BloodMarkerRow(name: "HDL", value: "65 mg/dL", status: "良好")
                        BloodMarkerRow(name: "LDL", value: "95 mg/dL", status: "最適")
                        BloodMarkerRow(name: "TCHO", value: "180 mg/dL", status: "正常範囲")
                        BloodMarkerRow(name: "ApoB", value: "75 mg/dL", status: "最適")
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // Related Microbiome
                MicrobiomeSection(bacteria: [
                    // [DUMMY] 腸内細菌データ、API連携後に実データ使用
                    MicrobiomeItem(
                        name: "SCFA産生菌",
                        description: "短鎖脂肪酸産生・代謝改善",
                        impact: "優秀",
                        color: Color(hex: "00C853")
                    ),
                    MicrobiomeItem(
                        name: "Prevotella/Bacteroides比",
                        description: "炭水化物代謝バランス",
                        impact: "良好",
                        color: Color(hex: "FFCB05")
                    )
                ])

                // Related HealthKit
                HealthKitSection(metrics: [
                    // [DUMMY] HealthKitデータ、API連携後に実データ使用
                    HealthKitMetric(name: "体重", value: "68kg", status: "最適"),
                    HealthKitMetric(name: "BMI", value: "22.5", status: "最適"),
                    HealthKitMetric(name: "消費カロリー", value: "2,350kcal", status: "良好"),
                    HealthKitMetric(name: "歩数", value: "8,500歩", status: "良好"),
                    HealthKitMetric(name: "ワークアウト時間", value: "45分", status: "優秀")
                ])

                // Recommendations
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        // [DUMMY] 推奨アクション、API連携後に実データ使用
                        RecommendationCard(
                            icon: "🍽️",
                            title: "食事管理",
                            description: "タンパク質を体重×1.6g/日摂取",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "🏃",
                            title: "有酸素運動",
                            description: "週3回30分のゾーン2トレーニング",
                            priority: "高"
                        )

                        RecommendationCard(
                            icon: "💪",
                            title: "筋力トレーニング",
                            description: "週2回の全身トレーニング",
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
        .navigationTitle("ダイエット")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { // [DUMMY] NavigationBarに共有ボタンを追加
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
            relatedGenes: metabolicGenes,
            relatedBloodMarkers: metabolicBloodMarkers,
            relatedHealthKit: metabolicHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: metabolicGenes,
            relatedBloodMarkers: metabolicBloodMarkers,
            relatedHealthKit: metabolicHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: metabolicGenes,
            relatedBloodMarkers: metabolicBloodMarkers,
            relatedHealthKit: metabolicHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }
}

// MARK: - Preview

#if DEBUG
struct MetabolicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MetabolicDetailView()
        }
    }
}
#endif
