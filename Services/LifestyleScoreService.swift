//
//  LifestyleScoreService.swift
//  TUUN
//
//  ライフスタイルカテゴリー(14種類)のスコア計算サービス
//  血液検査データから各カテゴリーのスコアを算出
//

import Foundation
import Combine

/// ライフスタイルカテゴリースコア計算サービス
@MainActor
class LifestyleScoreService: ObservableObject {
    static let shared = LifestyleScoreService()

    // MARK: - Published Properties

    @Published var categoryScores: [CategoryId: CategoryScore] = [:]
    @Published var isCalculating = false
    @Published var lastCalculated: Date?

    // MARK: - Dependencies

    private let bloodTestService = BloodTestService.shared

    // MARK: - Marker Key Mapping

    /// BloodTestServiceのキー → MarkerIdへのマッピング
    private let markerKeyMapping: [String: MarkerId] = [
        "AST": .AST,
        "ALT": .ALT,
        "GGT": .GGT,
        "γ-GTP": .GGT,
        "ALP": .ALP,
        "HbA1c": .HbA1c,
        "TG": .TG,
        "HDL": .HDL,
        "LDL": .LDL,
        "TC": .TCHO,
        "TCHO": .TCHO,
        "T-Cho": .TCHO,
        "Fe": .Fe,
        "UIBC": .UIBC,
        "Ferritin": .Ferritin,
        "ferritin": .Ferritin,
        "BUN": .BUN,
        "Cre": .Cre,
        "CRE": .Cre,
        "UA": .UA,
        "TP": .TP,
        "Alb": .Alb,
        "ALB": .Alb,
        "pAlb": .pAlb,
        "PreAlb": .pAlb,
        "CRP": .CRP,
        "CK": .CK,
        "CPK": .CK,
        "Mg": .Mg,
        "MG": .Mg,
        "T-Bil": .TBil,
        "TBil": .TBil,
        "TBIL": .TBil,
        "D-Bil": .DBil,
        "DBil": .DBil,
        "DBIL": .DBil
    ]

    // MARK: - Initialization

    private init() {
        // シングルトン
    }

    // MARK: - Public Methods

    /// 全14カテゴリーのスコアを計算
    func calculateAllScores() async {
        isCalculating = true
        defer { isCalculating = false }

        // BloodTestServiceからデータ取得
        guard let bloodData = bloodTestService.bloodData else {
            print("⚠️ LifestyleScoreService: 血液検査データが存在しません")
            return
        }

        // 各マーカーを0-100点に変換
        let markerScores = convertBloodItemsToScores(bloodData.bloodItems)

        // 14カテゴリーのスコアを計算
        let scores = computeAllCategoryScores(markerScores: markerScores)

        // UI更新
        categoryScores = scores
        lastCalculated = Date()

        print("✅ LifestyleScoreService: 14カテゴリーのスコア計算完了")
        printScoreSummary()
    }

    /// 特定のカテゴリーのスコアを取得
    func getScore(for categoryId: CategoryId) -> Int? {
        guard let categoryScore = categoryScores[categoryId],
              let score = categoryScore.score else {
            return nil
        }
        return Int(score.rounded())
    }

    // MARK: - Private Methods

    /// 血液検査データを0-100スコアに変換
    /// - Parameter bloodItems: BloodTestServiceから取得した血液検査項目
    /// - Returns: 各マーカーの0-100スコア
    private func convertBloodItemsToScores(_ bloodItems: [BloodTestService.BloodItem]) -> [MarkerId: Double] {
        var markerScores: [MarkerId: Double] = [:]

        for item in bloodItems {
            // キーをMarkerIdに変換
            guard let markerId = markerKeyMapping[item.key] else {
                continue // マッピングに存在しないマーカーはスキップ
            }

            // 値を数値に変換
            guard let value = Double(item.value.trimmingCharacters(in: .whitespaces)) else {
                continue // 数値変換できない場合はスキップ
            }

            // MetricConfigsから設定を取得してスコア計算
            let score = scoreMarkerValue(markerId: markerId, value: value)

            if let score = score {
                markerScores[markerId] = score
            }
        }

        return markerScores
    }

    /// 単一マーカーの値を0-100スコアに変換
    /// - Parameters:
    ///   - markerId: マーカーID
    ///   - value: 実測値
    /// - Returns: 0-100スコア（高いほど良い）
    private func scoreMarkerValue(markerId: MarkerId, value: Double) -> Double? {
        // MetricConfigsから対応する設定を取得
        let metricId = convertMarkerIdToMetricId(markerId)

        guard let config = MetricConfigs.all.first(where: { $0.id == metricId }) else {
            // 設定が見つからない場合は簡易計算
            return simpleScore(markerId: markerId, value: value)
        }

        // ScoreEngineを使って0-100スコアに変換
        return ScoreEngine.scoreMetric(value: value, config: config)
    }

    /// MarkerIdをMetricConfigsのmetricIdに変換
    private func convertMarkerIdToMetricId(_ markerId: MarkerId) -> String {
        switch markerId {
        case .HbA1c: return "HbA1c"
        case .AST: return "AST"
        case .ALT: return "ALT"
        case .GGT: return "GGT"
        case .ALP: return "ALP"
        case .TG: return "TG"
        case .TCHO: return "TC"
        case .HDL: return "HDL"
        case .LDL: return "LDL"
        case .CRP: return "CRP"
        case .Fe: return "Fe"
        case .Ferritin: return "ferritin"
        case .UIBC: return "UIBC"
        case .BUN: return "BUN"
        case .Cre: return "CRE"
        case .UA: return "UA"
        case .TP: return "TP"
        case .Alb: return "ALB"
        case .pAlb: return "pAlb"
        case .CK: return "CK"
        case .Mg: return "Mg"
        case .TBil: return "TBIL"
        case .DBil: return "DBil"
        }
    }

    /// MetricConfigsに定義がない場合の簡易スコア計算
    private func simpleScore(markerId: MarkerId, value: Double) -> Double {
        // 暫定的にすべて50点を返す
        // TODO: 各マーカーの基準範囲に基づいた計算を実装
        return 50.0
    }

    /// スコアサマリーをログ出力
    private func printScoreSummary() {
        print("📊 ライフスタイルカテゴリースコア:")
        for def in categoryDefinitions {
            if let catScore = categoryScores[def.id],
               let score = catScore.score {
                print("  \(catScore.emoji) \(catScore.nameJa): \(Int(score.rounded()))点")
            } else if let catScore = categoryScores[def.id] {
                print("  \(catScore.emoji) \(catScore.nameJa): 計算不能")
            }
        }
    }
}
