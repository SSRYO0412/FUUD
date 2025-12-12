//
//  ProgramRecommender.swift
//  FUUD
//
//  プログラム推薦サービス
//  Phase 6: ユーザーの遺伝子・血液・ライフスタイル情報からおすすめプログラムを算出
//

import Foundation

// MARK: - ProgramRecommender

/// プログラム推薦サービス
@MainActor
final class ProgramRecommender: ObservableObject {
    static let shared = ProgramRecommender()

    // MARK: - Dependencies

    private let bloodService = BloodTestService.shared
    private let geneService = GeneDataService.shared
    private let weightLogService = WeightLogService.shared

    // MARK: - Published Properties

    @Published var recommendations: RecommendationResult?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Catalog

    private var catalog: [DietProgram] {
        DietProgramCatalog.programs
    }

    private init() {}

    // MARK: - Public Methods

    /// 推薦を計算して結果を返す
    func calculateRecommendations() async {
        isLoading = true
        errorMessage = nil

        // UserTraitsを構築
        let traits = await buildUserTraits()

        // Baseプログラムをスコアリング
        let basePrograms = catalog.filter { $0.layer == .base }
        var scoredPrograms: [ProgramRecommendation] = []

        for program in basePrograms {
            let (score, reasons) = scoreProgram(program, traits: traits)
            // 禁忌に該当しない（score > -500）プログラムのみ追加
            if score > -500 {
                scoredPrograms.append(ProgramRecommendation(
                    program: program,
                    score: score,
                    reasons: reasons
                ))
            }
        }

        // スコア順にソートしてTOP3を抽出
        scoredPrograms.sort { $0.score > $1.score }
        let top3 = Array(scoredPrograms.prefix(3))

        // Calibrationプログラムを取得
        let calibration = catalog.first { $0.layer == .calibration }

        // 結果を設定
        recommendations = RecommendationResult(
            topRecommendations: top3,
            calibrationProgram: calibration,
            traits: traits
        )

        isLoading = false

        // ログ出力
        print("🎯 ProgramRecommender: 推薦計算完了")
        for (index, rec) in top3.enumerated() {
            print("   #\(index + 1): \(rec.program.nameJa) (score: \(rec.score))")
            for reason in rec.reasons.prefix(3) {
                print("      - \(reason.rawValue)")
            }
        }
    }

    // MARK: - Build User Traits

    /// 各サービスからUserTraitsを構築
    func buildUserTraits() async -> UserTraits {
        // 並列でデータ取得
        async let geneTask: () = fetchGeneDataIfNeeded()
        async let bloodTask: () = fetchBloodDataIfNeeded()
        async let goalTask: () = fetchGoalIfNeeded()

        _ = await (geneTask, bloodTask, goalTask)

        // Gene Profile
        let geneProfile = buildGeneProfile()

        // Blood Profile
        let bloodProfile = buildBloodProfile()

        // Lifestyle Profile
        let lifestyleProfile = buildLifestyleProfile()

        return UserTraits(
            gene: geneProfile,
            blood: bloodProfile,
            lifestyle: lifestyleProfile
        )
    }

    // MARK: - Data Fetching

    private func fetchGeneDataIfNeeded() async {
        if geneService.geneData == nil {
            await geneService.fetchGeneData()
        }
    }

    private func fetchBloodDataIfNeeded() async {
        if bloodService.bloodData == nil {
            await bloodService.fetchBloodTestData()
        }
    }

    private func fetchGoalIfNeeded() async {
        if weightLogService.userGoal == nil {
            await weightLogService.fetchUserGoal()
        }
    }

    // MARK: - Build Profiles

    private func buildGeneProfile() -> UserTraits.GeneProfile {
        guard let geneData = geneService.geneData else {
            return .unknown
        }

        // YourTraitsViewModelと同様のロジックでカテゴリスコアを計算
        var carbScore = 0
        var fatOxidationScore = 0
        var proteinScore = 0
        var lipidScore = 0

        for category in GeneTraitCategory.categories {
            let score = calculateCategoryScore(category: category, geneData: geneData)
            switch category.id {
            case "carbMetabolism":
                carbScore = score
            case "fatBurning":
                fatOxidationScore = score
            case "proteinResponse":
                proteinScore = score
            case "lipidMetabolism":
                lipidScore = score
            default:
                break
            }
        }

        return UserTraits.GeneProfile(
            carbMetabolism: scoreToLevel(carbScore),
            fatOxidation: scoreToLevel(fatOxidationScore),
            proteinResponse: scoreToLevel(proteinScore),
            lipidMetabolism: scoreToLevel(lipidScore)
        )
    }

    private func calculateCategoryScore(category: GeneTraitCategory, geneData: GeneDataService.GeneData) -> Int {
        var totalScore = 0
        var matchedCount = 0

        for (_, markers) in geneData.geneticMarkersWithGenotypes {
            for marker in markers {
                let isMatch = category.markerTitles.contains { targetTitle in
                    marker.title.contains(targetTitle) || targetTitle.contains(marker.title)
                }

                if isMatch, let impact = marker.cachedImpact {
                    totalScore += impact.score
                    matchedCount += 1
                }
            }
        }

        guard matchedCount > 0 else { return 0 }
        return totalScore / matchedCount
    }

