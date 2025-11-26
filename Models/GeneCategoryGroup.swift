//
//  GeneCategoryGroup.swift
//  TUUN
//
//  大カテゴリー（ダイエット・生活習慣・運動・長寿）のグループ定義
//

import Foundation

/// 大カテゴリーグループ
struct GeneCategoryGroup: Identifiable {
    let id = UUID()
    let name: String           // 大カテゴリー名
    let icon: String           // アイコン名
    let markers: [GeneDataService.GeneticMarker]  // 含まれる小カテゴリー

    /// 平均スコア（小カテゴリーの平均）
    var averageScore: Int {
        guard !markers.isEmpty else { return 0 }
        let totalScore = markers.compactMap { $0.cachedImpact?.score }.reduce(0, +)
        return totalScore / max(markers.count, 1)
    }

    /// スコアレベル
    var scoreLevel: ScoreLevel {
        switch averageScore {
        case 20...100:
            return .excellent
        case 1...19:
            return .good
        case -19...0:
            return .normal
        default:
            return .needsSupport
        }
    }

    /// タイプ名（スコアに基づく）
    var typeName: String {
        return GeneCategoryGroup.typeNames[name]?[scoreLevel] ?? "\(name)標準型"
    }

    /// 遺伝子説明（スコアに基づく）
    var description: String {
        return GeneCategoryGroup.descriptions[name]?[scoreLevel] ?? ""
    }

    // MARK: - スコアレベル定義

    enum ScoreLevel: String {
        case excellent = "優位型"
        case good = "やや優位型"
        case normal = "標準型"
        case needsSupport = "要サポート型"
    }

    // MARK: - 大カテゴリー定義

    /// 大カテゴリーと小カテゴリーのマッピング
    static let categoryMapping: [String: [String]] = [
        "ダイエット": [
            "基礎代謝",
            "除脂肪体重",
            "内臓脂肪",
            "食欲の調節力（レプチン値）",
            "インスリン抵抗性",
            "中性脂肪（血中濃度）",
            "LDLコレステロール（血中濃度）",
            "HDLコレステロール（血中濃度）",
            "アディポネクチン値",
            "脂質（血中濃度）",
            "高脂肪ダイエット効果",
            "高たんぱくダイエット効果",
            "不飽和脂肪酸の摂取効果"
        ],
        "生活習慣": [
            "眠りの深さ",
            "入眠潜時",
            "概日リズム",
            "昼間の眠気",
            "カフェイン代謝",
            "レジリエンス（精神的回復力）"
        ],
        "運動": [
            "筋肉の発達",
            "筋持久力",
            "瞬発力"
        ],
        "長寿": [
            "テロメアの長さ（細胞老化の指標）",
            "90歳以上まで生きる可能性",
            "抗酸化力",
            "hsCRP値 (免疫系疾患の指標）",
            "IL-18値 (免疫系疾患の指標）",
            "補体C3/C4値 (免疫系疾患の指標）"
        ]
    ]

    /// カテゴリーの表示順序
    static let categoryOrder: [String] = ["ダイエット", "生活習慣", "運動", "長寿"]

    /// カテゴリーアイコン
    static let categoryIcons: [String: String] = [
        "ダイエット": "flame.fill",
        "生活習慣": "moon.stars.fill",
        "運動": "figure.run",
        "長寿": "heart.fill"
    ]

    // MARK: - タイプ名定義

    static let typeNames: [String: [ScoreLevel: String]] = [
        "ダイエット": [
            .excellent: "脂肪燃焼優位型",
            .good: "代謝やや良好型",
            .normal: "代謝バランス型",
            .needsSupport: "代謝サポート必要型"
        ],
        "生活習慣": [
            .excellent: "睡眠・リズム最適型",
            .good: "生活リズムやや良好型",
            .normal: "生活習慣標準型",
            .needsSupport: "生活習慣サポート必要型"
        ],
        "運動": [
            .excellent: "運動能力優位型",
            .good: "運動能力やや優位型",
            .normal: "運動能力標準型",
            .needsSupport: "運動サポート必要型"
        ],
        "長寿": [
            .excellent: "長寿遺伝子優位型",
            .good: "長寿因子やや優位型",
            .normal: "長寿因子標準型",
            .needsSupport: "抗老化サポート必要型"
        ]
    ]

