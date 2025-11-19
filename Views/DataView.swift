//
//  DataView.swift
//  AWStest
//
//  DATA画面 - HTML版完全一致
//

import SwiftUI

struct DataView: View {
    @State private var selectedTab: DataTab = .lifestyle

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Background Orbs
                OrbBackground()

                ScrollView {
                    VStack(spacing: VirgilSpacing.md) {
                        // Tab Navigation
                        HStack(spacing: VirgilSpacing.sm) {
                        ForEach(DataTab.allCases) { tab in
                            TabButton(
                                tab: tab,
                                isSelected: selectedTab == tab,
                                action: { selectedTab = tab }
                            )
                        }
                    }
                    .padding(VirgilSpacing.xs)
                    .background(
                        Color.white.opacity(0.03)
                    )
                    .cornerRadius(VirgilSpacing.radiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: VirgilSpacing.radiusLarge)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                    // Tab Content
                    Group {
                        switch selectedTab {
                        case .blood:
                            BloodTab()
                        case .lifestyle:
                            LifestyleTab()
                        }
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.sm)
                }
            }
            .navigationTitle("data")
            .floatingChatButton()
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Data Tab Enum

enum DataTab: String, CaseIterable, Identifiable {
    case lifestyle = "LIFESTYLE"
    case blood = "BLOOD"
    // case microbiome = "MICROBIOME" - 一時的に非表示

    var id: String { rawValue }
}

// MARK: - Tab Button

private struct TabButton: View {
    let tab: DataTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tab.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isSelected ? Color.white : Color.gray)
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.sm)
                .background(isSelected ? Color.black : Color.clear)
                .cornerRadius(VirgilSpacing.radiusMedium)
        }
    }
}

// MARK: - Blood Tab

private struct BloodTab: View {
    // [DUMMY] 血液スコア表示は暫定値。バックエンド連携後に動的化予定
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("BLOOD BIOMARKERS")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text("87") // [DUMMY] 仮スコア値
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#00C853"))
            }
            .padding(.bottom, VirgilSpacing.sm)

            BloodTestView()
        }
    }
}

// MARK: - Microbiome Tab

private struct MicrobiomeTab: View {
    // [DUMMY] 多様性スコアと菌種リストはモックデータ
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
            // Diversity Score
            VStack(spacing: VirgilSpacing.md) {
                Text("85") // [DUMMY] モックの多様性スコア
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#00C853"), Color(hex: "#0088CC")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("DIVERSITY SCORE")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(VirgilSpacing.xl)
            .virgilGlassCard()

            // Bacteria List
            VStack(spacing: VirgilSpacing.sm) {
                BacteriaRow(name: "Faecalibacterium", percentage: "18.5%") // [DUMMY] モックの菌種データ
                BacteriaRow(name: "Bifidobacterium", percentage: "15.2%") // [DUMMY] モックの菌種データ
                BacteriaRow(name: "Akkermansia", percentage: "12.8%") // [DUMMY] モックの菌種データ
            }
        }
    }
}

private struct BacteriaRow: View {
    let name: String
    let percentage: String
    // [DUMMY] 腸内細菌の構成比は仮の固定値

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 10, weight: .medium))
                .italic()
            Spacer()
            Text(percentage)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(VirgilSpacing.radiusMedium)
    }
}

// MARK: - Lifestyle Tab

