//
//  PromptGenerator.swift
//  AWStest
//
//  Bio-Integrative AI Analyst プロンプト生成
//

import Foundation

/// 外部AI用プロンプト生成ユーティリティ
struct PromptGenerator {

    // MARK: - Base Template

    /// Bio-Integrative AI Analystのベーステンプレート
    /// [DUMMY] 現状はユーザー背景が固定、将来的にプロフィールから動的取得
    private static let baseTemplate = """
あなたは「Bio-Integrative AI Analyst」です。

【背景】
週50kmランニング＋週3回筋トレを継続中のアスリート。
最近パフォーマンス低下や疲労感を感じている。

【目的】
遺伝子情報・血液検査・マイクロバイオーム・生活習慣データを統合分析し、
パフォーマンス低下の原因特定と具体的改善策を提示してください。

【専門領域】
栄養学、運動生理学、ホルモン制御、炎症管理、睡眠科学、遺伝学、長寿医学

【提供データ】
"""

    private static let templateFooter = """

【回答形式】
以下の形式で回答してください：

1. **多領域統合分析**
   - 遺伝子×血液×生活習慣の関連性を明確に説明
   - パフォーマンス低下の根本原因を特定

2. **具体的実行可能アドバイス**
   - 推奨食材（具体的な食品名と量）
   - サプリメント（種類と摂取量）
   - 運動内容の調整（強度・頻度・種類）
   - 睡眠・回復戦略

3. **優先順位付けアクションリスト**
   - 今すぐ実行すべきこと（優先度：高）
   - 1週間以内に実行すべきこと（優先度：中）
   - 1ヶ月以内に検討すべきこと（優先度：低）

4. **追加検査の提案**
   - さらに調査すべき血液マーカーや検査項目があれば提案
"""

    // MARK: - Gene Prompt Generation

    /// 単一遺伝子のプロンプト生成
    /// [DUMMY] 現状はモックデータ、将来的にGeneDataServiceから取得
    static func generateGenePrompt(
        geneName: String,
        variant: String,
        riskLevel: String,
        description: String
    ) -> String {
        let dataSection = """
--- データ開始 ---
【遺伝子情報】

遺伝子名: \(geneName)
バリアント: \(variant)
リスクレベル: \(riskLevel)
説明: \(description)

--- データ終了 ---
"""
        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    /// 複数遺伝子セクションのプロンプト生成
    /// [DUMMY] GeneCardの配列を受け取る想定、実装時に型調整
    static func generateGenesSectionPrompt(genes: [(name: String, variant: String, risk: String, description: String)]) -> String {
        var dataSection = """
--- データ開始 ---
【遺伝子情報】

"""
        for gene in genes {
            dataSection += """
・\(gene.name): \(gene.variant)
  リスク: \(gene.risk)
  説明: \(gene.description)

"""
        }
        dataSection += "--- データ終了 ---"

        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    // MARK: - Blood Marker Prompt Generation

    /// 単一血液マーカーのプロンプト生成
    /// [DUMMY] 現状はモックデータ、将来的にBloodTestServiceから取得
    static func generateBloodMarkerPrompt(
        markerName: String,
        value: String,
        unit: String,
        referenceRange: String,
        status: String
    ) -> String {
        let dataSection = """
--- データ開始 ---
【血液バイオマーカー】

マーカー名: \(markerName)
測定値: \(value) \(unit)
基準値: \(referenceRange)
状態: \(status)

--- データ終了 ---
"""
        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    /// 複数血液マーカーセクションのプロンプト生成
    /// [DUMMY] BloodMarkerの配列を受け取る想定、実装時に型調整
    static func generateBloodMarkersSectionPrompt(markers: [(name: String, value: String, unit: String, range: String, status: String)]) -> String {
        var dataSection = """
--- データ開始 ---
【血液バイオマーカー】

"""
        for marker in markers {
            dataSection += """
・\(marker.name): \(marker.value) \(marker.unit)
  基準値: \(marker.range)
  状態: \(marker.status)

"""
        }
        dataSection += "--- データ終了 ---"

        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    // MARK: - Lifestyle Score Prompt Generation

    /// ライフスタイルスコアカードのプロンプト生成
    /// [DUMMY] スコアとカテゴリー情報のみ、詳細データは今後追加
    static func generateLifeScorePrompt(
        category: String,
        score: Int,
        emoji: String
    ) -> String {
        let dataSection = """
--- データ開始 ---
【ライフスタイルスコア】

カテゴリー: \(emoji) \(category)
スコア: \(score)/100

※このスコアは複数の遺伝子・血液マーカー・生活習慣データから算出されています。
詳細な関連データについては、該当DetailViewをご確認ください。

--- データ終了 ---
"""
        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    // MARK: - DetailView Comprehensive Prompt Generation

    /// DetailView全体の統合プロンプト生成
    /// [DUMMY] 現状は簡易版、将来的に全データを統合
    static func generateDetailViewPrompt(
        category: String,
        score: Int,
        relatedGenes: [(name: String, variant: String, risk: String, description: String)],
        relatedBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)]
    ) -> String {
        var dataSection = """
--- データ開始 ---
【カテゴリー: \(category)】
総合スコア: \(score)/100

【関連遺伝子】
"""
        for gene in relatedGenes {
            dataSection += """
・\(gene.name): \(gene.variant)
  リスク: \(gene.risk)
  説明: \(gene.description)

"""
        }

        dataSection += """

【関連血液バイオマーカー】
"""
        for marker in relatedBloodMarkers {
            dataSection += """
・\(marker.name): \(marker.value) \(marker.unit)
  基準値: \(marker.range)
  状態: \(marker.status)

"""
        }

        dataSection += "--- データ終了 ---"

        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    // MARK: - Microbiome Prompt Generation

    /// マイクロバイオームデータのプロンプト生成
    /// [DUMMY] 腸内細菌データの固定フォーマット、API連携後に動的化
    static func generateMicrobiomePrompt(
        diversityScore: Int,
        bacteria: [(name: String, percentage: String)]
    ) -> String {
        var dataSection = """
--- データ開始 ---
【腸内マイクロバイオーム】

多様性スコア: \(diversityScore)/100

主要菌種構成:
"""
        for bacterium in bacteria {
            dataSection += "・\(bacterium.name): \(bacterium.percentage)\n"
        }

        dataSection += "\n--- データ終了 ---"

        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }
}
