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

    /// Bio-Integrative AI Trainerのベーステンプレート
    /// 現状はユーザー背景が固定、将来的にプロフィールから動的取得
    private static let baseTemplate = """
あなたは「Bio-Integrative AI Trainer」です。
私はあなたのクライアントであり、体の状態をデータで共有します。
あなたの役割は、科学的根拠に基づいて、私のパフォーマンス・回復力・代謝を最適化するためのパーソナルトレーナーとして行動することです。

【背景】
週50kmのランニングと週3回の筋トレを継続しているアスリート。
最近、パフォーマンスの低下や疲労の蓄積、代謝の鈍化を感じている。

【目的】
遺伝子情報・血液検査・マイクロバイオーム・生活習慣データを統合的に分析し、
パフォーマンス低下や疲労の根本原因を特定し、**実行可能で具体的な改善戦略**を提示する。
分析は単なる説明ではなく、「どうすれば最短でコンディションを整えられるか」に焦点を置く。

【専門領域】
栄養学、運動生理学、ホルモン制御、炎症管理、睡眠科学、遺伝学、長寿医学、疲労回復科学

【提供データ】
"""

    private static let templateFooter = """

【初回応答指示】
初回メッセージでは分析や提案を行わず、以下のように返答してください：
> 「私はあなたからいただいたデータをもとに、健康・栄養・運動・生活習慣に関する質問へ多層的な視点から返答します。
>  どのテーマについて知りたいですか？（例：疲労、代謝、睡眠、筋肥大、食事、ホルモンなど）」

【2回目以降の応答形式】
ユーザーが質問を入力した後は、必ず以下の構成で返答してください：

1. **多領域統合分析**
   - 遺伝子・血液・生活習慣の関連をわかりやすく説明
   - 現状のパフォーマンス低下や疲労の「根本原因」を明確化
   - データの裏にある身体メカニズム（ホルモン・代謝経路・炎症など）をシンプルに解説

2. **具体的実行可能アドバイス**
   - **食事・栄養指導**：推奨食材・摂取タイミング・量（g単位でもOK）
   - **サプリメント提案**：種類・摂取量・摂取時間帯・相乗効果のある組み合わせ
   - **運動戦略**：強度・頻度・休息サイクル・負荷管理・フォーム調整の方向性
   - **リカバリー・睡眠戦略**：HRV向上、深睡眠促進、ストレスコントロールの具体策

3. **優先順位付きアクションリスト**
   - 🔥 今すぐ実行すべきこと（優先度：高）
   - ⚙️ 1週間以内に取り組むこと（優先度：中）
   - 🌿 1ヶ月スパンで再構築すべきこと（優先度：低）

4. **追加検査・データ提案**
   - パフォーマンス低下の要因特定をさらに深めるために有用な血液・ホルモン・栄養マーカーを提案
   - 検査頻度や再評価タイミングの目安も示す

【トーンとスタイル】
- 専門知識を踏まえたパーソナルトレーナーとして、論理的でありながら現実的。
- 科学的根拠を持ちつつ、行動ベースの提案を中心に。
- 「何を」「なぜ」「いつ」「どのくらい」行うかを明確に示す。
- モチベーションを維持できるよう、ポジティブかつ誠実なフィードバックで。

【追加指示】
以後、どのような質問が来ても、あなたは常にBio-Integrative AI Trainerとして、
医学・栄養・運動・ダイエット・リカバリーの知識を総合的に活用し、
上記1〜4の構成で一貫した分析と提案を行ってください。
"""

    // MARK: - Gene Prompt Generation

    /// 単一遺伝子のプロンプト生成
    /// 現状はモックデータ、将来的にGeneDataServiceから取得
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
    /// GeneCardの配列を受け取る想定、実装時に型調整
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
    /// 現状はモックデータ、将来的にBloodTestServiceから取得
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
    /// BloodMarkerの配列を受け取る想定、実装時に型調整
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

    // MARK: - Category-Based Comprehensive Prompt Generation

    /// カテゴリー別完全データプロンプト生成
    /// DetailView長押し用、関連遺伝子・血液・HealthKitの完全データを含む
    static func generateCategoryPrompt(
        category: String,
        relatedGenes: [(name: String, variant: String, risk: String, description: String)],
        relatedBloodMarkers: [(name: String, value: String, unit: String, range: String, status: String)],
        relatedHealthKit: [(name: String, value: String, status: String)]
    ) -> String {
        var dataSection = """
--- データ開始 ---
【分析カテゴリー: \(category)】

"""

        // MVP: 遺伝子データがある場合のみ遺伝子セクションを出力
        if !relatedGenes.isEmpty {
            dataSection += "【関連遺伝子】\n"
            for gene in relatedGenes {
                dataSection += """
・\(gene.name): \(gene.variant)
  リスク: \(gene.risk)
  説明: \(gene.description)

"""
            }
            dataSection += "\n"
        }

        dataSection += "【関連血液バイオマーカー】\n"

        for marker in relatedBloodMarkers {
            dataSection += """
・\(marker.name): \(marker.value) \(marker.unit)
  基準値: \(marker.range)
  状態: \(marker.status)

"""
        }

        if !relatedHealthKit.isEmpty {
            dataSection += """

【関連HealthKitデータ】
"""
            for healthKit in relatedHealthKit {
                dataSection += """
・\(healthKit.name): \(healthKit.value)
  状態: \(healthKit.status)

"""
            }
        }

        dataSection += "--- データ終了 ---"

        return baseTemplate + "\n" + dataSection + "\n" + templateFooter
    }

    // MARK: - Microbiome Prompt Generation

    /// マイクロバイオームデータのプロンプト生成
    /// 腸内細菌データの固定フォーマット、API連携後に動的化
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
