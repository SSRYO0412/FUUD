//
//  PerformanceMetrics.swift
//  AWStest
//
//  Today's Performance セクション用のデータモデル
//

import Foundation

// MARK: - Performance Metrics

struct PerformanceMetrics: Codable {
    let recovery: MetricScore      // 回復度 実際の計算値に置き換え
    let metabolic: MetricLevel     // 代謝力 実際の判定値に置き換え
    let inflammation: MetricLevel  // 炎症 CRP基準値に置き換え
    let longevity: Double          // 老化速度 老化速度計算値に置き換え
    let performance: Int           // 総合パフォーマンス 統合スコアに置き換え
    let predictedCalories: Int     // 予測消費カロリー 予測計算値に置き換え

    // テスト用のサンプルデータ
    static var sample: PerformanceMetrics {
        PerformanceMetrics(
            recovery: MetricScore(score: 87, delta: "+5%", indicator: .excellent),
            metabolic: MetricLevel(level: .high, delta: "+12%", indicator: .high),
            inflammation: MetricLevel(level: .low, delta: "—", indicator: .low),
            longevity: 0.82, // 仮の老化速度
            performance: 85,  // 仮の総合スコア
            predictedCalories: 2450 // 仮の予測消費カロリー
        )
    }
}

// MARK: - Metric Score (数値スコア)

struct MetricScore: Codable {
    let score: Int
    let delta: String
    let indicator: IndicatorType
}

// MARK: - Metric Level (レベル表示)

struct MetricLevel: Codable {
    let level: Level
    let delta: String
    let indicator: IndicatorType

    enum Level: String, Codable {
        case low = "Low"
        case mid = "Mid"
        case high = "High"
    }
}

// MARK: - Indicator Type

enum IndicatorType: String, Codable {
    case excellent
    case high
    case low

    var color: String {
        switch self {
        case .excellent: return "0088CC" // 青
        case .high: return "00C853"      // 緑
        case .low: return "FFCB05"       // 黄
        }
    }
}

// MARK: - Performance Detail Data

struct PerformanceDetailData {
    let recovery: [String: String]
    let metabolic: [String: String]
    let inflammation: [String: String]
    let longevity: [String: String]
    let performance: [String: String]
    let predictedCalories: [String: String]

    // テスト用の詳細データ
    static var sample: PerformanceDetailData {
        PerformanceDetailData(
            recovery: [
                "HRV (RMSSD)": "68ms ↑",  // HealthKit実測値に置き換え
                "安静時心拍": "52bpm ↓",   // HealthKit実測値に置き換え
                "深睡眠": "22% ↑",         // HealthKit実測値に置き換え
                "前日負荷": "中強度"       // 運動強度計算値に置き換え
            ],
            metabolic: [
                "消費/基礎代謝比": "1.85", // 計算値に置き換え
                "7日トレンド": "上昇",     // トレンド分析結果に置き換え
                "HbA1c": "5.2%",          // 血液検査データに置き換え
                "TG/HDL比": "1.3"         // 血液検査データに置き換え
            ],
            inflammation: [
                "CRP": "0.3mg/L",         // 血液検査データに置き換え
                "体温偏差": "±0.2℃",      // HealthKit実測値に置き換え
                "トリガー": "なし",        // 分析結果に置き換え
                "睡眠充足": "良好"         // HealthKit実測値に置き換え
            ],
            longevity: [
                "老化速度": "0.82年/年",   // 計算値に置き換え
                "週平均": "0.85年/年",     // 計算値に置き換え
                "VO₂max": "42ml/kg/min",  // HealthKit実測値に置き換え
                "腸内多様性": "85点"       // 腸内細菌データに置き換え
            ],
            performance: [
                "推奨強度": "テンポ走可",  // AI分析結果に置き換え
                "回復度": "87% (40%)",    // 計算値に置き換え
                "代謝力": "High (30%)",   // 計算値に置き換え
                "炎症": "Low (20%)"       // 計算値に置き換え
            ],
            predictedCalories: [
                "予測消費": "2,450kcal",  // AI予測値に置き換え
                "基礎代謝": "1,850kcal",  // 計算値に置き換え
                "活動代謝": "600kcal",    // 計算値に置き換え
                "前日比": "+8%"           // 比較値に置き換え
            ]
        )
    }
}

// MARK: - Tuuning Intelligence Messages

struct TuuningIntelligence {
    // デフォルトメッセージ - メトリック未選択時に表示、本番ではAI総合分析結果に置き換え
    static let defaultMessages: [String] = [
        "本日の**Performance Readiness: 85/100**。回復度87%で前日比+5%改善、代謝効率は高活性状態。\n炎症マーカーは低値安定、老化速度は平均より18%遅延を維持。\n推奨：**高強度インターバルまたはテンポ走可能**。\nVO2max向上には最適なコンディション。\n注意点：水分補給を通常の1.2倍に増量推奨。",

        "全5指標が**最適域に収束**。稀少な最高コンディション。\nHRV68ms（上位10%）、CRP0.3mg/L、代謝効率指数1.85。\n推奨：**限界挑戦日**。新記録への挑戦または高負荷トレーニング。\n腸内環境も多様性スコア85で理想的。\nこのタイミングでの強度の高い刺激が成長を最大化。"
    ]

