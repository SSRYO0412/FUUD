//
//  HighProteinRoadmap.swift
//  FUUD
//
//  High-Protein Program Roadmap Data (30/45/90日コース)
//

import Foundation

// MARK: - Course Focus

/// コース別フォーカス情報（DOS AND DON'TSとPFC目安）
struct CourseFocus {
    let duration: Int           // 30, 45, 90
    let weeks: Int              // 4, 6, 12
    let concept: String         // コースコンセプト（1行）
    let pfc: PFCRatio           // P/F/C比率
    let dos: [String]           // DO項目
    let donts: [String]         // DON'T項目
}

// MARK: - Roadmap Phase

/// ロードマップの週単位フェーズ
struct RoadmapPhase: Identifiable {
    let id: String
    let weekNumber: Int
    let dayRange: String        // "Day 1-7"
    let title: String           // フェーズ名
    let subtitle: String        // 週テーマ
    let focusPoints: [String]   // 具体的なタスク（2-3個）

    init(
        weekNumber: Int,
        dayRange: String,
        title: String,
        subtitle: String,
        focusPoints: [String]
    ) {
        self.id = "week-\(weekNumber)"
        self.weekNumber = weekNumber
        self.dayRange = dayRange
        self.title = title
        self.subtitle = subtitle
        self.focusPoints = focusPoints
    }
}

// MARK: - High Protein Roadmap

/// High-Proteinプログラムのロードマップデータ
struct HighProteinRoadmap {

    // MARK: - Get Course Focus

    /// コース別のフォーカス情報を取得
    static func getFocus(duration: Int) -> CourseFocus {
        switch duration {
        case 30:
            return CourseFocus(
                duration: 30,
                weeks: 4,
                concept: "高タンパクの基礎を身につける",
                pfc: PFCRatio(protein: 35, fat: 30, carbs: 35),
                dos: [
                    "毎食20g以上のタンパク質を摂る",
                    "朝食を抜かない（プロテインだけでもOK）",
                    "タンパク源（肉・魚・卵・大豆）を把握する",
                    "1日のタンパク質量をアプリで確認する",
                    "食事ログを毎日つける"
                ],
                donts: [
                    "炭水化物を極端に減らさない",
                    "タンパク質だけに偏った食事にしない"
                ]
            )

        case 45:
            return CourseFocus(
                duration: 45,
                weeks: 6,
                concept: "高タンパクの型＋トレーニング連携",
                pfc: PFCRatio(protein: 35, fat: 30, carbs: 35),
                dos: [
                    "毎食20g以上のタンパク質を摂る",
                    "朝食を抜かない（プロテインだけでもOK）",
                    "タンパク源（肉・魚・卵・大豆）を把握する",
                    "トレーニング前後の栄養補給を意識する",
                    "トレ後30分以内にタンパク質を摂る",
                    "高負荷日と休息日で食事を変える"
                ],
                donts: [
                    "炭水化物を極端に減らさない",
                    "トレーニング日に炭水化物を減らしすぎない",
                    "休息日にタンパク質量を落とさない"
                ]
            )

        case 90:
            return CourseFocus(
                duration: 90,
                weeks: 12,
                concept: "高タンパクを一生モノの習慣に",
                pfc: PFCRatio(protein: 35, fat: 30, carbs: 35),
                dos: [
                    "毎食20g以上のタンパク質を摂る",
                    "朝食を抜かない（プロテインだけでもOK）",
                    "トレ後30分以内にタンパク質を摂る",
                    "外食時も「まずタンパク源」を選ぶ",
                    "週1回は体重・体組成をチェックする",
                    "食材のバリエーションを増やす",
                    "プログラム後も続ける「Myルール」を作る"
                ],
                donts: [
                    "炭水化物を極端に減らさない",
                    "トレーニング日に炭水化物を減らしすぎない",
                    "飲み会翌日にリカバリー食を忘れない",
                    "マンネリで同じメニューばかりにしない"
                ]
            )

        default:
            // デフォルトは30日コース
            return getFocus(duration: 30)
        }
    }

    // MARK: - Get Roadmap Phases