    private func scoreToLevel(_ score: Int) -> UserTraits.GeneProfile.Level {
        if score >= 10 {
            return .good
        } else if score >= -10 {
            return .caution
        } else {
            return .poor
        }
    }

    private func buildBloodProfile() -> UserTraits.BloodProfile {
        guard let bloodData = bloodService.bloodData else {
            return .empty
        }

        var statusMap: [String: String] = [:]
        for item in bloodData.bloodItems {
            statusMap[item.key] = item.status
        }

        return UserTraits.BloodProfile(
            hba1c: Double(bloodService.findBloodItem(by: "HbA1c")?.value ?? ""),
            tg: Double(bloodService.findBloodItem(by: "TG")?.value ?? ""),
            hdl: Double(bloodService.findBloodItem(by: "HDL")?.value ?? ""),
            ldl: Double(bloodService.findBloodItem(by: "LDL")?.value ?? ""),
            alt: Double(bloodService.findBloodItem(by: "ALT")?.value ?? ""),
            gammaGtp: Double(bloodService.findBloodItem(by: "gamma_gtp")?.value ?? ""),
            crp: Double(bloodService.findBloodItem(by: "CRP")?.value ?? ""),
            ua: Double(bloodService.findBloodItem(by: "UA")?.value ?? ""),
            ferritin: Double(bloodService.findBloodItem(by: "Ferritin")?.value ?? ""),
            statusMap: statusMap
        )
    }

    private func buildLifestyleProfile() -> UserTraits.LifestyleProfile {
        let goal: GoalType
        if let goalString = weightLogService.userGoal?.goalType {
            goal = GoalType(rawValue: goalString) ?? .lose
        } else {
            goal = .lose
        }

        let weeklyRate = weightLogService.userGoal?.weeklyRate

        // 現状はオンボーディングデータがないため、デフォルト値を使用
        return .defaultProfile(goal: goal, weeklyRate: weeklyRate)
    }

    // MARK: - Scoring Logic

    /// プログラムをスコアリング
    private func scoreProgram(_ program: DietProgram, traits: UserTraits) -> (score: Int, reasons: [ProgramRecommendationReason]) {
        var score = 0
        var reasons: [ProgramRecommendationReason] = []

        // 1. 目標マッチ
        if program.targetGoal == traits.lifestyle.goal {
            score += 20
            reasons.append(.goalMatch)
        }

        // 2. ペースマッチ（deficitIntensityと週ペースの近さ）
        if let weeklyRate = traits.lifestyle.weeklyRateKg {
            let expectedDeficit = abs(weeklyRate) / 7.0 * 1000 / 7700 // 概算
            let diff = abs(program.deficitIntensity - expectedDeficit)
            if diff < 0.05 {
                score += 15
                reasons.append(.paceMatch)
            }
        }

        // 3. 血液フィット
        score += scoreBloodFit(program: program, blood: traits.blood, reasons: &reasons)

        // 4. 遺伝子フィット
        score += scoreGeneFit(program: program, gene: traits.gene, reasons: &reasons)

        // 5. ライフスタイルフィット
        score += scoreLifestyleFit(program: program, lifestyle: traits.lifestyle, reasons: &reasons)

        // 6. 禁忌チェック（大幅減点）
        score += checkContraindications(program: program, traits: traits)

        return (score, reasons)
    }

    // MARK: - Blood Fit Scoring

    private func scoreBloodFit(program: DietProgram, blood: UserTraits.BloodProfile, reasons: inout [ProgramRecommendationReason]) -> Int {
        var score = 0
        let id = program.id

        // HbA1c高め → insulin-control, sugar-detox, low-carb系に加点
        if blood.isHbA1cHigh {
            let hbA1cBoostTargets = ["insulin-control", "sugar-detox", "low-carb-28", "ketogenic-strict", "keto-burn"]
            if hbA1cBoostTargets.contains(id) {
                score += 30
                reasons.append(.highHbA1c)
            }
        }

        // TG高め → mediterranean, clean-eating, balanced系に加点
        if blood.isTGHigh {
            let tgBoostTargets = ["mediterranean", "clean-eating", "balanced-diet", "lifesum-standard", "metabolic-reset"]
            if tgBoostTargets.contains(id) {
                score += 25
                reasons.append(.highTG)
            }
        }

        // LDL高め → mediterranean, anti-inflammatory系に加点
        if blood.isLDLHigh {
            let ldlBoostTargets = ["mediterranean", "anti-inflammatory", "clean-eating"]
            if ldlBoostTargets.contains(id) {
                score += 25
                reasons.append(.highLDL)
            }
        }

        // CRP高め → anti-inflammatory, gut-reset に加点
        if blood.isCRPElevated {
            let crpBoostTargets = ["anti-inflammatory", "gut-reset", "clean-eating"]
            if crpBoostTargets.contains(id) {
                score += 25
                reasons.append(.elevatedCRP)
            }
        }

        // Ferritin低め → balanced系に加点、FASTING系は減点
        if blood.isFerritinLow {
            let ferritinBoostTargets = ["balanced-diet", "lifesum-standard", "mediterranean", "vitality"]
            if ferritinBoostTargets.contains(id) {
                score += 10
                reasons.append(.lowFerritin)
            }
            // ファスティング系は減点
            if program.category == .fasting {
                score -= 30
            }
        }

        return score
    }