    // Recovery専用メッセージ - 本番ではRecovery指標分析結果に置き換え
    static let recoveryMessages: [String] = [
        "**回復度87%：優秀レベル**。HRV 68ms（上位15%）、安静時心拍52bpmで自律神経バランス良好。\n深睡眠22%確保、前日比+5%改善。\n推奨：**高強度トレーニング可能**。回復が十分なため、限界への挑戦に最適な状態。\nただし、水分補給を通常の1.2倍に増量し、トレーニング後のクールダウンを15分確保。",

        "**回復度72%：標準レベル**。HRVがやや低下（-8%）、交感神経優位の兆候。\n深睡眠18%でやや不足、REM睡眠も減少傾向。\n推奨：**Zone2有酸素運動まで**。高強度は避け、回復促進を優先。\n就寝3時間前のブルーライト制限、マグネシウムサプリ、ストレッチングを実施。"
    ]

    // Metabolic専用メッセージ - 本番では代謝力分析結果に置き換え
    static let metabolicMessages: [String] = [
        "**代謝力：HIGH**。消費/基礎代謝比1.85、7日トレンド上昇中。\nHbA1c 5.2%、TG/HDL比1.3で理想的な脂質プロファイル。\n推奨：**現在の食事・運動パターン継続**。代謝が脂質燃焼モードに完全移行。\n朝食前の低強度持久運動60-90分で脂肪燃焼を最大化。糖質摂取は運動後に。",

        "**代謝力：MID**。消費/基礎代謝比1.45、横ばい傾向。\nインスリン感受性やや低下、改善の余地あり。\n推奨：**Zone2運動週150分以上確保**。筋トレ週2回で筋量維持。\n炭水化物は運動前後のみに限定、間食は高タンパク・低糖質を選択。"
    ]

    // Inflammation専用メッセージ - 本番では炎症指標分析結果に置き換え
    static let inflammationMessages: [String] = [
        "**炎症レベル：LOW（理想的）**。CRP 0.3mg/L、体温偏差±0.2℃で安定。\nトリガー検出なし、睡眠充足度良好。\n推奨：**現状維持**。抗炎症状態を継続するため、オメガ3脂肪酸（魚油2g/日）、\nポリフェノール豊富な食品（ベリー類、緑茶）を積極摂取。\n高強度トレーニング後は必ずクールダウンと抗酸化食品を。",

        "**炎症レベル：MID（要注意）**。CRP 1.2mg/L、基準値上限付近。\n体温偏差大、睡眠不足がトリガーの可能性。\n推奨：**炎症軽減優先**。高強度運動一時停止、Zone1-2の軽運動のみ。\nターメリック、生姜、EPA/DHA、ビタミンC・E摂取。睡眠7.5時間以上確保。"
    ]

    // Longevity（Aging pace）専用メッセージ - 本番では老化速度分析結果に置き換え
    static let longevityMessages: [String] = [
        "**老化速度：0.82年/年（優秀）**。平均より18%遅い老化ペース。\n週平均0.85年/年で安定推移。VO₂max 42ml/kg/min、腸内多様性85点が寄与。\n推奨：**長期視点の健康習慣継続**。有酸素運動週150分維持、\n腸内環境サポート（発酵食品、食物繊維30g/日）、\n抗酸化食品（色の濃い野菜・果物）を日常化。",

        "**老化速度：1.05年/年（要改善）**。平均より5%速い老化ペース。\nVO₂max低下傾向、腸内多様性スコア62点。\n推奨：**ライフスタイル見直し**。有酸素運動を週200分に増量、\n筋トレ週2-3回追加。プロバイオティクス摂取、\n加工食品を減らし、ホールフードを80%以上に。睡眠の質向上を最優先。"
    ]

    // Performance専用メッセージ - 本番では総合パフォーマンス分析結果に置き換え
    static let performanceMessages: [String] = [
        "**総合パフォーマンス：85/100（優秀）**。\n回復度87%（40%寄与）、代謝力HIGH（30%寄与）、炎症LOW（20%寄与）で構成。\n推奨強度：**テンポ走・高強度インターバル可能**。\n本日のトレーニング効果が最大化される状態。新記録への挑戦や\n限界域トレーニングに最適。リカバリー戦略も併せて実施。",

        "**総合パフォーマンス：68/100（標準）**。\n回復度72%、代謝力MID、炎症やや高めで総合値が抑制。\n推奨強度：**Zone2有酸素運動・軽い筋トレまで**。\n高強度は避け、回復と炎症軽減を優先。\n睡眠・栄養・ストレス管理を見直し、ベースラインを底上げ。"
    ]

    // Predicted Calories専用メッセージ - 本番ではカロリー予測分析結果に置き換え
    static let predictedCaloriesMessages: [String] = [
        "**予測消費カロリー：2,450kcal（前日比+8%）**。\n基礎代謝1,850kcal、活動代謝600kcal。運動強度・日常活動量が高水準。\n推奨：**カロリー収支に注意**。減量中なら2,200kcal摂取、\n維持なら2,400-2,500kcal、増量なら2,700kcal目安。\nタンパク質150g以上確保、炭水化物は運動前後に集中配分。",

        "**予測消費カロリー：2,050kcal（前日比-5%）**。\n基礎代謝1,850kcal、活動代謝200kcal。活動量やや低下。\n推奨：**NEAT（非運動性活動）増加**。立ち時間、歩数を意識的に増やす。\n摂取カロリーは2,000kcal前後に調整、タンパク質比率を高め（30%以上）、\n代謝低下を防ぐ。"
    ]
}
