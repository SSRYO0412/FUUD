//
//  BloodScoring.swift
//  TUUN
//
//  TUUN 血液スコアリングエンジン (14カテゴリー)
//  各バイオマーカーの0-100スコアから14のライフスタイルカテゴリースコアを計算
//

import Foundation

// MARK: - MarkerId (バイオマーカーID)

/// バイオマーカーの識別子
enum MarkerId: String, CaseIterable, Codable {
    case AST
    case ALT
    case GGT      // γ-GTP
    case ALP
    case HbA1c
    case TG
    case HDL
    case LDL
    case TCHO     // 総コレステロール
    case Fe
    case UIBC
    case Ferritin
    case BUN
    case Cre
    case UA
    case TP
    case Alb
    case pAlb
    case CRP
    case CK       // CK / CPK
    case Mg
    case TBil     // 総ビリルビン
    case DBil     // 直接ビリルビン
}

// MARK: - CategoryId (カテゴリーID)

/// 健康カテゴリーの識別子
enum CategoryId: String, CaseIterable, Codable {
    case diet        // ⚡️ ダイエット
    case sleep       // 😴 睡眠
    case recovery    // 💪 疲労回復
    case performance // 🏃 運動能力
    case stress      // 🧘 ストレス
    case antioxidant // 🛡️ 抗酸化
    case cognition   // 🧠 脳の認知機能
    case appearance  // ✨ 見た目の健康
    case skin        // 🌸 肌
    case sexual      // ❤️ 性的な健康
    case vitality    // ⚡ 活力
    case heart       // ❤️‍🩹 心臓の健康
    case liver       // 🫘 肝機能
    case lifestyle   // 📊 生活習慣
}

// MARK: - CategoryDefinition

/// カテゴリー定義
struct CategoryDefinition {
    let id: CategoryId
    let emoji: String
    let nameJa: String
    let labelJa: String
    let weights: [MarkerId: Double] // 重み（%）
}

// MARK: - CategoryScore

/// カテゴリースコア結果
struct CategoryScore {
    let id: CategoryId
    let emoji: String
    let nameJa: String
    let labelJa: String
    let score: Double? // 0〜100、計算不能時はnil
}

// MARK: - Category Definitions (14カテゴリー)