    // MARK: - Gene Fit Scoring

    private func scoreGeneFit(program: DietProgram, gene: UserTraits.GeneProfile, reasons: inout [ProgramRecommendationReason]) -> Int {
        var score = 0
        let id = program.id

        // 糖質代謝 poor → low-carb, insulin-control, keto系に加点
        if gene.carbMetabolism == .poor {
            let carbPoorTargets = ["low-carb-28", "insulin-control", "ketogenic-strict", "keto-burn", "sugar-detox"]
            if carbPoorTargets.contains(id) {
                score += 25
                reasons.append(.poorCarbMetabolismGene)
            }
        }

        // 糖質代謝 good → balanced, runners-diet に加点
        if gene.carbMetabolism == .good {
            let carbGoodTargets = ["balanced-diet", "runners-diet", "mediterranean", "lifesum-standard"]
            if carbGoodTargets.contains(id) {
                score += 10
                reasons.append(.goodCarbMetabolismGene)
            }
        }

        // 脂質代謝 poor → keto系は減点
        if gene.lipidMetabolism == .poor {
            let ketoTargets = ["ketogenic-strict", "keto-burn"]
            if ketoTargets.contains(id) {
                score -= 20
                reasons.append(.poorFatMetabolismGene)
            }
        }

        // 脂肪燃焼 good → metabolic-reset, turbo-carb-cycling に加点
        if gene.fatOxidation == .good {
            let fatOxidationTargets = ["metabolic-reset", "turbo-carb-cycling", "high-protein"]
            if fatOxidationTargets.contains(id) {
                score += 15
                reasons.append(.goodFatOxidationGene)
            }
        }

        // タンパク質応答 good → high-protein, eat-lift-repeat に加点
        if gene.proteinResponse == .good {
            let proteinTargets = ["high-protein", "eat-lift-repeat", "protein-weight-loss", "paleo"]
            if proteinTargets.contains(id) {
                score += 20
                reasons.append(.goodProteinResponseGene)
            }
        }

        return score
    }

    // MARK: - Lifestyle Fit Scoring

    private func scoreLifestyleFit(program: DietProgram, lifestyle: UserTraits.LifestyleProfile, reasons: inout [ProgramRecommendationReason]) -> Int {
        var score = 0
        let id = program.id

        // 運動スタイル
        switch lifestyle.trainingStyle {
        case .cardio:
            let cardioTargets = ["runners-diet", "turbo-carb-cycling", "mediterranean"]
            if cardioTargets.contains(id) {
                score += 20
                reasons.append(.runnerLifestyle)
            }
        case .strength, .both:
            let strengthTargets = ["high-protein", "eat-lift-repeat", "protein-weight-loss", "paleo"]
            if strengthTargets.contains(id) {
                score += 20
                reasons.append(.strengthLifestyle)
            }
        case .none:
            // 初心者向けプログラムに加点
            if program.difficulty == .beginner {
                score += 10
                reasons.append(.lowStressApproachPreferred)
            }
        }

        // 断食嗜好
        switch lifestyle.fastingPreference {
        case .ok:
            // ファスティング系は候補に含める（減点しない）
            if program.category == .fasting {
                score += 10
                reasons.append(.fastingPreferred)
            }
        case .notPreferred, .no:
            // ファスティング系は減点
            if program.category == .fasting || !program.canStackWithFasting {
                score -= 50
                reasons.append(.fastingNotPreferred)
            }
        }

        // Vegan嗜好
        if lifestyle.dietPreference == .vegan {
            if id == "vegan-for-a-week" {
                score += 30
            }
            // 肉系プログラムは減点
            let meatHeavyTargets = ["paleo", "high-protein", "eat-lift-repeat"]
            if meatHeavyTargets.contains(id) {
                score -= 40
            }
        }

        return score
    }

    // MARK: - Contraindication Check

    private func checkContraindications(program: DietProgram, traits: UserTraits) -> Int {
        var score = 0

        // プログラムの禁忌条件をチェック
        for contraindication in program.contraindications {
            // 現状はconditionベースの簡易チェック
            // 将来的にはユーザーの健康状態との照合が必要
            if contraindication.severity == .prohibited {
                // 禁忌に該当する場合は大幅減点（除外扱い）
                // 今回は健康状態データがないため、この部分は将来拡張
            }
        }

        // Ferritin低めでファスティング系は減点
        if traits.blood.isFerritinLow && program.category == .fasting {
            score -= 100
        }

        return score
    }
}
