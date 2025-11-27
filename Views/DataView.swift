//
//  DataView.swift
//  AWStest
//
//  DATA画面 - HTML版完全一致

//

import SwiftUI

struct DataView: View {
    @State private var selectedTab: DataTab = .lifestyle
    @StateObject private var bloodTestService = BloodTestService.shared
    @StateObject private var geneDataService = GeneDataService.shared

    // 遺伝子詳細オーバーレイ用の状態管理
    @State private var selectedGeneCategory: GeneCategoryGroup?
    @State private var isGeneDetailExpanded = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()

                // Orb Background Animation
                OrbBackground()

                ScrollView {
                    ScrollViewBackgroundClearer()
                        .frame(height: 0)
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
                        case .gene:
                            GeneTab(onCategorySelected: { category in
                                selectedGeneCategory = category
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isGeneDetailExpanded = true
                                }
                            })
                        }
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.sm)
                }
                .refreshable {
                    if selectedTab == .blood {
                        await bloodTestService.refreshData()
                    } else if selectedTab == .gene {
                        await geneDataService.refreshData()
                    }
                }
                .blur(radius: isGeneDetailExpanded ? 8 : 0)
                .animation(.easeInOut(duration: 0.3), value: isGeneDetailExpanded)
            }
            .navigationTitle("data")
            .floatingChatButton()
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                // 遺伝子詳細オーバーレイ（NavigationView直下で全画面表示）
                if isGeneDetailExpanded, let category = selectedGeneCategory {
                    GeneCategoryDetailOverlay(
                        category: category,
                        isPresented: $isGeneDetailExpanded
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isGeneDetailExpanded)
        }
    }
}

// MARK: - Data Tab Enum

enum DataTab: String, CaseIterable, Identifiable {
    case lifestyle = "LIFESTYLE"
    case blood = "BLOOD"
    case gene = "GENE"
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
    @StateObject private var bloodTestService = BloodTestService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // BLOOD BIOMARKERSとスコア表示を非表示
            // HStack {
            //     Text("BLOOD BIOMARKERS")
            //         .font(.system(size: 9, weight: .semibold))
            //         .foregroundColor(.gray)
            //     Spacer()
            //     Text("87") // [DUMMY] 仮スコア値
            //         .font(.system(size: 20, weight: .bold))
            //         .foregroundColor(Color(hex: "#00C853"))
            // }
            // .padding(.bottom, VirgilSpacing.sm)

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
            .liquidGlassCard()

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
    @StateObject private var lifestyleScoreService = LifestyleScoreService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("LIFESTYLE SCORES")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)

            VStack(spacing: VirgilSpacing.sm) {
                LifeScoreCard(emoji: "⚡️", title: "ダイエット", score: getScore(for: .diet))
                LifeScoreCard(emoji: "😴", title: "睡眠", score: getScore(for: .sleep))
                LifeScoreCard(emoji: "💪", title: "疲労回復", score: getScore(for: .recovery))
                LifeScoreCard(emoji: "🏃", title: "運動能力", score: getScore(for: .performance))
                LifeScoreCard(emoji: "🧘", title: "ストレス", score: getScore(for: .stress))
                LifeScoreCard(emoji: "🛡️", title: "抗酸化", score: getScore(for: .antioxidant))
                LifeScoreCard(emoji: "🧠", title: "脳の認知機能", score: getScore(for: .cognition))
                LifeScoreCard(emoji: "✨", title: "見た目の健康", score: getScore(for: .appearance))
                LifeScoreCard(emoji: "🌸", title: "肌", score: getScore(for: .skin))
                LifeScoreCard(emoji: "❤️", title: "性的な健康", score: getScore(for: .sexual))
                LifeScoreCard(emoji: "⚡", title: "活力", score: getScore(for: .vitality))
                LifeScoreCard(emoji: "❤️‍🩹", title: "心臓の健康", score: getScore(for: .heart))
                LifeScoreCard(emoji: "🫘", title: "肝機能", score: getScore(for: .liver))
                LifeScoreCard(emoji: "📊", title: "生活習慣", score: getScore(for: .lifestyle))
            }
        }
        .task {
            // 初回表示時にスコア計算
            if lifestyleScoreService.categoryScores.isEmpty {
                await lifestyleScoreService.calculateAllScores()
            }
        }
    }

    /// カテゴリーIDからスコアを取得（デフォルト値50）
    private func getScore(for categoryId: CategoryId) -> Int {
        return lifestyleScoreService.getScore(for: categoryId) ?? 50
    }
}

// MARK: - Gene Tab

