//
//  StrengthDetailView.swift
//  AWStest
//
//  筋力詳細ページ
//

import SwiftUI

struct StrengthDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCopyToast = false // [DUMMY] 共有ボタン用コピー通知トースト

    // MARK: - Category Data
    private let categoryName = "筋力"

    // [DUMMY] 筋力関連遺伝子データ
    private let strengthGenes: [(name: String, variant: String, risk: String, description: String)] = [
        (name: "ACTN3 R577X", variant: "RR型", risk: "優秀", description: "速筋繊維タイプ：RR型（パワー型）"),
        (name: "ACE I/D", variant: "ID型", risk: "良好", description: "持久力遺伝子：ID型（バランス型）"),
        (name: "MSTN K153R", variant: "良好", risk: "最適", description: "筋肉量調節：良好")
    ]

    // [DUMMY] 筋力関連血液マーカーデータ
    private let strengthBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)] = [
        (name: "Testosterone", value: "650", unit: "ng/dL", range: "300-1000", status: "最適"),
        (name: "Creatinine", value: "0.95", unit: "mg/dL", range: "0.6-1.2", status: "良好"),
        (name: "CK (CPK)", value: "180", unit: "U/L", range: "50-200", status: "正常"),
        (name: "Vitamin D", value: "45", unit: "ng/mL", range: "30-100", status: "最適")
    ]

    // [DUMMY] 筋力関連HealthKitデータ
    private let strengthHealthKit: [(name: String, value: String, status: String)] = []

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // Header Score
                VStack(spacing: VirgilSpacing.sm) {
                    Text("💪")
                        .font(.system(size: 24))

                    Text("88") // [DUMMY] スコア、API連携後に実データ使用
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("MUSCLE STRENGTH")
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

                    Text("あなたの筋力スコアは優秀です。適切な筋力トレーニングとタンパク質摂取が、筋肉量の維持と増強に寄与しています。引き続き現在の習慣を維持することで、長期的な筋力維持が期待できます。")  // [DUMMY] AIコメント、API連携後に実データ使用
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.virgilTextPrimary)
                        .lineSpacing(4)
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

                    // [DUMMY] 遺伝子データはモック
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

                    // [DUMMY] 血液マーカーはモック
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

                    // [DUMMY] 推奨アクションはモック
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
        .toolbar { // [DUMMY] NavigationBarに共有ボタン追加
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareDetailView) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
            }
        }
        .floatingChatButton()
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast) // [DUMMY] コピー完了トースト
    }

    // MARK: - Share Actions

    /// DetailView全体のデータをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestService/GeneDataService連携
    private func shareDetailView() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: strengthGenes,
            relatedBloodMarkers: strengthBloodMarkers,
            relatedHealthKit: strengthHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 遺伝子セクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareGenes() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: strengthGenes,
            relatedBloodMarkers: strengthBloodMarkers,
            relatedHealthKit: strengthHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
    }

    /// 血液マーカーセクションをプロンプトとしてコピー
    /// [DUMMY] 現状はモックデータ
    private func shareBloodMarkers() {
        let prompt = PromptGenerator.generateCategoryPrompt(
            category: categoryName,
            relatedGenes: strengthGenes,
            relatedBloodMarkers: strengthBloodMarkers,
            relatedHealthKit: strengthHealthKit
        )
        CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
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
