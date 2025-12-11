//
//  ProgramRecommendation.swift
//  FUUD
//
//  プログラム推薦結果のモデル
//  Phase 6: プログラム推薦ロジック用
//

import Foundation

// MARK: - ProgramRecommendation

/// プログラム推薦結果
struct ProgramRecommendation: Identifiable {
    /// 一意識別子（プログラムIDと同じ）
    let id: String
    /// 推薦されたプログラム
    let program: DietProgram
    /// スコア（高いほど推薦度が高い）
    let score: Int
    /// 推薦理由の配列
    let reasons: [ProgramRecommendationReason]

    init(program: DietProgram, score: Int, reasons: [ProgramRecommendationReason]) {
        self.id = program.id
        self.program = program
        self.score = score
        self.reasons = reasons
    }
}

// MARK: - ProgramRecommendationReason

/// プログラム推薦の理由
enum ProgramRecommendationReason: String, CaseIterable {
    // MARK: - 血液由来
    case highHbA1c
    case highTG
    case highLDL
    case elevatedCRP
    case lowFerritin

    // MARK: - 遺伝子由来
    case poorCarbMetabolismGene
    case goodCarbMetabolismGene
    case poorFatMetabolismGene
    case goodFatOxidationGene
    case goodProteinResponseGene

    // MARK: - ライフスタイル由来
    case runnerLifestyle
    case strengthLifestyle
    case fastingPreferred
    case fastingNotPreferred
    case lowStressApproachPreferred

    // MARK: - 目標マッチ
    case goalMatch
    case paceMatch

    // MARK: - Display Text

    /// ユーザー向け表示テキスト
    var displayText: String {
        switch self {
        // 血液由来
        case .highHbA1c:
            return "HbA1cの値から、血糖コントロールを重視したプランが合いそうです。"
        case .highTG:
            return "中性脂肪の状態から、脂質と糖質をバランス良く抑えるプランを優先しています。"
        case .highLDL:
            return "LDLコレステロールの状態から、地中海式などの心血管ケアプランが適しています。"
        case .elevatedCRP:
            return "炎症マーカーの値から、抗炎症・腸ケアにフォーカスしたプランをおすすめします。"
        case .lowFerritin:
            return "フェリチンがやや低めのため、急激な断食より栄養を確保しながらの減量が適しています。"

        // 遺伝子由来
        case .poorCarbMetabolismGene:
            return "遺伝的に糖質代謝がやや苦手な傾向があるため、低糖質寄りのプランをおすすめします。"
        case .goodCarbMetabolismGene:
            return "糖質代謝が得意な体質のため、バランス型のプランでも進めやすい体質です。"
        case .poorFatMetabolismGene:
            return "脂質の代謝がやや苦手な傾向があるため、高脂質のプランは避けています。"
        case .goodFatOxidationGene:
            return "脂肪燃焼が得意な体質なので、脂質を活用したプランも効果的です。"
        case .goodProteinResponseGene:
            return "高タンパクに反応しやすい体質なので、タンパク質重視のプランが効果的です。"

        // ライフスタイル由来
        case .runnerLifestyle:
            return "ランニングの習慣があるため、持久力と糖質補給を両立するプランを優先しています。"
        case .strengthLifestyle:
            return "筋トレの頻度から、筋肉を維持・成長させやすいプランを優先しています。"
        case .fastingPreferred:
            return "断食への抵抗が少ないため、時間制限を活かしたプランも候補に含めています。"
        case .fastingNotPreferred:
            return "断食が合わないと感じているため、食事の質とバランスで整えるプランを優先しています。"
        case .lowStressApproachPreferred:
            return "ストレスを抑えながら続けたいという希望から、無理のないベースプランを優先しています。"

        // 目標マッチ
        case .goalMatch:
            return "あなたの目標に合ったプランです。"
        case .paceMatch:
            return "目標ペースに適した強度のプランです。"
        }
    }

    /// 理由のカテゴリ
    var category: ReasonCategory {
        switch self {
        case .highHbA1c, .highTG, .highLDL, .elevatedCRP, .lowFerritin:
            return .blood
        case .poorCarbMetabolismGene, .goodCarbMetabolismGene,
             .poorFatMetabolismGene, .goodFatOxidationGene, .goodProteinResponseGene:
            return .gene
        case .runnerLifestyle, .strengthLifestyle, .fastingPreferred,
             .fastingNotPreferred, .lowStressApproachPreferred:
            return .lifestyle
        case .goalMatch, .paceMatch:
            return .goal
        }
    }

    enum ReasonCategory {
        case blood
        case gene
        case lifestyle
        case goal
    }
}

// MARK: - RecommendationResult

/// 推薦結果全体（TOP3 + Calibration）
struct RecommendationResult {
    /// 推薦プログラムTOP3
    let topRecommendations: [ProgramRecommendation]
    /// キャリブレーションプログラム（前座として常に提示）
    let calibrationProgram: DietProgram?
    /// 推薦に使用したUserTraits
    let traits: UserTraits

    /// 推薦プログラムが存在するか
    var hasRecommendations: Bool {
        !topRecommendations.isEmpty
    }

    /// 1位のプログラム
    var topProgram: ProgramRecommendation? {
        topRecommendations.first
    }
}
