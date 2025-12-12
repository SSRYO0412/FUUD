//
//  YourTraitsModels.swift
//  FUUD
//
//  Your Traits セクション用のモデル定義
//

import SwiftUI

// MARK: - 遺伝子特性カテゴリ

/// 遺伝子特性のカテゴリ定義
struct GeneTraitCategory: Identifiable {
    let id: String
    let name: String
    let englishName: String
    let markerTitles: [String]
    let evaluationType: EvaluationType

    enum EvaluationType {
        case twoLevel(positive: String, negative: String)
        case threeLevel(good: String, caution: String, warning: String)
    }

    /// 定義済みカテゴリ
    static let categories: [GeneTraitCategory] = [
        GeneTraitCategory(
            id: "fatBurning",
            name: "脂肪燃焼",
            englishName: "Fat Burning",
            markerTitles: ["基礎代謝", "内臓脂肪", "脂質（血中濃度）", "高脂肪ダイエット効果"],
            evaluationType: .twoLevel(positive: "優位", negative: "苦手")
        ),
        GeneTraitCategory(
            id: "carbMetabolism",
            name: "糖質代謝",
            englishName: "Carb Metabolism",
            markerTitles: ["インスリン抵抗性", "中性脂肪（血中濃度）", "アディポネクチン値"],
            evaluationType: .threeLevel(good: "良好", caution: "やや注意", warning: "要注意")
        ),
        GeneTraitCategory(
            id: "proteinResponse",
            name: "タンパク質応答",
            englishName: "Protein Response",
            markerTitles: ["高たんぱくダイエット効果", "除脂肪体重"],
            evaluationType: .twoLevel(positive: "高応答型", negative: "標準型")
        ),
        GeneTraitCategory(
            id: "lipidMetabolism",
            name: "脂質代謝",
            englishName: "Lipid Metabolism",
            markerTitles: ["LDLコレステロール（血中濃度）", "HDLコレステロール（血中濃度）", "不飽和脂肪酸の摂取効果"],
            evaluationType: .twoLevel(positive: "良好", negative: "やや注意")
        )
    ]
}

// MARK: - 遺伝子特性評価結果

/// 遺伝子特性の評価結果
struct GeneTraitResult: Identifiable {
    let id: String
    let categoryName: String
    let score: Int
    let evaluation: String
    let status: TraitStatus

    enum TraitStatus {
        case positive  // 緑
        case neutral   // 黄
        case negative  // 赤

        var color: Color {
            switch self {
            case .positive: return .virgilSuccess
            case .neutral: return .virgilWarning
            case .negative: return .virgilError
            }
        }
    }

    /// スコアから評価結果を生成
    static func evaluate(category: GeneTraitCategory, score: Int) -> GeneTraitResult {
        let (evaluation, status) = evaluateScore(category: category, score: score)
        return GeneTraitResult(
            id: category.id,
            categoryName: category.name,
            score: score,
            evaluation: evaluation,
            status: status
        )
    }

    private static func evaluateScore(category: GeneTraitCategory, score: Int) -> (String, TraitStatus) {
        switch category.evaluationType {
        case .twoLevel(let positive, let negative):
            if score >= 0 {
                return (positive, .positive)
            } else {
                return (negative, .negative)
            }

        case .threeLevel(let good, let caution, let warning):
            if score >= 10 {
                return (good, .positive)
            } else if score >= -10 {
                return (caution, .neutral)
            } else {
                return (warning, .negative)
            }
        }
    }
}

// MARK: - 血液検査サマリー

/// 血液検査のサマリー情報
struct BloodTestSummary {
    let totalCount: Int
    let normalCount: Int
    let cautionCount: Int
    let abnormalCount: Int
    let highlightItems: [BloodHighlightItem]
    let isAllNormal: Bool

    struct BloodHighlightItem: Identifiable {
        let id = UUID()
        let key: String
        let nameJp: String
        let status: String
        let isNormal: Bool

        var statusColor: Color {
            switch status.lowercased() {
            case "正常", "normal":
                return .virgilSuccess
            case "注意", "caution", "要注意":
                return .virgilWarning
            default:
                return .virgilError
            }
        }
    }

    /// 対象とする血液検査項目のキー
    static let targetKeys = [
        "HbA1c",      // 血糖コントロール
        "TG",         // 中性脂肪
        "HDL",        // 善玉
        "LDL",        // 悪玉
        "ALT",        // 肝機能
        "gamma_gtp",  // 肝機能(アルコール)
        "CRP",        // 炎症マーカー
        "UA",         // 尿酸
        "Ferritin"    // 鉄貯蔵
    ]

    /// 項目キーの日本語表示名
    static func displayName(for key: String) -> String {
        switch key {
        case "HbA1c": return "HbA1c"
        case "TG": return "中性脂肪"
        case "HDL": return "HDL"
        case "LDL": return "LDL"
        case "ALT": return "ALT"
        case "gamma_gtp": return "γ-GTP"
        case "CRP": return "CRP"
        case "UA": return "尿酸"
        case "Ferritin": return "フェリチン"
        default: return key
        }
    }
}

// MARK: - 体重目標情報

/// 体重目標の情報
struct WeightGoalInfo {
    let currentWeight: Double?
    let targetWeight: Double?
    let goalType: GoalType
    let remaining: Double?

    enum GoalType: String {
        case lose = "lose"
        case maintain = "maintain"
        case gain = "gain"

        var displayName: String {
            switch self {
            case .lose: return "減量"
            case .maintain: return "維持"
            case .gain: return "増量"
            }
        }

        var icon: String {
            switch self {
            case .lose: return "arrow.down"
            case .maintain: return "arrow.left.arrow.right"
            case .gain: return "arrow.up"
            }
        }

        var color: Color {
            switch self {
            case .lose: return .lifesumLightGreen
            case .maintain: return .virgilPrimary
            case .gain: return .orange
            }
        }
    }

    /// remaining を計算
    static func create(currentWeight: Double?, targetWeight: Double?, goalTypeString: String?) -> WeightGoalInfo {
        let goalType: GoalType
        if let typeStr = goalTypeString {
            goalType = GoalType(rawValue: typeStr) ?? .maintain
        } else if let current = currentWeight, let target = targetWeight {
            if target < current {
                goalType = .lose
            } else if target > current {
                goalType = .gain
            } else {
                goalType = .maintain
            }
        } else {
            goalType = .maintain
        }

        var remaining: Double? = nil
        if let current = currentWeight, let target = targetWeight {
            remaining = target - current
        }

        return WeightGoalInfo(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            goalType: goalType,
            remaining: remaining
        )
    }
}

// MARK: - Your Traits データ全体

/// Your Traits セクションの全データ
struct YourTraitsData {
    var geneTraits: [GeneTraitResult]
    var bloodSummary: BloodTestSummary?
    var weightGoal: WeightGoalInfo?

    var hasGeneData: Bool { !geneTraits.isEmpty }
    var hasBloodData: Bool { bloodSummary != nil }
    var hasWeightData: Bool { weightGoal?.currentWeight != nil }

    static let empty = YourTraitsData(geneTraits: [], bloodSummary: nil, weightGoal: nil)
}