    /// コース別のロードマップフェーズを取得
    static func getPhases(duration: Int) -> [RoadmapPhase] {
        switch duration {
        case 30:
            return phases30Days
        case 45:
            return phases45Days
        case 90:
            return phases90Days
        default:
            return phases30Days
        }
    }

    // MARK: - 30 Days (4 Weeks)

    private static let phases30Days: [RoadmapPhase] = [
        RoadmapPhase(
            weekNumber: 1,
            dayRange: "Day 1-7",
            title: "現状把握 & タンパク質チェック",
            subtitle: "今の食事パターンとタンパク質量を「見える化」",
            focusPoints: [
                "毎日最低1回食事をログする",
                "タンパク質量を数字で把握する"
            ]
        ),
        RoadmapPhase(
            weekNumber: 2,
            dayRange: "Day 8-14",
            title: "タンパク質ベースライン",
            subtitle: "1日のタンパク質を体重1.4〜1.6g/kg/dayに",
            focusPoints: [
                "合計タンパク質量を毎日確認する",
                "不足時はプロテインで補う"
            ]
        ),
        RoadmapPhase(
            weekNumber: 3,
            dayRange: "Day 15-21",
            title: "朝食タンパク質強化",
            subtitle: "朝から20〜25gのタンパク質を入れる",
            focusPoints: [
                "朝食メニューを見直す",
                "卵・ヨーグルト・プロテインを活用"
            ]
        ),
        RoadmapPhase(
            weekNumber: 4,
            dayRange: "Day 22-30",
            title: "全食タンパク質均等化",
            subtitle: "朝・昼・夜＋間食で25〜30gずつ均等配分",
            focusPoints: [
                "1食あたりのタンパク質量を意識",
                "間食にも高タンパクを取り入れる"
            ]
        )
    ]

    // MARK: - 45 Days (6 Weeks)

    private static let phases45Days: [RoadmapPhase] = [
        // Week 1-4: 30日コースと同じ
        RoadmapPhase(
            weekNumber: 1,
            dayRange: "Day 1-7",
            title: "現状把握 & タンパク質チェック",
            subtitle: "今の食事パターンとタンパク質量を「見える化」",
            focusPoints: [
                "毎日最低1回食事をログする",
                "タンパク質量を数字で把握する"
            ]
        ),
        RoadmapPhase(
            weekNumber: 2,
            dayRange: "Day 8-14",
            title: "タンパク質ベースライン",
            subtitle: "1日のタンパク質を体重1.4〜1.6g/kg/dayに",
            focusPoints: [
                "合計タンパク質量を毎日確認する",
                "不足時はプロテインで補う"
            ]
        ),
        RoadmapPhase(
            weekNumber: 3,
            dayRange: "Day 15-21",
            title: "朝食タンパク質強化",
            subtitle: "朝から20〜25gのタンパク質を入れる",
            focusPoints: [
                "朝食メニューを見直す",
                "卵・ヨーグルト・プロテインを活用"
            ]
        ),
        RoadmapPhase(
            weekNumber: 4,
            dayRange: "Day 22-28",
            title: "全食タンパク質均等化",
            subtitle: "朝・昼・夜＋間食で25〜30gずつ均等配分",
            focusPoints: [
                "1食あたりのタンパク質量を意識",
                "間食にも高タンパクを取り入れる"
            ]
        ),
        // Week 5-6: トレーニング連携
        RoadmapPhase(
            weekNumber: 5,
            dayRange: "Day 29-36",
            title: "トレーニング連携①",
            subtitle: "トレ前後の「ガソリン補給」パターンを覚える",
            focusPoints: [
                "トレ前に炭水化物を入れる",
                "トレ後30分以内にタンパク質を摂る"
            ]
        ),
        RoadmapPhase(
            weekNumber: 6,
            dayRange: "Day 37-45",
            title: "トレーニング連携②",
            subtitle: "「追い込む日」と「回復させる日」を食事でコントロール",
            focusPoints: [
                "高負荷日はカロリーを増やす",
                "休息日もタンパク質量はキープ"
            ]
        )
    ]

    // MARK: - 90 Days (12 Weeks)

