//
//  YourTraitsViewModel.swift
//  FUUD
//
//  Your Traits セクション用のViewModel
//

import Foundation
import Combine

@MainActor
class YourTraitsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var traitsData: YourTraitsData = .empty
    @Published var isLoading = false
    @Published var errorMessage = ""

    // MARK: - Services

    private let geneDataService = GeneDataService.shared
    private let bloodTestService = BloodTestService.shared
    private let weightLogService = WeightLogService.shared
    private let healthProfileService = HealthProfileService.shared

    // MARK: - Initialization

    init() {}

    // MARK: - Data Loading

    /// 全てのTraitsデータを読み込む
    func loadAllTraits() async {
        isLoading = true
        errorMessage = ""

        // 並列でデータ取得
        async let geneTask: () = loadGeneTraits()
        async let bloodTask: () = loadBloodSummary()
        async let weightTask: () = loadWeightGoal()

        _ = await (geneTask, bloodTask, weightTask)

        isLoading = false
    }

    // MARK: - Gene Traits Loading

    private func loadGeneTraits() async {
        // データがなければAPIから取得
        if geneDataService.geneData == nil {
            await geneDataService.fetchGeneData()
        }

        guard let geneData = geneDataService.geneData else {
            print("🧬 YourTraits: 遺伝子データなし")
            return
        }

        var results: [GeneTraitResult] = []

        for category in GeneTraitCategory.categories {
            let score = calculateCategoryScore(category: category, geneData: geneData)
            let result = GeneTraitResult.evaluate(category: category, score: score)
            results.append(result)
        }

        traitsData.geneTraits = results
        print("🧬 YourTraits: 遺伝子トレイト \(results.count)カテゴリ計算完了")
    }

    /// カテゴリに対応するマーカーのスコア平均を計算
    private func calculateCategoryScore(category: GeneTraitCategory, geneData: GeneDataService.GeneData) -> Int {
        var totalScore = 0
        var matchedCount = 0

        // 全カテゴリを検索して、マッチするマーカーを探す
        for (_, markers) in geneData.geneticMarkersWithGenotypes {
            for marker in markers {
                // マーカータイトルがカテゴリの対象リストに含まれているか
                // 部分一致で検索（「中性脂肪（血中濃度）」と「中性脂肪」など）
                let isMatch = category.markerTitles.contains { targetTitle in
                    marker.title.contains(targetTitle) || targetTitle.contains(marker.title)
                }

                if isMatch, let impact = marker.cachedImpact {
                    totalScore += impact.score
                    matchedCount += 1
                }
            }
        }

        guard matchedCount > 0 else {
            print("🧬 YourTraits: カテゴリ[\(category.name)]に対応するマーカーが見つかりません")
            return 0
        }

        let averageScore = totalScore / matchedCount
        print("🧬 YourTraits: カテゴリ[\(category.name)] マッチ数=\(matchedCount) 平均スコア=\(averageScore)")
        return averageScore
    }

    // MARK: - Blood Summary Loading

    private func loadBloodSummary() async {
        // データがなければAPIから取得
        if bloodTestService.bloodData == nil {
            await bloodTestService.fetchBloodTestData()
        }

        guard let bloodData = bloodTestService.bloodData else {
            print("🩸 YourTraits: 血液検査データなし")
            return
        }

        // 対象項目をフィルタリング
        let targetItems = bloodData.bloodItems.filter { item in
            BloodTestSummary.targetKeys.contains(item.key)
        }

        guard !targetItems.isEmpty else {
            print("🩸 YourTraits: 対象の血液検査項目なし")
            return
        }

        // 集計
        var normalCount = 0
        var cautionCount = 0
        var abnormalCount = 0
        var highlightItems: [BloodTestSummary.BloodHighlightItem] = []

        for item in targetItems {
            let isNormal = ["正常", "normal"].contains(item.status.lowercased())
            let isCaution = ["注意", "caution", "要注意"].contains(item.status.lowercased())

            if isNormal {
                normalCount += 1
            } else if isCaution {
                cautionCount += 1
            } else {
                abnormalCount += 1
            }

            // ハイライト項目を作成（異常/注意を先に、正常を後に）
            highlightItems.append(BloodTestSummary.BloodHighlightItem(
                key: item.key,
                nameJp: BloodTestSummary.displayName(for: item.key),
                status: item.status,
                isNormal: isNormal
            ))
        }

        // 異常/注意を先に表示するようソート
        highlightItems.sort { !$0.isNormal && $1.isNormal }

        let summary = BloodTestSummary(
            totalCount: targetItems.count,
            normalCount: normalCount,
            cautionCount: cautionCount,
            abnormalCount: abnormalCount,
            highlightItems: highlightItems,
            isAllNormal: cautionCount == 0 && abnormalCount == 0
        )

        traitsData.bloodSummary = summary
        print("🩸 YourTraits: 血液サマリー 全\(targetItems.count)項目 (正常:\(normalCount) 注意:\(cautionCount) 異常:\(abnormalCount))")
    }

    // MARK: - Weight Goal Loading

    private func loadWeightGoal() async {
        // データがなければAPIから取得
        if weightLogService.currentWeight == nil {
            await weightLogService.fetchWeightHistory()
        }
        if weightLogService.userGoal == nil {
            await weightLogService.fetchUserGoal()
        }

        // WeightLogServiceから取得を試みる
        var currentWeight: Double? = nil
        var targetWeight: Double? = nil
        var goalTypeString: String? = nil

        // WeightLogServiceの最新体重
        if let latestWeight = weightLogService.currentWeight {
            currentWeight = latestWeight
        }

        // WeightLogServiceの目標
        if let goal = weightLogService.userGoal {
            targetWeight = goal.targetWeight
            goalTypeString = goal.goalType
        }

        // HealthProfileServiceからも試みる（フォールバック）
        if currentWeight == nil || targetWeight == nil {
            do {
                if let profile = try await healthProfileService.getProfile() {
                    if currentWeight == nil, let weight = profile.sections.physical?.weight {
                        currentWeight = weight
                    }
                    if targetWeight == nil, let target = profile.sections.goals?.targetWeight {
                        targetWeight = target
                    }
                }
            } catch {
                print("⚖️ YourTraits: HealthProfileからの取得に失敗: \(error.localizedDescription)")
            }
        }

        let weightGoal = WeightGoalInfo.create(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            goalTypeString: goalTypeString
        )

        traitsData.weightGoal = weightGoal
        print("⚖️ YourTraits: 体重目標 現在=\(currentWeight ?? 0)kg 目標=\(targetWeight ?? 0)kg タイプ=\(weightGoal.goalType.displayName)")
    }

    // MARK: - Refresh

    /// データを再読み込み
    func refresh() async {
        await loadAllTraits()
    }
}
