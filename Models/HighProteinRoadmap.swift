//
//  HighProteinRoadmap.swift
//  FUUD
//
//  High-Protein Program Roadmap Data (30/45/90日コース)
//  通常版 / pro版（血液検査ベース）対応
//

import Foundation

// MARK: - Program Mode

/// プログラムモード（通常版 / pro版）
enum ProgramMode: String, CaseIterable {
    case standard = "standard"
    case pro = "pro"

    var displayName: String {
        switch self {
        case .standard: return "通常版"
        case .pro: return "pro版"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "検査なしでも高タンパク習慣を身につけられる標準コースです。"
        case .pro:
            return "血液検査データをもとに、あなた専用の微調整アドバイスが追加されます。"
        }
    }
}

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
    let userBenefit: String     // ユーザーのメリット
    let focusPoints: [String]   // 具体的なタスク（2-4個）
    let proNotes: [String]      // pro版用：血液データに基づく微調整コメント

    init(
        weekNumber: Int,
        dayRange: String,
        title: String,
        subtitle: String,
        userBenefit: String,
        focusPoints: [String],
        proNotes: [String] = []
    ) {
        self.id = "week-\(weekNumber)"
        self.weekNumber = weekNumber
        self.dayRange = dayRange
        self.title = title
        self.subtitle = subtitle
        self.userBenefit = userBenefit
        self.focusPoints = focusPoints
        self.proNotes = proNotes
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
                concept: "高タンパクの型＋活動量連携",
                pfc: PFCRatio(protein: 35, fat: 30, carbs: 35),
                dos: [
                    "毎食20g以上のタンパク質を摂る",
                    "朝食を抜かない（プロテインだけでもOK）",
                    "タンパク源（肉・魚・卵・大豆）を把握する",
                    "活動量に合わせてエネルギー配分を変える",
                    "週の中でメリハリをつける"
                ],
                donts: [
                    "炭水化物を極端に減らさない",
                    "動きが多い日に炭水化物を減らしすぎない",
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
                    "活動量に合わせてエネルギー配分を変える",
                    "週1回は体重・体組成をチェックする",
                    "食材のバリエーションを増やす",
                    "プログラム後も続ける「Myルール」を作る"
                ],
                donts: [
                    "炭水化物を極端に減らさない",
                    "動きが多い日に炭水化物を減らしすぎない",
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
            return Array(masterPhases.prefix(4))  // Week 1-4
        case 45:
            return Array(masterPhases.prefix(6))  // Week 1-6
        case 90:
            return masterPhases                    // Week 1-12
        default:
            return Array(masterPhases.prefix(4))
        }
    }

    // MARK: - Master Phases (Week 1-12)

    /// Week 1-12 マスターロードマップ
    private static let masterPhases: [RoadmapPhase] = [
        // MARK: Week 1
        RoadmapPhase(
            weekNumber: 1,
            dayRange: "Day 1-7",
            title: "今の自分を可視化する週",
            subtitle: "カラダの燃料を変える前に、まずは「今の状態」を正しく知る",
            userBenefit: "自分が普段どれくらいタンパク質を摂れているのか、感覚ではなく「数字」で分かる",
            focusPoints: [
                "毎日1回は食事を記録（写真でもOK）",
                "ざっくりでいいので「今日のタンパク質何gくらい？」をメモする",
                "毎朝同じ時間に体重を測る（起床後・トイレ後など）"
            ],
            proNotes: [
                "HbA1c高め → 記録時に「糖質量」も軽くメモしておくと後で比較しやすい",
                "TG/LDL高め → 「脂質の種類（揚げ物・加工肉・良質脂質）」も併せて記録",
                "Ferritin低め → 食事量が極端に少ない日がないかチェック"
            ]
        ),

        // MARK: Week 2
        RoadmapPhase(
            weekNumber: 2,
            dayRange: "Day 8-14",
            title: "タンパク質を「狙って」摂る週",
            subtitle: "「なんとなく」から卒業して、1日のタンパク質目標値に寄せていく",
            userBenefit: "「このくらい食べればOK」が明確になり、迷いが減る",
            focusPoints: [
                "目標：体重 × 1.4〜1.6 g/kg/day（例：70kg → 100〜110g/日）",
                "毎日、合計タンパク質が目標の80%以上になるよう意識する",
                "タンパク質がほぼゼロの食事は1日1回までにする"
            ],
            proNotes: [
                "HbA1c高め → 減量ペースを緩める／極端な低糖質を避ける",
                "TG/LDL高め → 脂質の質を強く意識（揚げ物・加工肉→焼き/蒸し中心）",
                "Ferritin低め → 無理なカロリーカットやハード有酸素と組み合わせない",
                "CRP高め → 抗炎症食材（青魚・ナッツ・緑黄色野菜）を意識して追加"
            ]
        ),

        // MARK: Week 3
        RoadmapPhase(
            weekNumber: 3,
            dayRange: "Day 15-21",
            title: "朝からスイッチを入れる週",
            subtitle: "朝からタンパク質をしっかり入れて、1日のスタートの質を上げる",
            userBenefit: "朝〜昼のだるさやドカ食いが減り、日中のエネルギーが安定しやすくなる",
            focusPoints: [
                "朝食でタンパク質20〜25gを毎日入れる（例：卵2個＋ヨーグルト）",
                "朝食パターンを1〜2種類に絞って、朝の「何食べよう…」をなくす",
                "朝食抜きは「本当に時間がない日」だけにして、その日はプロテインだけでも必ず飲む"
            ],
            proNotes: [
                "HbA1c高め → 朝食は低GI炭水化物（オートミール等）＋タンパク質の組み合わせを優先",
                "TG/LDL高め → 朝食に卵を使う場合、調理法は茹で・ポーチドを中心に",
                "Ferritin低め → 朝食にレバー入りの料理や鉄強化ヨーグルトを取り入れる"
            ]
        ),

        // MARK: Week 4
        RoadmapPhase(
            weekNumber: 4,
            dayRange: "Day 22-28",
            title: "1日を通してタンパク質をキープする週",
            subtitle: "朝・昼・夜＋間食で、タンパク質を均等に配る感覚を掴む",
            userBenefit: "空腹の波が穏やかになり、暴食や夜のドカ食いが減る",
            focusPoints: [
                "各食事でタンパク質25〜30gを目標にする",
                "間食を「甘いお菓子だけ」から、「タンパク源＋少量脂質（ナッツ等）」に1回入れ替える",
                "1日の終わりに「どの時間帯でタンパク質が足りなかったか」を振り返る"
            ],
            proNotes: [
                "HbA1c高め → 間食は低GI＋タンパク質（チーズ・ナッツ・ゆで卵）を優先",
                "TG/LDL高め → 間食で脂質の多いスナック（ポテチ等）を避ける",
                "Ferritin低め → 夕食にはヘム鉄源（赤身肉・魚）を毎日入れる",
                "CRP高め → 夜の炭水化物を白米→雑穀米・オートミールに置き換え"
            ]
        ),

        // MARK: Week 5
        RoadmapPhase(
            weekNumber: 5,
            dayRange: "Day 29-35",
            title: "活動量に合わせてエネルギーを配る週",
            subtitle: "「よく動く日」と「ほぼ座りっぱなしの日」で、食べ方を少し変えてみる",
            userBenefit: "ジムに行かなくても、仕事や生活の「忙しさ」に合わせて燃費の良い食べ方ができるようになる",
            focusPoints: [
                "1週間の中で「動きが多い日」と「少ない日」をざっくりラベルづけする",
                "動きが多い日は：昼〜夕方の炭水化物を少し増やす／タンパク質はいつもどおり",
                "動きが少ない日は：炭水化物を少し控えめにし、その分タンパク質と野菜を増やす",
                "日の終わりの「疲れ具合・空腹具合」を軽くメモする"
            ],
            proNotes: [
                "HbA1c高め → 動きが多い日でも低GI炭水化物を優先",
                "TG/LDL高め → 動きが多い日でも高脂質ジャンクでの補給は避ける",
                "Ferritin低め → 動きが多い日の前後は「しっかり食べて回復」を優先",
                "CRP高め → 活動後の炎症を抑えるため、抗酸化食材（ベリー類・緑茶）を追加"
            ]
        ),

        // MARK: Week 6
        RoadmapPhase(
            weekNumber: 6,
            dayRange: "Day 36-42",
            title: "1週間の中でメリハリをつける週",
            subtitle: "「毎日100点」ではなく、がんばる日とゆるめる日を自分で設計する",
            userBenefit: "休み方を決めておくことで、自己嫌悪の少ないダイエットになる",
            focusPoints: [
                "週の中で「集中デー」を2〜3日、「ゆるめデー」を1〜2日決める",
                "集中デー：高タンパクをきっちり守る／炭水化物・脂質の「質」も意識",
                "ゆるめデー：タンパク質だけは各食で確保（P源1つ以上）／他はあまり縛らず楽しむ",
                "集中デーとゆるめデーで、体重・体調・メンタルの変化をなんとなく確認"
            ],
            proNotes: [
                "HbA1c高め → 「ゆるめデー」でも糖質の「質」は守る（白砂糖・精製糖質を避ける）",
                "TG/LDL高め → 「ゆるめデー」でも揚げ物・加工肉は1回までに",
                "Ferritin低め → 「集中デー」でも鉄源を必ず1日1回以上",
                "CRP高め → 「ゆるめデー」にアルコールを飲む場合は1〜2杯まで"
            ]
        ),

        // MARK: Week 7
        RoadmapPhase(
            weekNumber: 7,
            dayRange: "Day 43-49",
            title: "代謝ブースト週間",
            subtitle: "「同じ生活でも、燃えやすいカラダに寄せていく」週",
            userBenefit: "同じ食事量でも「燃え方が違う」感覚が出てくる",
            focusPoints: [
                "1日の歩数・立っている時間を少しだけ増やす（+2000歩、階段を選ぶ等）",
                "ビタミンB群・マグネシウム・鉄など「エネルギー産生に必要な栄養」を含む食材を1日1回以上",
                "カフェイン・緑茶のタイミングを「午後のだるくなる時間帯」に寄せる（飲みすぎ注意）"
            ],
            proNotes: [
                "HbA1c高め → カフェインで血糖が上がりやすい人は緑茶・ほうじ茶を選ぶ",
                "TG/LDL高め → ビタミンB群を含む食材で脂質代謝をサポート（豚肉・卵・納豆）",
                "Ferritin低め → 歩数を増やしすぎると鉄消費が増えるので、+1500歩程度に抑える",
                "CRP高め → NEAT増加で炎症が悪化しないよう、抗炎症食材を1日2回以上"
            ]
        ),

        // MARK: Week 8
        RoadmapPhase(
            weekNumber: 8,
            dayRange: "Day 50-56",
            title: "スタミナが切れにくいカラダを作る週",
            subtitle: "「午後〜夜のパフォーマンスを落とさない」ための栄養と食べ方を試す",
            userBenefit: "仕事終わりやトレーニング後でもエネルギーが残りやすくなる",
            focusPoints: [
                "青魚・ナッツ・オリーブオイルなど、良質な脂質を1日1回以上",
                "活動量が多い日の前後で、炭水化物の質（低GI＋一部速やかに使える糖質）を意識する",
                "水分と電解質（カリウム/マグネシウム/ナトリウム）を意識し、「だるさ・頭痛・むくみ」が減るか観察"
            ],
            proNotes: [
                "HbA1c高め → 糖質は「活動直前・直後」に集中させ、それ以外は低GI中心",
                "TG/LDL高め → 良質脂質は青魚・オリーブオイル・ナッツに絞る",
                "Ferritin低め → 活動量が多い日は鉄吸収を高めるビタミンC（柑橘類）と一緒に",
                "CRP高め → 電解質補給は自然食材（バナナ・アボカド・海藻）から"
            ]
        ),

        // MARK: Week 9
        RoadmapPhase(
            weekNumber: 9,
            dayRange: "Day 57-63",
            title: "筋肉がちゃんと働くカラダに整える週",
            subtitle: "「筋肉とホルモンが働きやすい環境」を食事で整える",
            userBenefit: "トレ翌日の回復速度・筋肉痛の残り方が変わる／日中のだるさが減る",
            focusPoints: [
                "ω3脂肪酸（青魚）と飽和脂肪酸（肉・バター等）のバランスを意識",
                "夕食を「消化の軽いタンパク質＋低GI炭水化物」に寄せて、睡眠の質を観察",
                "マグネシウム・亜鉛を含む食品（ナッツ・全粒穀物・貝類など）を増やす"
            ],
            proNotes: [
                "HbA1c高め → 夕食の炭水化物は睡眠に必要な最低限に",
                "TG/LDL高め → ω3脂肪酸を毎日摂る（青魚 or フィッシュオイル）",
                "Ferritin低め → マグネシウム・亜鉛と一緒に鉄も意識（貝類・レバー）",
                "CRP高め → 睡眠の質を高めて回復力UP（夕食は消化の良いタンパク質中心）"
            ]
        ),

        // MARK: Week 10
        RoadmapPhase(
            weekNumber: 10,
            dayRange: "Day 64-70",
            title: "腸に優しい高タンパクを覚える週",
            subtitle: "高タンパクでも「お腹がきつくならない食べ方」を見つける",
            userBenefit: "お腹の不快感が減り、長期的に続けやすくなる",
            focusPoints: [
                "発酵食品（納豆・キムチ・ヨーグルト・味噌汁）を毎日1回以上",
                "食物繊維（野菜・海藻・オートミール・果物）を毎食意識して入れる",
                "肉・プロテイン多めの日には、スープ＋野菜をセットにして腸の負担を下げる"
            ],
            proNotes: [
                "HbA1c高め → 発酵食品の中でも低糖質なもの（納豆・キムチ・味噌）を選ぶ",
                "TG/LDL高め → 食物繊維で脂質の吸収を緩やかに（海藻・こんにゃく）",
                "Ferritin低め → 腸内環境を整えて鉄の吸収効率を上げる（乳酸菌・ビフィズス菌）",
                "CRP高め → 腸内炎症を抑える発酵食品と食物繊維を毎食意識"
            ]
        ),

        // MARK: Week 11
        RoadmapPhase(
            weekNumber: 11,
            dayRange: "Day 71-77",
            title: "見た目を整える微調整週",
            subtitle: "「体重」よりも「鏡に映る自分・服のフィット感」を整える1週間",
            userBenefit: "体重が同じでも、「痩せた？」と言われる変化を狙いやすくなる",
            focusPoints: [
                "ウエスト・ヒップ・太ももなど、気になる部位を測る",
                "夜の炭水化物を少し減らして、むくみ・ラインの変化を観察する",
                "むくみ対策（塩分控えめ＋カリウム豊富な食材：バナナ・ほうれん草など）を取り入れる"
            ],
            proNotes: [
                "HbA1c高め → むくみ対策で糖質を減らしすぎると血糖不安定になるので注意",
                "TG/LDL高め → むくみ対策の塩分カットと併せて良質脂質は維持",
                "Ferritin低め → カリウム豊富な食材（バナナ・ほうれん草）で鉄も補給",
                "CRP高め → 炎症によるむくみも考慮し、抗炎症食材を継続"
            ]
        ),

        // MARK: Week 12
        RoadmapPhase(
            weekNumber: 12,
            dayRange: "Day 78-90",
            title: "代謝の「土台栄養」を整える週",
            subtitle: "タンパク＋PFCだけでなく、「ビタミン・ミネラルなどの不足しやすい栄養を底上げ」する",
            userBenefit: "検査をしていなくても、「大きな栄養ギャップを徐々に埋めている」安心感が得られる",
            focusPoints: [
                "1週間で「色の違う野菜を5〜7色」食べるチャレンジ",
                "鉄・マグネシウム・亜鉛・ビタミンD を含む食品（レバー・貝・青魚・きのこ等）をローテーション",
                "「今後も続けたい食材/メニューTOP5」を決める"
            ],
            proNotes: [
                "【全マーカー共通】スタート時点と比較して、どのマーカーが改善したか振り返る",
                "HbA1c高め → 糖質の「質」の習慣化を「Myルール」に入れる",
                "TG/LDL高め → 脂質の「質」の習慣化を「Myルール」に入れる",
                "Ferritin低め → 鉄源ローテーション（レバー・貝・赤身肉）を「Myルール」に",
                "CRP高め → 抗炎症食材の習慣化を「Myルール」に入れる"
            ]
        )
    ]
}
