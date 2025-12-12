//
//  NutritionPersonalizer.swift
//  FUUD
//
//  血液・遺伝子データに基づく栄養パーソナライズサービス
//
//  設計思想:
//  - TDEE = エンジン（熱力学の逆算、Lambda側で実装済み）
//  - 血液 = 現実の今（代謝・糖脂質リスクを見てカロリーとPFCの"傾き"を変える）
//  - 遺伝子 = 生まれ持った傾き（微調整＋"こういう体質かも"の情報）
//

import Foundation

// MARK: - Data Models

/// カロリー調整結果
struct CalorieAdjustment {
    let baseTDEE: Int                    // Lambda から取得したTDEE
    let baseTarget: Int                  // Lambda から取得した目標カロリー
    let bmr: Int                         // 基礎代謝量（下限）
    let adjustedTarget: Int              // 血液・遺伝子で調整後の目標
    let adjustmentPercent: Double        // 血液による調整率 (-20% ~ +10%)
    let geneKcalDelta: Int               // 遺伝子による絶対値調整
    let reasons: [AdjustmentReason]      // 調整理由
    let confidence: String               // high/medium/low
    let goalType: String                 // lose/maintain/gain
}

/// 調整理由
enum AdjustmentReason: Identifiable {
    // 血液由来
    case highHbA1c(value: Double)        // HbA1c > 6.0
    case veryHighHbA1c(value: Double)    // HbA1c > 6.5
    case highTG(value: Double)           // TG > 150
    case veryHighTG(value: Double)       // TG > 300
    case highLDL(value: Double)          // LDL > 140
    case lowTSH(value: Double)           // TSH < 0.5
    case highTSH(value: Double)          // TSH > 4.0
    case highCreatinine(value: Double)   // CRE > 1.2

    // 遺伝子由来
    case geneDietNeedsSupport            // ダイエット遺伝子: 要サポート型
    case geneBasalMetabolismLow          // 基礎代謝: 低い
    case geneInsulinResistanceLow        // インスリン抵抗性: 低い
    case geneHighProteinEffective        // 高たんぱくダイエット効果: 高い
    case geneHighFatIneffective          // 高脂肪ダイエット効果: 低い

    var id: String {
        switch self {
        case .highHbA1c: return "highHbA1c"
        case .veryHighHbA1c: return "veryHighHbA1c"
        case .highTG: return "highTG"
        case .veryHighTG: return "veryHighTG"
        case .highLDL: return "highLDL"
        case .lowTSH: return "lowTSH"
        case .highTSH: return "highTSH"
        case .highCreatinine: return "highCreatinine"
        case .geneDietNeedsSupport: return "geneDietNeedsSupport"
        case .geneBasalMetabolismLow: return "geneBasalMetabolismLow"
        case .geneInsulinResistanceLow: return "geneInsulinResistanceLow"
        case .geneHighProteinEffective: return "geneHighProteinEffective"
        case .geneHighFatIneffective: return "geneHighFatIneffective"
        }
    }

    /// UI表示用テキスト（調整の説明）
    var displayText: String {
        switch self {
        case .highHbA1c(let value):
            return "HbA1c \(String(format: "%.1f", value))%（やや高め）"
        case .veryHighHbA1c(let value):
            return "HbA1c \(String(format: "%.1f", value))%（高め）"
        case .highTG(let value):
            return "中性脂肪 \(Int(value))mg/dL（やや高め）"
        case .veryHighTG(let value):
            return "中性脂肪 \(Int(value))mg/dL（高め）"
        case .highLDL(let value):
            return "LDL \(Int(value))mg/dL（やや高め）"
        case .lowTSH(let value):
            return "TSH \(String(format: "%.2f", value))（低め・代謝亢進傾向）"
        case .highTSH(let value):
            return "TSH \(String(format: "%.2f", value))（高め・代謝低下傾向）"
        case .highCreatinine(let value):
            return "クレアチニン \(String(format: "%.2f", value))mg/dL（やや高め）"
        case .geneDietNeedsSupport:
            return "代謝サポートが効果的な体質"
        case .geneBasalMetabolismLow:
            return "基礎代謝がやや低めの傾向"
        case .geneInsulinResistanceLow:
            return "糖質コントロールが効果的な体質"
        case .geneHighProteinEffective:
            return "高タンパクが効果的な体質"
        case .geneHighFatIneffective:
            return "低脂質が効果的な体質"
        }
    }

