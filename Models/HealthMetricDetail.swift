//
//  HealthMetricDetail.swift
//  AWStest
//
//  HOMEカード詳細データモデル
//

import Foundation

// MARK: - Metric Type

enum HealthMetricType: String, CaseIterable {
    case metabolic = "代謝力"
    case inflammation = "炎症レベル"
    case recovery = "回復スピード"
    case aging = "老化速度"

    var icon: String {
        switch self {
        case .metabolic: return "flame.circle.fill"
        case .inflammation: return "shield.circle.fill"
        case .recovery: return "arrow.clockwise.circle.fill"
        case .aging: return "chart.line.uptrend.xyaxis.circle.fill"
        }
    }

    var accentColor: String {
        switch self {
        case .metabolic: return "FF6B35" // オレンジ
        case .inflammation: return "4ECDC4" // ティール
        case .recovery: return "95E1D3" // ミントグリーン
        case .aging: return "A78BFA" // パープル
        }
    }
}

// MARK: - Score Breakdown

struct ScoreBreakdown: Identifiable {
    let id = UUID()
    let category: String
    let percentage: Double
    let value: Double // 0-100

    var color: String {
        if value >= 70 { return "00C853" } // Green
        if value >= 40 { return "FFCB05" } // Yellow
        return "ED1C24" // Red
    }
}

// MARK: - Blood Marker

struct BloodMarker: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let unit: String
    let status: MarkerStatus
    let normalRange: String

    enum MarkerStatus: String {
        case optimal = "最適"
        case good = "良好"
        case normal = "正常範囲"
        case attention = "注意"
        case high = "高い"

        var color: String {
            switch self {
            case .optimal: return "00C853"
            case .good: return "7CB342"
            case .normal: return "FFCB05"
            case .attention: return "FF9800"
            case .high: return "ED1C24"
            }
        }
    }
}

// MARK: - Trend Data

struct TrendData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Recommended Action

struct RecommendedAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: Priority

    enum Priority: String {
        case high = "高"
        case medium = "中"
        case low = "低"

        var color: String {
            switch self {
            case .high: return "ED1C24"
            case .medium: return "FFCB05"
            case .low: return "00C853"
            }
        }
    }
}

// MARK: - Health Metric Detail

struct HealthMetricDetail {
    let type: HealthMetricType
    let score: Double // 0-100 or custom value
    let scoreDisplay: String // "35%" or "1.2歳/年"
    let status: String
    let breakdowns: [ScoreBreakdown]
    let topMarkers: [BloodMarker]
    let trendData: [TrendData]
    let actions: [RecommendedAction]