/// 全カテゴリー定義
let categoryDefinitions: [CategoryDefinition] = [
    CategoryDefinition(
        id: .diet,
        emoji: "⚡️",
        nameJa: "ダイエット",
        labelJa: "⚡️ダイエット：脂肪が「落ちやすい／落ちにくい」代謝か？",
        weights: [.HbA1c: 25, .TG: 20, .LDL: 15, .HDL: 10, .TCHO: 10, .AST: 10, .ALT: 10]
    ),
    CategoryDefinition(
        id: .sleep,
        emoji: "😴",
        nameJa: "睡眠",
        labelJa: "😴睡眠：寝ているあいだにちゃんと回復できる体か？",
        weights: [.Mg: 25, .CRP: 20, .CK: 15, .HbA1c: 15, .AST: 10, .ALT: 10, .BUN: 5]
    ),
    CategoryDefinition(
        id: .recovery,
        emoji: "💪",
        nameJa: "疲労回復",
        labelJa: "💪疲労回復：一晩寝たらどこまでチャージし直せるか？",
        weights: [
            .Fe: 15, .Ferritin: 15, .Mg: 15, .CK: 15, .TP: 10, .Alb: 10, .CRP: 10, .UIBC: 5, .pAlb: 5
        ]
    ),
    CategoryDefinition(
        id: .performance,
        emoji: "🏃",
        nameJa: "運動能力",
        labelJa: "🏃運動能力：走る・動くための「血液スペック」は十分か？",
        weights: [
            .HbA1c: 15, .CK: 15, .Fe: 10, .Ferritin: 10, .TG: 10, .HDL: 10, .LDL: 10, .TCHO: 10, .Mg: 10
        ]
    ),
    CategoryDefinition(
        id: .stress,
        emoji: "🧘",
        nameJa: "ストレス",
        labelJa: "🧘ストレス：体の中のストレス負荷がどれくらい溜まっているか？",
        weights: [.CRP: 30, .Mg: 20, .HbA1c: 15, .UA: 15, .AST: 10, .ALT: 10]
    ),
    CategoryDefinition(
        id: .antioxidant,
        emoji: "🛡️",
        nameJa: "抗酸化",
        labelJa: "🛡️抗酸化：体が「サビにくい」状態を保てているか？",
        weights: [
            .TBil: 20, .CRP: 20, .DBil: 10, .HbA1c: 10, .LDL: 10, .HDL: 10, .TG: 10, .TCHO: 10
        ]
    ),
    CategoryDefinition(
        id: .cognition,
        emoji: "🧠",
        nameJa: "脳の認知機能",
        labelJa: "🧠脳の認知機能：脳の冴え・集中力の土台は整っているか？",
        weights: [
            .HbA1c: 20, .LDL: 15, .CRP: 15, .HDL: 10, .TCHO: 10, .Mg: 10, .Fe: 10, .Ferritin: 10
        ]
    ),
    CategoryDefinition(
        id: .appearance,
        emoji: "✨",
        nameJa: "見た目の健康",
        labelJa: "✨見た目の健康：見た目の若さ・印象を支える内側の状態は？",
        weights: [
            .HbA1c: 15, .TP: 10, .Alb: 10, .Fe: 10, .Ferritin: 10,
            .CRP: 10, .Mg: 10, .TCHO: 10, .pAlb: 5, .LDL: 5, .HDL: 5
        ]
    ),
    CategoryDefinition(
        id: .skin,
        emoji: "🌸",
        nameJa: "肌",
        labelJa: "🌸肌：ハリ・透明感・トラブルの出にくさを支える状態か？",
        weights: [
            .HbA1c: 20, .TP: 10, .Alb: 10, .Fe: 10, .Ferritin: 10,
            .CRP: 10, .TCHO: 10, .LDL: 10, .pAlb: 5, .TG: 5
        ]
    ),
    CategoryDefinition(
        id: .sexual,
        emoji: "❤️",
        nameJa: "性的な健康",
        labelJa: "❤️性的な健康：ホルモン・血流・代謝のバランスは整っているか？",
        weights: [
            .HbA1c: 20, .TCHO: 15, .LDL: 15, .HDL: 10, .TG: 10,
            .UA: 10, .CRP: 10, .Mg: 10
        ]
    ),
    CategoryDefinition(
        id: .vitality,
        emoji: "⚡",
        nameJa: "活力",
        labelJa: "⚡活力：朝からフルパワーを出せる「エネルギータンク」か？",
        weights: [
            .Mg: 15, .HbA1c: 13, .TP: 10, .Alb: 10, .CRP: 10,
            .Fe: 9, .Ferritin: 9, .GGT: 7, .AST: 6, .ALT: 6, .pAlb: 5
        ]
    ),
    CategoryDefinition(
        id: .heart,
        emoji: "❤️‍🩹",
        nameJa: "心臓の健康",
        labelJa: "❤️‍🩹心臓の健康：心臓と血管にどれくらい余裕があるか？",
        weights: [
            .HbA1c: 20, .LDL: 20, .TG: 15, .TCHO: 15,
            .HDL: 10, .CRP: 10, .UA: 5, .Mg: 5
        ]
    ),
    CategoryDefinition(
        id: .liver,
        emoji: "🫘",
        nameJa: "肝機能",
        labelJa: "🫘肝機能：肝臓の処理能力・解毒力にどれくらい余白があるか？",
        weights: [
            .AST: 25, .ALT: 25, .GGT: 20, .ALP: 10, .TBil: 10, .DBil: 10
        ]
    ),
    CategoryDefinition(
        id: .lifestyle,
        emoji: "📊",
        nameJa: "生活習慣",
        labelJa: "📊生活習慣：いまの生活スタイルが体にどれだけ優しいか／負担か？",
        weights: [
            .HbA1c: 14, .TG: 9, .HDL: 9, .LDL: 9, .TCHO: 9,
            .AST: 7, .ALT: 7, .GGT: 7, .CRP: 7,
            .TP: 5, .Alb: 5, .UA: 4, .BUN: 4, .Cre: 4
        ]
    )
]

// MARK: - Scoring Functions

/// 単一カテゴリーのスコアを計算
/// - Parameters:
///   - markerScores: 各マーカーの0〜100スコア
///   - weights: マーカーごとの重み
/// - Returns: 0〜100のスコア、または計算不能時はnil
func computeCategoryScore(
    markerScores: [MarkerId: Double],
    weights: [MarkerId: Double]
) -> Double? {
    var total: Double = 0
    var wSum: Double = 0

    // 各マーカーについて重み付き合計を計算
    for (markerId, weight) in weights {
        if let score = markerScores[markerId] {
            total += score * weight
            wSum += weight
        }
    }

    // 有効なマーカーが1つもない場合はnil
    if wSum == 0 {
        return nil
    }

    // 重み付き平均を計算
    var raw = total / wSum

    // 0〜100にクリップ
    if raw < 0 { raw = 0 }
    if raw > 100 { raw = 100 }

    return raw
}

/// 全14カテゴリーのスコアを計算
/// - Parameter markerScores: 各マーカーの0〜100スコア
/// - Returns: 全カテゴリーのスコア結果
func computeAllCategoryScores(
    markerScores: [MarkerId: Double]
) -> [CategoryId: CategoryScore] {
    var result: [CategoryId: CategoryScore] = [:]

    for def in categoryDefinitions {
        let score = computeCategoryScore(markerScores: markerScores, weights: def.weights)

        result[def.id] = CategoryScore(
            id: def.id,
            emoji: def.emoji,
            nameJa: def.nameJa,
            labelJa: def.labelJa,
            score: score
        )
    }

    return result
}