private struct GeneTab: View {
    @StateObject private var geneDataService = GeneDataService.shared
    var onCategorySelected: ((GeneCategoryGroup) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            GeneDataView(onCategorySelected: onCategorySelected)
        }
        .task {
            // 初回表示時にデータ取得
            if geneDataService.geneData == nil && !geneDataService.isLoading {
                await geneDataService.fetchGeneData()
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

    /// カテゴリー名からデータを取得（実データ）
    private func getCategoryData(for category: String) -> (
        name: String,
        genes: [(name: String, variant: String, risk: String, description: String)],
        bloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)],
        healthKit: [(name: String, value: String, status: String)]
    ) {
        // カテゴリー名からCategoryIdを取得
        let categoryId = getCategoryId(from: category)

        // BloodTestServiceから血液検査データを取得
        let bloodTestService = BloodTestService.shared
        guard let bloodData = bloodTestService.bloodData else {
            // データがない場合は空を返す
            return (name: category, genes: [], bloodMarkers: [], healthKit: [])
        }

        // このカテゴリーで使用するマーカーのリストを取得
        let relevantMarkers = getRelevantMarkers(for: categoryId)

        // 血液検査データからこのカテゴリーで使用するマーカーのみを抽出
        let bloodMarkers = bloodData.bloodItems
            .filter { item in
                relevantMarkers.contains(where: { markerKey in
                    item.key.lowercased() == markerKey.lowercased() ||
                    item.key.replacingOccurrences(of: "-", with: "").lowercased() == markerKey.lowercased()
                })
            }
            .map { item in
                (name: item.nameJp, value: item.value, unit: item.unit, range: item.reference, status: item.status)
            }

        return (
            name: category,
            genes: [], // MVP: 遺伝子情報を非表示
            bloodMarkers: bloodMarkers,
            healthKit: [] // MVP: HealthKit項目を非表示
        )
    }

    /// カテゴリー名からCategoryIdに変換
    private func getCategoryId(from categoryName: String) -> CategoryId? {
        switch categoryName {
        case "ダイエット":
            return .diet
        case "睡眠":
            return .sleep
        case "疲労回復":
            return .recovery
        case "運動能力":
            return .performance
        case "ストレス":
            return .stress
        case "抗酸化":
            return .antioxidant
        case "脳の認知機能":
            return .cognition
        case "見た目の健康":
            return .appearance
        case "肌":
            return .skin
        case "性的な健康":
            return .sexual
        case "活力":
            return .vitality
        case "心臓の健康":
            return .heart
        case "肝機能":
            return .liver
        case "生活習慣":
            return .lifestyle
        default:
            return nil
        }
    }

    /// CategoryIdから使用するマーカーのキーリストを取得
    /// BloodScoring.swiftのcategoryDefinitionsで定義された重みから抽出
    private func getRelevantMarkers(for categoryId: CategoryId?) -> [String] {
        guard let categoryId = categoryId else {
            return []
        }

        // BloodScoring.swiftのcategoryDefinitionsから対応するカテゴリーを取得
        guard let definition = categoryDefinitions.first(where: { $0.id == categoryId }) else {
            return []
        }

        // 重みで定義されているマーカーのキーを抽出
        let markerKeys = definition.weights.keys.map { markerId -> [String] in
            // MarkerIdをBloodTestServiceのキーに変換（複数の表記をサポート）
            switch markerId {
            case .AST:
                return ["AST"]
            case .ALT:
                return ["ALT"]
            case .GGT:
                return ["GGT", "γ-GTP"]
            case .ALP:
                return ["ALP"]
            case .HbA1c:
                return ["HbA1c"]
            case .TG:
                return ["TG"]
            case .HDL:
                return ["HDL"]
            case .LDL:
                return ["LDL"]
            case .TCHO:
                return ["TC", "TCHO", "T-Cho"]
            case .Fe:
                return ["Fe"]
            case .UIBC:
                return ["UIBC"]
            case .Ferritin:
                return ["Ferritin", "ferritin"]
            case .BUN:
                return ["BUN"]
            case .Cre:
                return ["Cre", "CRE"]
            case .UA:
                return ["UA"]
            case .TP:
                return ["TP"]
            case .Alb:
                return ["Alb", "ALB"]
            case .pAlb:
                return ["pAlb", "PreAlb"]
            case .CRP:
                return ["CRP"]
            case .CK:
                return ["CK", "CPK"]
            case .Mg:
                return ["Mg", "MG"]
            case .TBil:
                return ["T-Bil", "TBil", "TBIL"]
            case .DBil:
                return ["D-Bil", "DBil", "DBIL"]
            }
        }

        return markerKeys.flatMap { $0 }
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
