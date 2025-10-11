//
//  PerformanceMetrics.swift
//  AWStest
//
//  Today's Performance セクション用のデータモデル
//

import Foundation

// MARK: - Performance Metrics

struct PerformanceMetrics: Codable {
    let recovery: MetricScore      // 回復度 [DUMMY] 実際の計算値に置き換え
    let metabolic: MetricLevel     // 代謝力 [DUMMY] 実際の判定値に置き換え
    let inflammation: MetricLevel  // 炎症 [DUMMY] CRP基準値に置き換え
    let longevity: Double          // 老化速度 [DUMMY] 老化速度計算値に置き換え
    let performance: Int           // 総合パフォーマンス [DUMMY] 統合スコアに置き換え

    // [DUMMY] テスト用のサンプルデータ
    static var sample: PerformanceMetrics {
        PerformanceMetrics(
            recovery: MetricScore(score: 87, delta: "+5%", indicator: .excellent),
            metabolic: MetricLevel(level: .high, delta: "+12%", indicator: .high),
            inflammation: MetricLevel(level: .low, delta: "—", indicator: .low),
            longevity: 0.82, // [DUMMY] 仮の老化速度
            performance: 85  // [DUMMY] 仮の総合スコア
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

    // [DUMMY] テスト用の詳細データ
    static var sample: PerformanceDetailData {
        PerformanceDetailData(
            recovery: [
                "HRV (RMSSD)": "68ms ↑",  // [DUMMY] HealthKit実測値に置き換え
                "安静時心拍": "52bpm ↓",   // [DUMMY] HealthKit実測値に置き換え
                "深睡眠": "22% ↑",         // [DUMMY] HealthKit実測値に置き換え
                "前日負荷": "中強度"       // [DUMMY] 運動強度計算値に置き換え
            ],
            metabolic: [
                "消費/基礎代謝比": "1.85", // [DUMMY] 計算値に置き換え
                "7日トレンド": "上昇",     // [DUMMY] トレンド分析結果に置き換え
                "HbA1c": "5.2%",          // [DUMMY] 血液検査データに置き換え
                "TG/HDL比": "1.3"         // [DUMMY] 血液検査データに置き換え
            ],
            inflammation: [
                "CRP": "0.3mg/L",         // [DUMMY] 血液検査データに置き換え
                "体温偏差": "±0.2℃",      // [DUMMY] HealthKit実測値に置き換え
                "トリガー": "なし",        // [DUMMY] 分析結果に置き換え
                "睡眠充足": "良好"         // [DUMMY] HealthKit実測値に置き換え
            ],
            longevity: [
                "老化速度": "0.82年/年",   // [DUMMY] 計算値に置き換え
                "週平均": "0.85年/年",     // [DUMMY] 計算値に置き換え
                "VO₂max": "42ml/kg/min",  // [DUMMY] HealthKit実測値に置き換え
                "腸内多様性": "85点"       // [DUMMY] 腸内細菌データに置き換え
            ],
            performance: [
                "推奨強度": "テンポ走可",  // [DUMMY] AI分析結果に置き換え
                "回復度": "87% (40%)",    // [DUMMY] 計算値に置き換え
                "代謝力": "High (30%)",   // [DUMMY] 計算値に置き換え
                "炎症": "Low (20%)"       // [DUMMY] 計算値に置き換え
            ]
        )
    }
}

// MARK: - Tuuning Intelligence Messages

struct TuuningIntelligence {
    static let messages: [String] = [
        // [DUMMY] 以下のメッセージは実際のAI分析結果に置き換え
        "本日の**Performance Readiness: 85/100**。回復度87%で前日比+5%改善、代謝効率は高活性状態。\n炎症マーカーは低値安定、老化速度は平均より18%遅延を維持。\n推奨：**高強度インターバルまたはテンポ走可能**。\nVO2max向上には最適なコンディション。\n注意点：水分補給を通常の1.2倍に増量推奨。",

        "HRV値が**基準値より-12%低下**を検出。交感神経優位の状態。\n睡眠効率は82%でREM睡眠が不足傾向（通常比-15%）。\n推奨：**Zone2での有酸素運動40分まで**。\n回復促進のため、就寝3時間前からブルーライトを避ける。\nマグネシウム補給とストレッチングを夜のルーティンに追加。",

        "全5指標が**最適域に収束**。稀少な最高コンディション。\nHRV68ms（上位10%）、CRP0.3mg/L、代謝効率指数1.85。\n推奨：**限界挑戦日**。新記録への挑戦または高負荷トレーニング。\n腸内環境も多様性スコア85で理想的。\nこのタイミングでの強度の高い刺激が成長を最大化。",

        "代謝が**脂質燃焼モード**に完全移行。ケトン体利用効率↑。\n空腹時インスリン低値、TG/HDL比1.3で理想的な脂質プロファイル。\n推奨：**朝食前の低強度持久運動60-90分**。\n脂肪燃焼を最大化するため、運動中の糖質摂取は避ける。\nBCAAまたは電解質のみで水分補給を。",

        "**累積疲労度：警告レベル**。CK値上昇、睡眠債務3時間蓄積。\n深睡眠比率が15%（通常22%）まで低下、筋修復不足。\n推奨：**完全休養またはヨガ/軽いウォーキング**。\nタンパク質を体重×1.5g摂取、抗炎症食品を増やす。\n20分の昼寝で自律神経リセットを図る。"
    ]
}