private struct LifestyleTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("LIFESTYLE SCORES")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)

            VStack(spacing: VirgilSpacing.sm) {
                // [DUMMY] スコア値は仮データ、API連携後に実データ使用
                LifeScoreCard(emoji: "⚡️", title: "ダイエット", score: 68) // [DUMMY] 黄グラデ
                LifeScoreCard(emoji: "😴", title: "睡眠", score: 88) // [DUMMY] 緑グラデ
                LifeScoreCard(emoji: "💪", title: "疲労回復", score: 58) // [DUMMY] 黄グラデ
                LifeScoreCard(emoji: "🏃", title: "運動能力", score: 95) // [DUMMY] 緑グラデ
                LifeScoreCard(emoji: "🧘", title: "ストレス", score: 38) // [DUMMY] 赤グラデ
                LifeScoreCard(emoji: "🛡️", title: "抗酸化", score: 72) // [DUMMY] 黄グラデ
                LifeScoreCard(emoji: "🧠", title: "脳の認知機能", score: 92) // [DUMMY] 緑グラデ
                LifeScoreCard(emoji: "✨", title: "見た目の健康", score: 45) // [DUMMY] 赤グラデ
                LifeScoreCard(emoji: "🌸", title: "肌", score: 82) // [DUMMY] 緑グラデ
                LifeScoreCard(emoji: "❤️", title: "性的な健康", score: 65) // [DUMMY] 黄グラデ
                LifeScoreCard(emoji: "⚡", title: "活力", score: 42) // [DUMMY] 赤グラデ
                LifeScoreCard(emoji: "❤️‍🩹", title: "心臓の健康", score: 86) // [DUMMY] 緑グラデ
                LifeScoreCard(emoji: "🫘", title: "肝機能", score: 75) // [DUMMY] 黄グラデ
                LifeScoreCard(emoji: "📊", title: "生活習慣", score: 48) // [DUMMY] 赤グラデ
            }
        }
    }
}

private struct LifeScoreCard: View {
    let emoji: String
    let title: String
    let score: Int
    @State private var showCopyToast = false // [DUMMY] コピー通知トースト表示状態
    @State private var showActionDialog = false // [DUMMY] アクション選択ダイアログ表示状態
    @State private var navigateToDetail = false // [DUMMY] DetailView遷移フラグ