    // 代謝力カードのサンプルデータ
    static let metabolicSample = HealthMetricDetail(
        type: .metabolic,
        score: 35,
        scoreDisplay: "35%",
        status: "中",
        breakdowns: [
            ScoreBreakdown(category: "血糖制御", percentage: 30, value: 45),
            ScoreBreakdown(category: "脂質代謝", percentage: 25, value: 38),
            ScoreBreakdown(category: "エネルギー効率", percentage: 20, value: 42),
            ScoreBreakdown(category: "インスリン感受性", percentage: 15, value: 28),
            ScoreBreakdown(category: "ミトコンドリア機能", percentage: 10, value: 35)
        ],
        topMarkers: [
            BloodMarker(name: "HbA1c", value: "5.4", unit: "%", status: .good, normalRange: "<5.7"),
            BloodMarker(name: "TG", value: "92", unit: "mg/dL", status: .optimal, normalRange: "<150"),
            BloodMarker(name: "HDL", value: "65", unit: "mg/dL", status: .optimal, normalRange: ">40"),
            BloodMarker(name: "LDL", value: "105", unit: "mg/dL", status: .good, normalRange: "<120"),
            BloodMarker(name: "Glucose", value: "95", unit: "mg/dL", status: .optimal, normalRange: "70-100")
        ],
        trendData: Array(0..<7).map { day in
            TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: Double.random(in: 30...40))
        },
        actions: [
            RecommendedAction(icon: "🏃", title: "朝の有酸素運動", description: "空腹時に30分の軽いジョギングで脂肪燃焼促進", priority: .high),
            RecommendedAction(icon: "🍽️", title: "食後の軽い運動", description: "食後15分の散歩で血糖値スパイク抑制", priority: .high),
            RecommendedAction(icon: "🥗", title: "低GI食品選択", description: "全粒穀物・野菜中心の食事で血糖安定化", priority: .medium)
        ]
    )

    // 炎症レベルカードのサンプルデータ
    static let inflammationSample = HealthMetricDetail(
        type: .inflammation,
        score: 40,
        scoreDisplay: "40%",
        status: "状態正常",
        breakdowns: [
            ScoreBreakdown(category: "急性炎症", percentage: 40, value: 55),
            ScoreBreakdown(category: "慢性炎症", percentage: 30, value: 38),
            ScoreBreakdown(category: "酸化ストレス", percentage: 20, value: 42),
            ScoreBreakdown(category: "免疫バランス", percentage: 10, value: 48)
        ],
        topMarkers: [
            BloodMarker(name: "CRP", value: "0.08", unit: "mg/dL", status: .optimal, normalRange: "<0.3"),
            BloodMarker(name: "IL-6", value: "2.1", unit: "pg/mL", status: .good, normalRange: "<5.0"),
            BloodMarker(name: "Ferritin", value: "88", unit: "ng/mL", status: .good, normalRange: "30-400"),
            BloodMarker(name: "白血球", value: "6200", unit: "/μL", status: .optimal, normalRange: "3500-9000"),
            BloodMarker(name: "ESR", value: "8", unit: "mm/hr", status: .optimal, normalRange: "<15")
        ],
        trendData: Array(0..<7).map { day in
            TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: Double.random(in: 35...45))
        },
        actions: [
            RecommendedAction(icon: "🥗", title: "抗炎症食材摂取", description: "オメガ3・ターメリック・緑茶で炎症抑制", priority: .high),
            RecommendedAction(icon: "🧘", title: "ストレス管理", description: "毎日15分の瞑想でコルチゾール低減", priority: .high),
            RecommendedAction(icon: "😴", title: "十分な睡眠", description: "7-8時間の質の高い睡眠で炎症回復", priority: .medium)
        ]
    )

    // 回復スピードカードのサンプルデータ
    static let recoverySample = HealthMetricDetail(
        type: .recovery,
        score: 71,
        scoreDisplay: "71%",
        status: "準備完了",
        breakdowns: [
            ScoreBreakdown(category: "筋肉回復", percentage: 35, value: 75),
            ScoreBreakdown(category: "神経回復", percentage: 25, value: 68),
            ScoreBreakdown(category: "代謝回復", percentage: 20, value: 72),
            ScoreBreakdown(category: "睡眠質", percentage: 20, value: 70)
        ],
        topMarkers: [
            BloodMarker(name: "CK", value: "145", unit: "U/L", status: .optimal, normalRange: "50-200"),
            BloodMarker(name: "LDH", value: "168", unit: "U/L", status: .good, normalRange: "120-240"),
            BloodMarker(name: "Cortisol", value: "12.5", unit: "μg/dL", status: .optimal, normalRange: "6-18"),
            BloodMarker(name: "HRV", value: "68", unit: "ms", status: .good, normalRange: ">50"),
            BloodMarker(name: "深睡眠", value: "90", unit: "分", status: .optimal, normalRange: ">60")
        ],
        trendData: Array(0..<7).map { day in
            TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: Double.random(in: 65...75))
        },
        actions: [
            RecommendedAction(icon: "🚶", title: "アクティブリカバリー", description: "軽い散歩・ストレッチで血流促進", priority: .high),
            RecommendedAction(icon: "😴", title: "質の高い睡眠", description: "22時就寝で深睡眠90分以上確保", priority: .high),
            RecommendedAction(icon: "🍖", title: "タンパク質摂取", description: "体重×1.5gのタンパク質で筋肉回復", priority: .medium)
        ]
    )

    // 老化速度カードのサンプルデータ
    static let agingSample = HealthMetricDetail(
        type: .aging,
        score: 1.2,
        scoreDisplay: "1.2歳/年",
        status: "標準",
        breakdowns: [
            ScoreBreakdown(category: "細胞老化", percentage: 30, value: 45),
            ScoreBreakdown(category: "酸化ダメージ", percentage: 25, value: 52),
            ScoreBreakdown(category: "糖化", percentage: 20, value: 48),
            ScoreBreakdown(category: "テロメア", percentage: 15, value: 55),
            ScoreBreakdown(category: "DNA修復", percentage: 10, value: 50)
        ],
        topMarkers: [
            BloodMarker(name: "AGEs", value: "12", unit: "μg/mL", status: .good, normalRange: "<15"),
            BloodMarker(name: "抗酸化能力", value: "1.2", unit: "mM", status: .good, normalRange: ">1.0"),
            BloodMarker(name: "HbA1c", value: "5.4", unit: "%", status: .good, normalRange: "<5.7"),
            BloodMarker(name: "Albumin", value: "4.4", unit: "g/dL", status: .optimal, normalRange: "3.8-5.3"),
            BloodMarker(name: "TP", value: "7.1", unit: "g/dL", status: .optimal, normalRange: "6.5-8.0")
        ],
        trendData: Array(0..<7).map { day in
            TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: Double.random(in: 1.1...1.3))
        },
        actions: [
            RecommendedAction(icon: "🥗", title: "抗酸化食品摂取", description: "ベリー類・緑茶・ダークチョコで酸化防止", priority: .high),
            RecommendedAction(icon: "🍽️", title: "カロリー制限", description: "適度なカロリー制限で長寿遺伝子活性化", priority: .medium),
            RecommendedAction(icon: "🏃", title: "適度な運動", description: "週3回の中強度運動でテロメア保護", priority: .medium)
        ]
    )
}