    /// 調整内容の説明
    var adjustmentText: String {
        switch self {
        case .highHbA1c:
            return "カロリー-5%、糖質控えめに"
        case .veryHighHbA1c:
            return "カロリー-10%、糖質控えめに"
        case .highTG:
            return "カロリー-5%、脂質控えめに"
        case .veryHighTG:
            return "カロリー-10%、脂質控えめに"
        case .highLDL:
            return "カロリー-5%、脂質控えめに"
        case .lowTSH:
            return "カロリー-10%"
        case .highTSH:
            return "カロリー+5%"
        case .highCreatinine:
            return "タンパク質控えめに"
        case .geneDietNeedsSupport:
            return "カロリー-5%、糖質控えめに"
        case .geneBasalMetabolismLow:
            return "カロリー-30kcal"
        case .geneInsulinResistanceLow:
            return "糖質-5%"
        case .geneHighProteinEffective:
            return "タンパク質+3%"
        case .geneHighFatIneffective:
            return "脂質-3%"
        }
    }

    /// 血液由来かどうか
    var isBloodBased: Bool {
        switch self {
        case .highHbA1c, .veryHighHbA1c, .highTG, .veryHighTG,
             .highLDL, .lowTSH, .highTSH, .highCreatinine:
            return true
        default:
            return false
        }
    }
}

/// PFCバランス
struct PFCBalance {
    let protein: Double    // タンパク質 % (default: 20%)
    let fat: Double        // 脂質 % (default: 25%)
    let carbs: Double      // 糖質 % (default: 55%)

    static let `default` = PFCBalance(protein: 20, fat: 25, carbs: 55)

    /// タンパク質のグラム計算（4kcal/g）
    func proteinGrams(for calories: Int) -> Int {
        Int(Double(calories) * protein / 100 / 4)
    }

    /// 脂質のグラム計算（9kcal/g）
    func fatGrams(for calories: Int) -> Int {
        Int(Double(calories) * fat / 100 / 9)
    }

    /// 糖質のグラム計算（4kcal/g）
    func carbsGrams(for calories: Int) -> Int {
        Int(Double(calories) * carbs / 100 / 4)
    }
}

// MARK: - TDEE API Response

/// TDEE API レスポンス
struct TDEEResponse: Codable {
    let success: Bool
    let data: TDEEData?
    let error: String?
}

struct TDEEData: Codable {
    let currentTdee: Int
    let targetCalories: Int
    let bmr: Int
    let confidence: String
    let goalType: String
    let weeklyRate: Double

    enum CodingKeys: String, CodingKey {
        case currentTdee = "current_tdee"
        case targetCalories = "target_calories"
        case bmr
        case confidence
        case goalType = "goal_type"
        case weeklyRate = "weekly_rate"
    }
}

// MARK: - NutritionPersonalizer Service

/// 栄養パーソナライズサービス
class NutritionPersonalizer: ObservableObject {
    static let shared = NutritionPersonalizer()

    // MARK: - Published Properties

    @Published var adjustedCalories: CalorieAdjustment?
    @Published var pfcBalance: PFCBalance = .default
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let bloodService = BloodTestService.shared
    private let geneService = GeneDataService.shared

    private init() {}

    // MARK: - Main Calculation

    /// TDEE取得 + 血液・遺伝子パーソナライズを実行
    func calculatePersonalization() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            // Step 1: TDEE API から現在値取得
            let tdeeData = try await fetchTDEE()

            // Step 2-3: 血液・遺伝子データは既にロード済みを想定
            // （HomeView等で事前にfetchされている）

            // Step 4: 血液ルール適用（%調整）
            let bloodAdjustment = calculateBloodAdjustment()