    // MARK: - 遺伝子説明定義

    static let descriptions: [String: [ScoreLevel: String]] = [
        "ダイエット": [
            .excellent: "あなたの遺伝子は代謝・脂質に関連するSNPで保護的な変異が多く見られます。基礎代謝が高く、脂質をエネルギーに効率的に変換できる傾向があります。食事コントロールの効果が出やすい遺伝的背景です。",
            .good: "あなたの遺伝子は代謝・脂質に関連するSNPでやや優位な変異が見られます。適切な食事管理と運動を組み合わせることで、効果的なダイエットが期待できます。",
            .normal: "あなたの遺伝子は代謝・脂質に関連するSNPで標準的な傾向を示しています。バランスの取れた食事と適度な運動で、健康的な体重管理が可能です。",
            .needsSupport: "あなたの遺伝子は代謝・脂質に関連するSNPでリスク変異がやや多く見られます。脂質の蓄積や血糖値の管理に注意が必要な傾向があります。適切な食事管理と運動で十分にコントロール可能です。"
        ],
        "生活習慣": [
            .excellent: "あなたの遺伝子は睡眠・生体リズムに関連するSNPで優位な変異が多く見られます。深い睡眠を取りやすく、カフェイン代謝も良好で、ストレスからの回復力も高い遺伝的背景を持っています。",
            .good: "あなたの遺伝子は睡眠・生体リズムに関連するSNPでやや優位な傾向があります。規則正しい生活リズムを維持することで、より良い睡眠の質を保てます。",
            .normal: "あなたの遺伝子は睡眠・生体リズムに関連するSNPで標準的な傾向を示しています。規則正しい睡眠習慣を心がけることで、健康的な生活リズムを維持できます。",
            .needsSupport: "あなたの遺伝子は睡眠・生体リズムに関連するSNPでリスク変異がやや多く見られます。睡眠の質や概日リズムの維持に意識的なケアが効果的です。規則正しい生活習慣で大きく改善できます。"
        ],
        "運動": [
            .excellent: "あなたの遺伝子は筋肉・運動能力に関連するSNPで優位な変異が多く見られます。筋トレに対する反応が良く、筋肥大しやすい遺伝的背景です。適切なトレーニングで効率的に筋力アップが期待できます。",
            .good: "あなたの遺伝子は筋肉・運動能力に関連するSNPでやや優位な傾向があります。継続的なトレーニングで着実に運動能力を向上させることができます。",
            .normal: "あなたの遺伝子は筋肉・運動能力に関連するSNPで標準的な傾向を示しています。バランスの取れたトレーニングプログラムで、健康的な筋力維持が可能です。",
            .needsSupport: "あなたの遺伝子は筋肉・運動能力に関連するSNPでリスク変異がやや多く見られます。筋肉の発達に時間がかかる傾向がありますが、継続的なトレーニングと適切な栄養摂取で十分に成果が出せます。"
        ],
        "長寿": [
            .excellent: "あなたの遺伝子は長寿・抗老化に関連するSNPで保護的な変異が多く見られます。テロメアの長さや抗酸化力に優れた遺伝的背景を持ち、細胞の老化スピードが緩やかな傾向があります。",
            .good: "あなたの遺伝子は長寿・抗老化に関連するSNPでやや優位な傾向があります。健康的な生活習慣を維持することで、その遺伝的利点を最大限に活かせます。",
            .normal: "あなたの遺伝子は長寿・抗老化に関連するSNPで標準的な傾向を示しています。バランスの取れた食事と適度な運動で、健康寿命を延ばすことができます。",
            .needsSupport: "あなたの遺伝子は長寿・抗老化に関連するSNPでリスク変異がやや多く見られます。抗酸化物質の摂取や炎症を抑える生活習慣が特に効果的です。日々のケアで細胞の健康を維持できます。"
        ]
    ]
}