    private static let phases90Days: [RoadmapPhase] = [
        // Week 1-6: 45日コースと同じ
        RoadmapPhase(
            weekNumber: 1,
            dayRange: "Day 1-7",
            title: "現状把握 & タンパク質チェック",
            subtitle: "今の食事パターンとタンパク質量を「見える化」",
            focusPoints: [
                "毎日最低1回食事をログする",
                "タンパク質量を数字で把握する"
            ]
        ),
        RoadmapPhase(
            weekNumber: 2,
            dayRange: "Day 8-14",
            title: "タンパク質ベースライン",
            subtitle: "1日のタンパク質を体重1.4〜1.6g/kg/dayに",
            focusPoints: [
                "合計タンパク質量を毎日確認する",
                "不足時はプロテインで補う"
            ]
        ),
        RoadmapPhase(
            weekNumber: 3,
            dayRange: "Day 15-21",
            title: "朝食タンパク質強化",
            subtitle: "朝から20〜25gのタンパク質を入れる",
            focusPoints: [
                "朝食メニューを見直す",
                "卵・ヨーグルト・プロテインを活用"
            ]
        ),
        RoadmapPhase(
            weekNumber: 4,
            dayRange: "Day 22-28",
            title: "全食タンパク質均等化",
            subtitle: "朝・昼・夜＋間食で25〜30gずつ均等配分",
            focusPoints: [
                "1食あたりのタンパク質量を意識",
                "間食にも高タンパクを取り入れる"
            ]
        ),
        RoadmapPhase(
            weekNumber: 5,
            dayRange: "Day 29-35",
            title: "トレーニング連携①",
            subtitle: "トレ前後の「ガソリン補給」パターンを覚える",
            focusPoints: [
                "トレ前に炭水化物を入れる",
                "トレ後30分以内にタンパク質を摂る"
            ]
        ),
        RoadmapPhase(
            weekNumber: 6,
            dayRange: "Day 36-42",
            title: "トレーニング連携②",
            subtitle: "「追い込む日」と「回復させる日」を食事でコントロール",
            focusPoints: [
                "高負荷日はカロリーを増やす",
                "休息日もタンパク質量はキープ"
            ]
        ),
        // Week 7-12: 応用・定着フェーズ
        RoadmapPhase(
            weekNumber: 7,
            dayRange: "Day 43-49",
            title: "外食・飲み会対応",
            subtitle: "崩れやすい場面でも最低限守るライン",
            focusPoints: [
                "外食時は「まずタンパク源」を選ぶ",
                "飲み会翌日のリカバリー食を意識"
            ]
        ),
        RoadmapPhase(
            weekNumber: 8,
            dayRange: "Day 50-56",
            title: "パターンのバリエーション",
            subtitle: "食材・メニューのバリエーションを増やす",
            focusPoints: [
                "新しいタンパク源を試す",
                "マンネリ防止のレシピを追加"
            ]
        ),
        RoadmapPhase(
            weekNumber: 9,
            dayRange: "Day 57-63",
            title: "微調整①（体重・見た目）",
            subtitle: "体重・見た目から「効き具合」を判断",
            focusPoints: [
                "週1回は体重・体組成をチェック",
                "変化に応じてPFCを微調整"
            ]
        ),
        RoadmapPhase(
            weekNumber: 10,
            dayRange: "Day 64-70",
            title: "微調整②（体調・パフォ）",
            subtitle: "眠気・集中力からPFCバランスを調整",
            focusPoints: [
                "午後の眠気をチェック",
                "トレーニングパフォーマンスを確認"
            ]
        ),
        RoadmapPhase(
            weekNumber: 11,
            dayRange: "Day 71-77",
            title: "定着＆出口戦略①",
            subtitle: "プログラム後も続けられる「ふだんモード」設計",
            focusPoints: [
                "自分に合った継続パターンを見つける",
                "「最低限これだけ」ルールを決める"
            ]
        ),
        RoadmapPhase(
            weekNumber: 12,
            dayRange: "Day 78-90",
            title: "定着＆出口戦略②",
            subtitle: "イベント週でも大崩れしない「Myルール」作成",
            focusPoints: [
                "旅行・イベント時の対応策を決める",
                "プログラム後の「Myルール」を完成させる"
            ]
        )
    ]
}
