//
//  UserTraits.swift
//  FUUD
//
//  ユーザーの遺伝子・血液・ライフスタイル情報を統合したモデル
//  Phase 6: プログラム推薦ロジック用
//

import Foundation

// MARK: - UserTraits

/// ユーザーの特性情報（遺伝子・血液・ライフスタイル）を統合した構造体
struct UserTraits {
    /// 遺伝子プロファイル
    let gene: GeneProfile
    /// 血液プロファイル
    let blood: BloodProfile
    /// ライフスタイルプロファイル
    let lifestyle: LifestyleProfile
}

// MARK: - Gene Profile

extension UserTraits {
    /// 遺伝子4軸のプロファイル
    struct GeneProfile {
        /// 遺伝子評価レベル
        enum Level: String {
            case good     // 良好・得意
            case caution  // やや注意
            case poor     // 苦手・要サポート
        }

        /// 糖質代謝（インスリン抵抗性、中性脂肪、アディポネクチン値）
        let carbMetabolism: Level
        /// 脂肪燃焼（基礎代謝、内臓脂肪、脂質、高脂肪ダイエット効果）
        let fatOxidation: Level
        /// タンパク質応答（高たんぱくダイエット効果、除脂肪体重）
        let proteinResponse: Level
        /// 脂質代謝（LDL/HDLコレステロール、不飽和脂肪酸の摂取効果）
        let lipidMetabolism: Level

        /// データなし時のデフォルト
        static let unknown = GeneProfile(
            carbMetabolism: .caution,
            fatOxidation: .caution,
            proteinResponse: .caution,
            lipidMetabolism: .caution
        )
    }
}

// MARK: - Blood Profile

extension UserTraits {
    /// 血液検査プロファイル（9項目）
    struct BloodProfile {
        /// HbA1c（血糖コントロール）
        let hba1c: Double?
        /// 中性脂肪
        let tg: Double?
        /// HDLコレステロール（善玉）
        let hdl: Double?
        /// LDLコレステロール（悪玉）
        let ldl: Double?
        /// ALT（肝機能）
        let alt: Double?
        /// γ-GTP（肝機能・アルコール）
        let gammaGtp: Double?
        /// CRP（炎症マーカー）
        let crp: Double?
        /// 尿酸
        let ua: Double?
        /// フェリチン（鉄貯蔵）
        let ferritin: Double?

        /// ステータスマップ（キー: 項目名, 値: 正常/注意/異常/高い/低い）
        /// 例: ["HbA1c": "高い", "TG": "注意", "LDL": "正常", ...]
        /// スコアリング時に statusMap["HbA1c"] == "高い" のような条件で使用
        let statusMap: [String: String]

        /// データなし時のデフォルト
        static let empty = BloodProfile(
            hba1c: nil, tg: nil, hdl: nil, ldl: nil,
            alt: nil, gammaGtp: nil, crp: nil, ua: nil, ferritin: nil,
            statusMap: [:]
        )

        // MARK: - Convenience Methods

        /// HbA1cが高いか（>= 6.0）
        var isHbA1cHigh: Bool {
            guard let value = hba1c else { return false }
            return value >= 6.0
        }

        /// HbA1cが非常に高いか（>= 6.5）
        var isHbA1cVeryHigh: Bool {
            guard let value = hba1c else { return false }
            return value >= 6.5
        }

        /// 中性脂肪が高いか（>= 150）
        var isTGHigh: Bool {
            guard let value = tg else { return false }
            return value >= 150
        }

        /// LDLが高いか（>= 140）
        var isLDLHigh: Bool {
            guard let value = ldl else { return false }
            return value >= 140
        }

        /// CRPが高いか（>= 1.0）
        var isCRPElevated: Bool {
            guard let value = crp else { return false }
            return value >= 1.0
        }

        /// フェリチンが低いか（< 20）
        var isFerritinLow: Bool {
            guard let value = ferritin else { return false }
            return value < 20
        }
    }
}

// MARK: - Lifestyle Profile

extension UserTraits {
    /// ライフスタイル・オンボーディング情報
    struct LifestyleProfile {
        /// 目標タイプ（既存のGoalTypeを再利用）
        let goal: GoalType
        /// 週あたりの目標体重変化（kg/week）
        let weeklyRateKg: Double?
        /// 断食への嗜好
        let fastingPreference: FastingPreference
        /// 糖質制限への嗜好
        let carbPreference: CarbPreference
        /// 食事スタイル
        let dietPreference: DietPreference
        /// 運動スタイル
        let trainingStyle: TrainingStyle

        /// 断食嗜好
        enum FastingPreference: String {
            case ok           // 断食OK
            case notPreferred // あまり好まない
            case no           // 断食NG
        }

        /// 糖質制限嗜好
        enum CarbPreference: String {
            case ok           // 糖質制限OK
            case notPreferred // あまり好まない
            case no           // 糖質制限NG
        }

        /// 食事スタイル
        enum DietPreference: String {
            case omnivore     // 雑食
            case pescatarian  // ペスカタリアン
            case vegetarian   // ベジタリアン
            case vegan        // ヴィーガン
        }

        /// 運動スタイル
        enum TrainingStyle: String {
            case none      // 運動なし
            case cardio    // 有酸素運動中心
            case strength  // 筋トレ中心
            case both      // 両方
        }

        /// デフォルト値（オンボーディングデータがない場合）
        static func defaultProfile(goal: GoalType = .lose, weeklyRate: Double? = nil) -> LifestyleProfile {
            return LifestyleProfile(
                goal: goal,
                weeklyRateKg: weeklyRate,
                fastingPreference: .notPreferred,
                carbPreference: .ok,
                dietPreference: .omnivore,
                trainingStyle: .none
            )
        }
    }
}