            // Step 5: 遺伝子ルール適用（kcal微調整）
            let geneAdjustment = calculateGeneAdjustment()

            // カロリー調整計算
            // percentTotal = min(max(bloodPercent, -0.20), 0.10)
            let percentTotal = min(max(bloodAdjustment.percent, -0.20), 0.10)
            var adjustedTarget = Int(Double(tdeeData.targetCalories) * (1 + percentTotal))
            adjustedTarget += geneAdjustment.kcal
            adjustedTarget = max(adjustedTarget, tdeeData.bmr) // BMR下限でクリップ

            // 調整理由を統合
            var allReasons = bloodAdjustment.reasons
            allReasons.append(contentsOf: geneAdjustment.reasons)

            // Step 6: PFC計算
            let bloodPFC = calculateBloodPFCAdjustment()
            let genePFC = calculateGenePFCAdjustment()

            // PFC合算 + 正規化
            let finalPFC = normalizePFC(
                proteinDelta: bloodPFC.protein + genePFC.protein,
                fatDelta: bloodPFC.fat + genePFC.fat,
                carbsDelta: bloodPFC.carbs + genePFC.carbs
            )

            // Step 7: 結果をセット
            await MainActor.run {
                self.adjustedCalories = CalorieAdjustment(
                    baseTDEE: tdeeData.currentTdee,
                    baseTarget: tdeeData.targetCalories,
                    bmr: tdeeData.bmr,
                    adjustedTarget: adjustedTarget,
                    adjustmentPercent: percentTotal,
                    geneKcalDelta: geneAdjustment.kcal,
                    reasons: allReasons,
                    confidence: tdeeData.confidence,
                    goalType: tdeeData.goalType
                )
                self.pfcBalance = finalPFC
                self.isLoading = false
                print("🥗 NutritionPersonalizer: パーソナライズ完了")
                print("   基礎TDEE: \(tdeeData.currentTdee)kcal")
                print("   目標カロリー: \(tdeeData.targetCalories)kcal → \(adjustedTarget)kcal")
                print("   調整率: \(String(format: "%.1f", percentTotal * 100))%")
                print("   PFC: P\(String(format: "%.0f", finalPFC.protein))% / F\(String(format: "%.0f", finalPFC.fat))% / C\(String(format: "%.0f", finalPFC.carbs))%")
            }

        } catch {
            await MainActor.run {
                self.errorMessage = "データの取得に失敗しました"
                self.isLoading = false
                print("🥗 NutritionPersonalizer Error: \(error)")
            }
        }
    }

    // MARK: - TDEE API

    /// TDEE API からデータ取得
    private func fetchTDEE() async throws -> TDEEData {
        let userEmail = SimpleCognitoService.shared.currentUserEmail ?? ""
        guard !userEmail.isEmpty else {
            throw NutritionError.userNotFound
        }

        let encodedEmail = userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? userEmail
        let baseUrl = ConfigurationManager.shared.apiEndpoints.fuudTdee
        let endpoint = "\(baseUrl)?userId=\(encodedEmail)"

        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .GET,
            requiresAuth: true
        )

        let response: TDEEResponse = try await NetworkManager.shared.sendRequest(
            config: requestConfig,
            responseType: TDEEResponse.self
        )

        guard response.success, let data = response.data else {
            throw NutritionError.tdeeNotAvailable
        }

        return data
    }

    // MARK: - Blood Data Processing

    /// 血液マーカー値を取得（キー指定）
    private func getBloodMarkerValue(_ key: String) -> Double? {
        guard let item = bloodService.findBloodItem(by: key) else {
            return nil
        }
        return Double(item.value)
    }

    /// 血液データに基づくカロリー調整率を計算
    private func calculateBloodAdjustment() -> (percent: Double, reasons: [AdjustmentReason]) {
        var percent = 0.0
        var reasons: [AdjustmentReason] = []

        // HbA1c チェック
        if let hba1c = getBloodMarkerValue("HbA1c") {
            if hba1c > 6.5 {
                percent -= 0.10
                reasons.append(.veryHighHbA1c(value: hba1c))
            } else if hba1c > 6.0 {
                percent -= 0.05
                reasons.append(.highHbA1c(value: hba1c))
            }
        }

        // 中性脂肪 (TG) チェック
        if let tg = getBloodMarkerValue("TG") {
            if tg > 300 {
                percent -= 0.10
                reasons.append(.veryHighTG(value: tg))
            } else if tg > 150 {
                percent -= 0.05
                reasons.append(.highTG(value: tg))
            }
        }

        // LDL チェック
        if let ldl = getBloodMarkerValue("LDL") {
            if ldl > 140 {
                percent -= 0.05
                reasons.append(.highLDL(value: ldl))
            }
        }

        // TSH チェック（甲状腺機能）
        if let tsh = getBloodMarkerValue("TSH") {
            if tsh < 0.5 {
                percent -= 0.10
                reasons.append(.lowTSH(value: tsh))
            } else if tsh > 4.0 {
                percent += 0.05
                reasons.append(.highTSH(value: tsh))
            }
        }

        // クレアチニン (CRE) チェック（PFC調整のみ、カロリー調整なし）
        if let cre = getBloodMarkerValue("CRE") {
            if cre > 1.2 {
                reasons.append(.highCreatinine(value: cre))
            }
        }

        return (percent: percent, reasons: reasons)
    }

    /// 血液データに基づくPFC調整を計算（デルタ値）
    private func calculateBloodPFCAdjustment() -> (protein: Double, fat: Double, carbs: Double) {
        var proteinDelta = 0.0
        var fatDelta = 0.0
        var carbsDelta = 0.0

        // HbA1c による調整
        if let hba1c = getBloodMarkerValue("HbA1c") {
            if hba1c > 6.5 {
                carbsDelta -= 15
                proteinDelta += 5
                fatDelta += 10
            } else if hba1c > 6.0 {
                carbsDelta -= 10
                proteinDelta += 5
                fatDelta += 5
            }
        }

        // TG による調整
        if let tg = getBloodMarkerValue("TG") {
            if tg > 300 {
                fatDelta -= 10
                proteinDelta += 5
                carbsDelta += 5
            } else if tg > 150 {
                fatDelta -= 5
                proteinDelta += 5
            }
        }

        // LDL による調整
        if let ldl = getBloodMarkerValue("LDL") {
            if ldl > 140 {
                fatDelta -= 5
                carbsDelta += 5
            }
        }

        // クレアチニンによる調整
        if let cre = getBloodMarkerValue("CRE") {
            if cre > 1.2 {
                proteinDelta -= 5
                carbsDelta += 5
            }
        }

        return (protein: proteinDelta, fat: fatDelta, carbs: carbsDelta)
    }

    // MARK: - Gene Data Processing

    /// ダイエットカテゴリーのスコアレベル取得
    private func getDietCategoryScoreLevel() -> GeneCategoryGroup.ScoreLevel? {
        let groups = geneService.generateCategoryGroups()
        guard let dietGroup = groups.first(where: { $0.name == "ダイエット" }) else {
            return nil
        }
        return dietGroup.scoreLevel
    }

    /// 個別マーカーのスコアレベル取得
    private func getMarkerScoreLevel(_ markerTitle: String) -> SNPImpactCount.ScoreLevel? {
        guard let data = geneService.geneData else { return nil }

        for (_, markers) in data.geneticMarkersWithGenotypes {
            for marker in markers {
                if marker.title == markerTitle || marker.title.contains(markerTitle) {
                    return marker.cachedImpact?.scoreLevel
                }
            }
        }
        return nil
    }

    /// 遺伝子データに基づくカロリー調整を計算
    private func calculateGeneAdjustment() -> (kcal: Int, reasons: [AdjustmentReason]) {
        var kcal = 0
        var reasons: [AdjustmentReason] = []

        // ダイエットカテゴリー全体のスコアレベル
        if let dietLevel = getDietCategoryScoreLevel() {
            if dietLevel == .needsSupport {
                // 要サポート型: カロリー調整はPFC側で対応
                reasons.append(.geneDietNeedsSupport)
            }
        }

        // 基礎代謝マーカー
        if let level = getMarkerScoreLevel("基礎代謝") {
            if level == .low || level == .slightlyLow {
                kcal -= 30
                reasons.append(.geneBasalMetabolismLow)
            }
        }

        return (kcal: kcal, reasons: reasons)
    }

    /// 遺伝子データに基づくPFC調整を計算（デルタ値）
    private func calculateGenePFCAdjustment() -> (protein: Double, fat: Double, carbs: Double) {
        var proteinDelta = 0.0
        var fatDelta = 0.0
        var carbsDelta = 0.0

        // ダイエットカテゴリー全体
        if let dietLevel = getDietCategoryScoreLevel() {
            if dietLevel == .needsSupport {
                carbsDelta -= 5
                proteinDelta += 5
            }
        }

        // インスリン抵抗性
        if let level = getMarkerScoreLevel("インスリン抵抗性") {
            if level == .low || level == .slightlyLow {
                carbsDelta -= 5
            }
        }

        // 高たんぱくダイエット効果
        if let level = getMarkerScoreLevel("高たんぱくダイエット効果") {
            if level == .high {
                proteinDelta += 3
            }
        }

        // 高脂肪ダイエット効果
        if let level = getMarkerScoreLevel("高脂肪ダイエット効果") {
            if level == .low {
                fatDelta -= 3
            }
        }

        return (protein: proteinDelta, fat: fatDelta, carbs: carbsDelta)
    }

    // MARK: - PFC Normalization

    /// PFCを正規化（合計100%、セーフティクリップ付き）
    private func normalizePFC(proteinDelta: Double, fatDelta: Double, carbsDelta: Double) -> PFCBalance {
        // デフォルト値 + デルタ
        var protein = 20 + proteinDelta
        var fat = 25 + fatDelta
        var carbs = 55 + carbsDelta

        // 合計を100%に正規化
        let total = protein + fat + carbs
        protein = protein / total * 100
        fat = fat / total * 100
        carbs = carbs / total * 100

        // セーフティクリップ
        protein = min(max(protein, 15), 30)  // 15〜30%
        fat = min(max(fat, 15), 35)          // 15〜35%
        carbs = min(max(carbs, 30), 65)      // 30〜65%

        // クリップ後の再正規化
        let clippedTotal = protein + fat + carbs
        protein = protein / clippedTotal * 100
        fat = fat / clippedTotal * 100
        carbs = carbs / clippedTotal * 100

        return PFCBalance(protein: protein, fat: fat, carbs: carbs)
    }

    // MARK: - Convenience Properties

    /// 調整後のカロリー目標（未取得時はデフォルト）
    var targetCalories: Int {
        adjustedCalories?.adjustedTarget ?? 2100
    }

    /// タンパク質グラム
    var proteinGrams: Int {
        pfcBalance.proteinGrams(for: targetCalories)
    }

    /// 脂質グラム
    var fatGrams: Int {
        pfcBalance.fatGrams(for: targetCalories)
    }

    /// 糖質グラム
    var carbsGrams: Int {
        pfcBalance.carbsGrams(for: targetCalories)
    }

    /// 調整理由があるかどうか
    var hasAdjustmentReasons: Bool {
        guard let reasons = adjustedCalories?.reasons else { return false }
        return !reasons.isEmpty
    }

    /// 血液由来の調整理由
    var bloodBasedReasons: [AdjustmentReason] {
        adjustedCalories?.reasons.filter { $0.isBloodBased } ?? []
    }

    /// 遺伝子由来の調整理由
    var geneBasedReasons: [AdjustmentReason] {
        adjustedCalories?.reasons.filter { !$0.isBloodBased } ?? []
    }
}

// MARK: - Error Types

enum NutritionError: LocalizedError {
    case userNotFound
    case tdeeNotAvailable
    case networkError

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "ユーザー情報が見つかりません"
        case .tdeeNotAvailable:
            return "TDEE情報が取得できません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        }
    }
}