    // スコア別グラデーションカラー（左濃→右薄）
    private var scoreGradient: LinearGradient {
        switch score {
        case 80...100:
            // 優秀: 緑基調の濃淡グラデーション（左濃→右薄）
            return LinearGradient(
                colors: [Color(hex: "66BB6A"), Color(hex: "C8E6C9")],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 50...79:
            // 良好: 黄色基調の濃淡グラデーション（左濃→右薄）
            return LinearGradient(
                colors: [Color(hex: "FBC02D"), Color(hex: "FFF9C4")],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            // 要改善: 赤色基調の濃淡グラデーション（左濃→右薄）
            return LinearGradient(
                colors: [Color(hex: "E57373"), Color(hex: "FFCCBC")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    // スコア数値の色（左側の濃い色に合わせる）
    private var scoreTextColor: Color {
        switch score {
        case 80...100:
            return Color(hex: "66BB6A")
        case 50...79:
            return Color(hex: "FBC02D")
        default:
            return Color(hex: "E57373")
        }
    }

    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                HStack {
                    Text(emoji)
                        .font(.system(size: 17.6))  // 16 * 1.1
                    Text(title)
                        .font(.system(size: 17.6, weight: .semibold))  // 絵文字と同じサイズ
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                }

                Text("\(score)")
                    .font(.system(size: 26.4, weight: .black))  // 24 * 1.1
                    .foregroundColor(scoreTextColor)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4.95, style: .continuous)
                            .fill(Color.clear)  // iOS 26 Liquid Glass透明度を活かすため透明化
                            .frame(height: 9.9)  // 3 * 1.1 * 3 = 9.9

                        RoundedRectangle(cornerRadius: 4.95, style: .continuous)
                            .fill(scoreGradient)
                            .frame(width: geometry.size.width * CGFloat(score) / 100, height: 9.9)  // 3 * 1.1 * 3 = 9.9
                    }
                    }
                    .frame(height: 9.9)  // 3 * 1.1 * 3 = 9.9
                }
                .padding(VirgilSpacing.md * 1.1)  // padding 10%拡大

                LongPressHint(helpText: "\(title)のスコアです。タップすると詳細な分析が表示されます。")
                    .padding(8)
            }
            .virgilGlassCard(interactive: true)
            .onLongPressGesture(minimumDuration: 0.5) {
                // [DUMMY] ライフスコアカード長押し時にハプティックフィードバック＆ダイアログ表示
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showActionDialog = true
            }
        }
        .buttonStyle(.plain)  // NavigationLinkのデフォルト背景を削除
        .background(
            NavigationLink(isActive: $navigateToDetail, destination: { destinationView }) {
                EmptyView()
            }
            .hidden()
        )
        .confirmationDialog("アクション選択", isPresented: $showActionDialog) {
            Button("プロンプトを生成") {
                // [DUMMY] カテゴリー完全データプロンプトを生成＆コピー
                let categoryData = getCategoryData(for: title)
                let prompt = PromptGenerator.generateCategoryPrompt(
                    category: categoryData.name,
                    relatedGenes: categoryData.genes,
                    relatedBloodMarkers: categoryData.bloodMarkers,
                    relatedHealthKit: categoryData.healthKit
                )
                CopyHelper.copyToClipboard(prompt, showToast: $showCopyToast)
            }
            Button("詳細を開く") {
                navigateToDetail = true
            }
            Button("キャンセル", role: .cancel) { }
        }
        .showToast(message: "✅ プロンプトをコピーしました", isShowing: $showCopyToast)
    }

    // MARK: - Category Data Mapping

    /// カテゴリー名からデータを取得
    /// [DUMMY] 全カテゴリーのモックデータ、DetailViewと同じ内容
    private func getCategoryData(for category: String) -> (
        name: String,
        genes: [(name: String, variant: String, risk: String, description: String)],
        bloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)],
        healthKit: [(name: String, value: String, status: String)]
    ) {
        switch category {
        case "脳の認知機能":
            return (
                name: "認知機能",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "Homocysteine", value: "8.2", unit: "μmol/L", range: "5-15", status: "最適"),
                    (name: "Vitamin B12", value: "580", unit: "pg/mL", range: "200-900", status: "良好"),
                    (name: "Folate", value: "12.5", unit: "ng/mL", range: "3-20", status: "最適"),
                    (name: "Omega-3 Index", value: "8.2", unit: "%", range: ">8", status: "優秀")
                ],
                healthKit: [
                    (name: "睡眠時間", value: "7.5時間", status: "最適"),
                    (name: "深睡眠", value: "90分", status: "優秀"),
                    (name: "HRV", value: "68ms", status: "良好"),
                    (name: "安静時心拍", value: "58bpm", status: "最適")
                ]
            )
        case "活力":
            return (
                name: "活力",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "Ferritin", value: "98", unit: "ng/mL", range: "30-400", status: "最適"),
                    (name: "TKB", value: "0.8", unit: "mg/dL", range: "0.4-1.5", status: "良好"),
                    (name: "LAC", value: "11", unit: "mg/dL", range: "4-16", status: "最適"),
                    (name: "ALB", value: "4.6", unit: "g/dL", range: "4.1-5.1", status: "最適"),
                    (name: "TP", value: "7.2", unit: "g/dL", range: "6.6-8.1", status: "正常範囲"),
                    (name: "HbA1c", value: "5.2", unit: "%", range: "<5.6", status: "最適")
                ],
                healthKit: [
                    (name: "HRV", value: "72ms", status: "優秀"),
                    (name: "安静時心拍", value: "58bpm", status: "最適"),
                    (name: "睡眠効率", value: "88%", status: "優秀"),
                    (name: "日中活動量", value: "450kcal", status: "良好"),
                    (name: "立ち上がり回数", value: "12回/日", status: "最適")
                ]
            )
        case "肝機能":
            return (
                name: "肝機能",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "AST", value: "22", unit: "U/L", range: "10-40", status: "最適"),
                    (name: "ALT", value: "18", unit: "U/L", range: "5-45", status: "最適"),
                    (name: "GGT", value: "25", unit: "U/L", range: "0-50", status: "最適"),
                    (name: "ALP", value: "195", unit: "U/L", range: "100-325", status: "正常範囲"),
                    (name: "T-Bil", value: "0.9", unit: "mg/dL", range: "0.2-1.2", status: "最適"),
                    (name: "D-Bil", value: "0.2", unit: "mg/dL", range: "0.0-0.4", status: "最適"),
                    (name: "ALB", value: "4.5", unit: "g/dL", range: "3.8-5.3", status: "最適"),
                    (name: "TG", value: "88", unit: "mg/dL", range: "30-150", status: "最適")
                ],
                healthKit: [
                    (name: "飲酒ログ", value: "週2日", status: "良好"),
                    (name: "体重推移", value: "-0.5kg/月", status: "最適"),
                    (name: "睡眠タイミング", value: "22:30-6:00", status: "優秀"),
                    (name: "歩数", value: "9500歩/日", status: "良好")
                ]
            )
        case "生活習慣":
            return (
                name: "生活習慣",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
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
                ],
                healthKit: [
                    (name: "歩数", value: "10200歩/日", status: "優秀"),
                    (name: "立ち時間", value: "10h/日", status: "最適"),
                    (name: "ワークアウト分", value: "45分/日", status: "優秀"),
                    (name: "睡眠効率", value: "86%", status: "良好"),
                    (name: "HRV", value: "65ms", status: "良好")
                ]
            )
        case "ダイエット":
            return (
                name: "ダイエット",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "HbA1c", value: "5.2", unit: "%", range: "4.0-6.0", status: "最適"),
                    (name: "GA", value: "14.5", unit: "%", range: "11-16", status: "良好"),
                    (name: "1,5-AG", value: "18.5", unit: "μg/mL", range: "14-30", status: "最適"),
                    (name: "TG", value: "85", unit: "mg/dL", range: "<150", status: "最適"),
                    (name: "HDL", value: "65", unit: "mg/dL", range: ">40", status: "良好"),
                    (name: "LDL", value: "95", unit: "mg/dL", range: "<120", status: "最適"),
                    (name: "TCHO", value: "180", unit: "mg/dL", range: "150-220", status: "正常範囲"),
                    (name: "ApoB", value: "75", unit: "mg/dL", range: "<90", status: "最適")
                ],
                healthKit: [
                    (name: "体重", value: "68kg", status: "最適"),
                    (name: "BMI", value: "22.5", status: "最適"),
                    (name: "消費カロリー", value: "2,350kcal", status: "良好"),
                    (name: "歩数", value: "8,500歩", status: "良好"),
                    (name: "ワークアウト時間", value: "45分", status: "優秀")
                ]
            )
        case "見た目の健康":
            return (
                name: "見た目の健康",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "ALB", value: "4.5", unit: "g/dL", range: "3.8-5.2", status: "最適"),
                    (name: "TP", value: "7.2", unit: "g/dL", range: "6.5-8.2", status: "最適"),
                    (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-200", status: "良好"),
                    (name: "Zn", value: "95", unit: "μg/dL", range: "80-120", status: "最適"),
                    (name: "CRP", value: "0.3", unit: "mg/L", range: "<1.0", status: "最適"),
                    (name: "GGT", value: "22", unit: "U/L", range: "10-50", status: "最適"),
                    (name: "HbA1c", value: "5.2", unit: "%", range: "4.0-5.6", status: "最適")
                ],
                healthKit: [
                    (name: "VO2max", value: "42 ml/kg/min", status: "良好"),
                    (name: "睡眠効率", value: "89%", status: "優秀"),
                    (name: "歩行速度", value: "5.2 km/h", status: "最適"),
                    (name: "HRV", value: "68ms", status: "良好"),
                    (name: "水分摂取", value: "2.2L", status: "最適")
                ]
            )
        case "睡眠":
            return (
                name: "睡眠",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "Melatonin", value: "12", unit: "pg/mL", range: "10-15", status: "最適"),
                    (name: "Cortisol (朝)", value: "15", unit: "μg/dL", range: "10-20", status: "良好"),
                    (name: "Magnesium", value: "2.3", unit: "mg/dL", range: "1.8-2.6", status: "最適"),
                    (name: "Vitamin D", value: "45", unit: "ng/mL", range: "30-100", status: "最適")
                ],
                healthKit: [
                    (name: "睡眠時間", value: "7h 12m", status: "最適"),
                    (name: "深睡眠", value: "2h 30m", status: "優秀"),
                    (name: "レム睡眠", value: "1h 48m", status: "良好"),
                    (name: "睡眠効率", value: "89%", status: "優秀"),
                    (name: "HRV", value: "70ms", status: "優秀")
                ]
            )
        case "疲労回復":
            return (
                name: "疲労回復",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "CK", value: "120", unit: "U/L", range: "60-400", status: "最適"),
                    (name: "Mb", value: "45", unit: "ng/mL", range: "28-72", status: "良好"),
                    (name: "LAC", value: "12", unit: "mg/dL", range: "5-20", status: "最適"),
                    (name: "TKB", value: "0.8", unit: "mg/dL", range: "0.2-1.2", status: "良好"),
                    (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "最適"),
                    (name: "ALB", value: "4.5", unit: "g/dL", range: "3.8-5.3", status: "最適"),
                    (name: "Mg", value: "2.2", unit: "mg/dL", range: "1.8-2.6", status: "良好")
                ],
                healthKit: [
                    (name: "心拍回復 (HRR)", value: "35bpm/1min", status: "優秀"),
                    (name: "トレーニング負荷", value: "適正", status: "良好"),
                    (name: "ワークアウト強度", value: "中", status: "最適"),
                    (name: "HRV", value: "68ms", status: "良好")
                ]
            )
        case "肌":
            return (
                name: "肌",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "Zn", value: "95", unit: "μg/dL", range: "60-130", status: "最適"),
                    (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "良好"),
                    (name: "ALB", value: "4.5", unit: "g/dL", range: "4.0-5.0", status: "最適"),
                    (name: "CRP", value: "0.3", unit: "mg/L", range: "<3.0", status: "最適"),
                    (name: "GGT", value: "22", unit: "U/L", range: "0-73", status: "最適"),
                    (name: "HbA1c", value: "5.2", unit: "%", range: "<5.6", status: "最適"),
                    (name: "TP", value: "7.2", unit: "g/dL", range: "6.6-8.1", status: "良好"),
                    (name: "pAlb", value: "28", unit: "mg/dL", range: "25-30", status: "最適")
                ],
                healthKit: [
                    (name: "深睡眠", value: "90分", status: "優秀"),
                    (name: "HRV", value: "68ms", status: "良好"),
                    (name: "安静時心拍", value: "58bpm", status: "最適"),
                    (name: "水分摂取", value: "2.2L", status: "最適")
                ]
            )
        case "抗酸化":
            return (
                name: "抗酸化",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "GGT", value: "22", unit: "U/L", range: "0-50", status: "最適"),
                    (name: "UA", value: "5.2", unit: "mg/dL", range: "3.0-7.0", status: "最適"),
                    (name: "CRP", value: "0.3", unit: "mg/L", range: "<1.0", status: "最適"),
                    (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "良好"),
                    (name: "Zn", value: "95", unit: "μg/dL", range: "80-130", status: "最適")
                ],
                healthKit: [
                    (name: "高強度運動時間", value: "週150分", status: "最適"),
                    (name: "睡眠時間", value: "7.5時間", status: "良好")
                ]
            )
        case "ストレス":
            return (
                name: "ストレス",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "CRP", value: "0.3", unit: "mg/L", range: "0-5", status: "最適"),
                    (name: "LAC", value: "12", unit: "mg/dL", range: "4-16", status: "良好"),
                    (name: "1,5-AG", value: "18.5", unit: "μg/mL", range: "14-30", status: "最適"),
                    (name: "GGT", value: "22", unit: "U/L", range: "0-50", status: "最適")
                ],
                healthKit: [
                    (name: "HRV", value: "68ms", status: "良好"),
                    (name: "安静時心拍", value: "58bpm", status: "最適"),
                    (name: "呼吸数", value: "14回/分", status: "最適"),
                    (name: "マインドフルネス時間", value: "10分/日", status: "良好")
                ]
            )
        case "運動能力":
            return (
                name: "運動能力",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "CK", value: "120", unit: "U/L", range: "30-200", status: "最適"),
                    (name: "Mb", value: "45", unit: "ng/mL", range: "20-80", status: "良好"),
                    (name: "LAC", value: "12", unit: "mg/dL", range: "5-20", status: "最適"),
                    (name: "TKB", value: "0.8", unit: "mg/dL", range: "0.2-1.2", status: "良好"),
                    (name: "Ferritin", value: "95", unit: "ng/mL", range: "30-400", status: "最適")
                ],
                healthKit: [
                    (name: "VO2max", value: "48 ml/kg/min", status: "優秀"),
                    (name: "最高心拍", value: "185bpm", status: "最適"),
                    (name: "心拍回復", value: "35bpm/1min", status: "優秀"),
                    (name: "走行ペース", value: "5:20/km", status: "良好"),
                    (name: "トレーニング負荷", value: "適正", status: "最適")
                ]
            )
        case "性的な健康":
            return (
                name: "性的な健康",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "ApoB", value: "85", unit: "mg/dL", range: "<100", status: "最適"),
                    (name: "Lp(a)", value: "18", unit: "mg/dL", range: "<30", status: "最適"),
                    (name: "TG", value: "95", unit: "mg/dL", range: "<150", status: "最適"),
                    (name: "HDL", value: "62", unit: "mg/dL", range: ">40", status: "良好"),
                    (name: "LDL", value: "98", unit: "mg/dL", range: "<100", status: "最適"),
                    (name: "HbA1c", value: "5.3", unit: "%", range: "<5.7", status: "最適"),
                    (name: "CRP", value: "0.05", unit: "mg/dL", range: "<0.3", status: "最適"),
                    (name: "Ferritin", value: "92", unit: "ng/mL", range: "30-400", status: "最適"),
                    (name: "Zn", value: "95", unit: "μg/dL", range: "80-130", status: "良好")
                ],
                healthKit: [
                    (name: "睡眠の質", value: "85%", status: "優秀"),
                    (name: "深睡眠", value: "1h 45m", status: "良好"),
                    (name: "HRV", value: "68ms", status: "優秀"),
                    (name: "体重", value: "72.5kg", status: "最適"),
                    (name: "月経周期", value: "28日", status: "正常範囲")
                ]
            )
        case "心臓の健康":
            return (
                name: "心臓の健康",
                genes: [], // MVP: 遺伝子情報を非表示
                bloodMarkers: [
                    (name: "ApoB", value: "82", unit: "mg/dL", range: "<90", status: "最適"),
                    (name: "Lp(a)", value: "15", unit: "mg/dL", range: "<30", status: "最適"),
                    (name: "TG", value: "85", unit: "mg/dL", range: "<150", status: "最適"),
                    (name: "HDL", value: "68", unit: "mg/dL", range: ">40", status: "優秀"),
                    (name: "LDL", value: "95", unit: "mg/dL", range: "<100", status: "最適"),
                    (name: "HbA1c", value: "5.2", unit: "%", range: "<5.7", status: "最適"),
                    (name: "CRP", value: "0.04", unit: "mg/dL", range: "<0.1", status: "最適")
                ],
                healthKit: [
                    (name: "安静時心拍", value: "58bpm", status: "最適"),
                    (name: "HRV", value: "68ms", status: "優秀"),
                    (name: "血圧", value: "118/75", status: "最適"),
                    (name: "VO2max", value: "42 ml/kg/min", status: "良好"),
                    (name: "有酸素運動時間", value: "150分/週", status: "最適")
                ]
            )
        default:
            // [DUMMY] 他のカテゴリーは空データを返す（必要に応じて追加）
            return (name: category, genes: [], bloodMarkers: [], healthKit: [])
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        // タイトル完全一致で分岐（1文字でも違うと遷移失敗するため注意）
        switch title {
        case "脳の認知機能":
            CognitiveDetailView()
        case "ダイエット":
            MetabolicDetailView()
        case "見た目の健康":
            AppearanceDetailView()
        case "睡眠":
            SleepDetailView()
        case "疲労回復":
            RecoveryDetailView()
        case "肌":
            SkinDetailView()
        case "抗酸化":
            AntioxidantDetailView()
        case "ストレス":
            StressDetailView()
        case "運動能力":
            AthleticDetailView()
        case "性的な健康":
            SexualHealthDetailView()
        case "活力":
            VitalityDetailView()
        case "心臓の健康":
            CardioDetailView()
        case "肝機能":
            LiverDetailView()
        case "生活習慣":
            LifestyleHabitsDetailView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
#endif
