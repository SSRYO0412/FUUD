//
//  DietProgramCatalog.swift
//  FUUD
//
//  v1: App-embedded program catalog (no DynamoDB)
//

import Foundation

/// v1: アプリ内固定のプログラムカタログ
struct DietProgramCatalog {

    // MARK: - Program Catalog

    static let programs: [DietProgram] = [

        // MARK: - 1. Calibration (TDEE測定)
        DietProgram(
            id: "calibration",
            nameJa: "キャリブレーション",
            nameEn: "Calibration",
            category: .biohacking,
            description: "まずは2週間、正確なTDEEを測定するためのプログラム。体重変動と食事記録から、あなた固有の代謝量を算出します。",
            descriptionEn: "Measure your precise TDEE over 2 weeks. Calculate your unique metabolism from weight changes and food logs.",
            difficulty: .beginner,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "cal-w1",
                    weekNumber: 1,
                    name: "測定期間 前半",
                    nameEn: "Measurement Phase 1",
                    description: "毎日の食事を正確に記録し、体重を測定します",
                    focusPoints: [
                        "毎日同じ時間に体重測定",
                        "全ての食事を記録",
                        "水分摂取量も記録"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "cal-w2",
                    weekNumber: 2,
                    name: "測定期間 後半",
                    nameEn: "Measurement Phase 2",
                    description: "引き続き記録を継続し、精度を高めます",
                    focusPoints: [
                        "記録の習慣を定着",
                        "外食時も推定カロリーを記録",
                        "週末も記録を継続"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "cal-b1", mealType: .breakfast, name: "バランス朝食", nameEn: "Balanced Breakfast", calories: 400, protein: 20, fat: 15, carbs: 50, imageURL: nil),
                SampleMeal(id: "cal-l1", mealType: .lunch, name: "定食スタイル昼食", nameEn: "Set Meal Lunch", calories: 600, protein: 25, fat: 20, carbs: 70, imageURL: nil),
                SampleMeal(id: "cal-d1", mealType: .dinner, name: "和食中心夕食", nameEn: "Japanese Style Dinner", calories: 550, protein: 30, fat: 18, carbs: 60, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["測定", "基礎", "初心者", "TDEE"],
            features: [
                "正確なTDEE測定",
                "食事記録の習慣化",
                "自分の代謝を知る"
            ],
            expectedResults: [
                "TDEE精度向上",
                "食事記録スキル習得",
                "自己理解の深化"
            ],
            imageURL: nil,
            layer: .calibration,
            canStackWithFasting: false,
            canStackWithFocus: false
        ),

        // MARK: - 2. 28日低糖質チャレンジ
        DietProgram(
            id: "low-carb-28",
            nameJa: "28日低糖質チャレンジ",
            nameEn: "28-Day Low Carb Challenge",
            category: .lowCarb,
            description: "4週間で糖質を段階的に減らし、脂肪燃焼体質への切り替えを促進。インスリン感受性の改善も期待できます。",
            descriptionEn: "Gradually reduce carbs over 4 weeks to promote fat-burning. Expect improved insulin sensitivity.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.15,
            basePFC: .lowCarb,
            phases: [
                ProgramPhase(
                    id: "lc28-w1",
                    weekNumber: 1,
                    name: "導入期",
                    nameEn: "Introduction",
                    description: "糖質を徐々に減らし始める",
                    focusPoints: [
                        "糖質は1食40g以下を目標",
                        "白米→玄米に切り替え",
                        "間食の糖質を見直す"
                    ],
                    calorieMultiplier: 0.9,
                    pfcOverride: PFCRatio(protein: 28, fat: 40, carbs: 32)
                ),
                ProgramPhase(
                    id: "lc28-w2",
                    weekNumber: 2,
                    name: "適応期",
                    nameEn: "Adaptation",
                    description: "低糖質に体を慣らす",
                    focusPoints: [
                        "糖質は1食30g以下",
                        "タンパク質を意識的に増やす",
                        "良質な脂質を積極的に摂取"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: PFCRatio(protein: 30, fat: 45, carbs: 25)
                ),
                ProgramPhase(
                    id: "lc28-w3",
                    weekNumber: 3,
                    name: "加速期",
                    nameEn: "Acceleration",
                    description: "脂肪燃焼を促進",
                    focusPoints: [
                        "糖質は1食25g以下",
                        "MCTオイルの活用",
                        "野菜でボリューム確保"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: .lowCarb
                ),
                ProgramPhase(
                    id: "lc28-w4",
                    weekNumber: 4,
                    name: "維持期",
                    nameEn: "Maintenance",
                    description: "習慣として定着させる",
                    focusPoints: [
                        "低糖質食の継続",
                        "外食時の対処法を実践",
                        "リバウンド防止策を学ぶ"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: .lowCarb
                )
            ],
            sampleMeals: [
                SampleMeal(id: "lc-b1", mealType: .breakfast, name: "卵とアボカドのプレート", nameEn: "Egg & Avocado Plate", calories: 350, protein: 20, fat: 25, carbs: 8, imageURL: nil),
                SampleMeal(id: "lc-l1", mealType: .lunch, name: "サラダチキンボウル", nameEn: "Salad Chicken Bowl", calories: 450, protein: 35, fat: 28, carbs: 15, imageURL: nil),
                SampleMeal(id: "lc-d1", mealType: .dinner, name: "グリルサーモンと野菜", nameEn: "Grilled Salmon with Vegetables", calories: 500, protein: 35, fat: 32, carbs: 12, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "インスリン調整が必要な場合は医師に相談してください"),
                Contraindication(condition: "kidney_disease", severity: .warning, message: "高タンパク食は腎臓に負担がかかる場合があります")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "HbA1c", condition: .above, threshold: 5.6, scoreBoost: 30),
                RecommendCondition(biomarker: "triglycerides", condition: .above, threshold: 150, scoreBoost: 25),
                RecommendCondition(biomarker: "fasting_glucose", condition: .above, threshold: 100, scoreBoost: 20)
            ],
            tags: ["低糖質", "ダイエット", "インスリン", "血糖値"],
            features: [
                "段階的な糖質制限",
                "インスリン感受性の改善",
                "脂肪燃焼の促進",
                "血糖値の安定化"
            ],
            expectedResults: [
                "体脂肪 -3〜5%",
                "HbA1c改善",
                "中性脂肪減少",
                "空腹感の軽減"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 3. 16:8 インターミッテントファスティング
        DietProgram(
            id: "if-16-8",
            nameJa: "16:8 インターミッテントファスティング",
            nameEn: "16:8 Intermittent Fasting",
            category: .fasting,
            description: "1日のうち8時間の食事窓で摂取し、16時間は断食。オートファジーを活性化し、細胞の若返りを促進します。",
            descriptionEn: "Eat within an 8-hour window, fast for 16 hours. Activate autophagy and promote cellular rejuvenation.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.1,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "if-w1",
                    weekNumber: 1,
                    name: "12:12から始める",
                    nameEn: "Start with 12:12",
                    description: "まずは12時間断食に慣れる",
                    focusPoints: [
                        "夜8時以降は食べない",
                        "朝8時以降に朝食",
                        "水・お茶・ブラックコーヒーはOK"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "if-w2",
                    weekNumber: 2,
                    name: "14:10に移行",
                    nameEn: "Transition to 14:10",
                    description: "食事窓を10時間に短縮",
                    focusPoints: [
                        "朝食を10時頃に遅らせる",
                        "夕食は20時までに終える",
                        "空腹感との向き合い方"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "if-w3",
                    weekNumber: 3,
                    name: "16:8達成",
                    nameEn: "Achieve 16:8",
                    description: "本格的な16:8に移行",
                    focusPoints: [
                        "食事窓は8時間以内",
                        "最初の食事でタンパク質を確保",
                        "断食中の電解質補給"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "if-w4",
                    weekNumber: 4,
                    name: "習慣化",
                    nameEn: "Make It a Habit",
                    description: "ライフスタイルとして定着",
                    focusPoints: [
                        "週末も可能な限り継続",
                        "社会的イベントへの対応",
                        "長期継続のコツ"
                    ],
                    calorieMultiplier: 0.9
                )
            ],
            sampleMeals: [
                SampleMeal(id: "if-l1", mealType: .lunch, name: "高タンパク昼食", nameEn: "High Protein Lunch", calories: 600, protein: 40, fat: 25, carbs: 55, imageURL: nil),
                SampleMeal(id: "if-d1", mealType: .dinner, name: "バランス夕食", nameEn: "Balanced Dinner", calories: 650, protein: 35, fat: 28, carbs: 60, imageURL: nil),
                SampleMeal(id: "if-s1", mealType: .snack, name: "ナッツ&チーズ", nameEn: "Nuts & Cheese", calories: 250, protein: 12, fat: 20, carbs: 5, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "摂食障害の既往がある方には推奨しません"),
                Contraindication(condition: "pregnancy", severity: .prohibited, message: "妊娠中・授乳中は推奨しません"),
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "低血糖リスクがあります。医師に相談してください")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "fasting_insulin", condition: .above, threshold: 10, scoreBoost: 25),
                RecommendCondition(biomarker: "CRP", condition: .above, threshold: 1.0, scoreBoost: 20)
            ],
            tags: ["ファスティング", "オートファジー", "断食", "16:8"],
            features: [
                "オートファジー活性化",
                "インスリン感受性改善",
                "集中力向上",
                "シンプルなルール"
            ],
            expectedResults: [
                "体重 -2〜4kg（個人差あり）",
                "空腹感への適応",
                "食事への意識向上",
                "エネルギーレベルの安定"
            ],
            imageURL: nil,
            layer: .timing,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 4. 高タンパクダイエット
        DietProgram(
            id: "high-protein",
            nameJa: "高タンパクダイエット",
            nameEn: "High Protein Diet",
            category: .highProtein,
            description: "タンパク質を体重1kgあたり1.6〜2.0g摂取し、筋肉を維持しながら体脂肪を減らす。運動と組み合わせると効果倍増。",
            descriptionEn: "Consume 1.6-2.0g protein per kg body weight to preserve muscle while losing fat. Even more effective with exercise.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.15,
            basePFC: .highProtein,
            phases: [
                ProgramPhase(
                    id: "hp-w1",
                    weekNumber: 1,
                    name: "タンパク質量の把握",
                    nameEn: "Understanding Protein Intake",
                    description: "現在の摂取量を確認し、目標を設定",
                    focusPoints: [
                        "毎食20g以上のタンパク質",
                        "プロテインソースの把握",
                        "タンパク質計算に慣れる"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "hp-w2",
                    weekNumber: 2,
                    name: "朝食のタンパク質強化",
                    nameEn: "Boost Breakfast Protein",
                    description: "1日の最初にタンパク質を確保",
                    focusPoints: [
                        "朝食で25g以上のタンパク質",
                        "卵、ヨーグルト、プロテインの活用",
                        "朝の空腹感を抑える"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "hp-w3",
                    weekNumber: 3,
                    name: "均等配分",
                    nameEn: "Even Distribution",
                    description: "3食+間食で均等に配分",
                    focusPoints: [
                        "各食事で25-35gを目標",
                        "間食でもタンパク質を意識",
                        "筋トレとの組み合わせ"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "hp-w4",
                    weekNumber: 4,
                    name: "最適化と維持",
                    nameEn: "Optimize & Maintain",
                    description: "体感を確認しながら調整",
                    focusPoints: [
                        "体組成の変化を確認",
                        "タンパク質源のバリエーション",
                        "長期継続のためのコツ"
                    ],
                    calorieMultiplier: 0.85
                )
            ],
            sampleMeals: [
                SampleMeal(id: "hp-b1", mealType: .breakfast, name: "プロテインスムージー", nameEn: "Protein Smoothie", calories: 400, protein: 35, fat: 12, carbs: 40, imageURL: nil),
                SampleMeal(id: "hp-l1", mealType: .lunch, name: "鶏胸肉のグリル定食", nameEn: "Grilled Chicken Breast Set", calories: 550, protein: 45, fat: 18, carbs: 45, imageURL: nil),
                SampleMeal(id: "hp-d1", mealType: .dinner, name: "豆腐ステーキと魚", nameEn: "Tofu Steak & Fish", calories: 500, protein: 40, fat: 22, carbs: 35, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "kidney_disease", severity: .warning, message: "腎機能が低下している場合は医師に相談してください"),
                Contraindication(condition: "gout", severity: .warning, message: "痛風の方はプリン体含有量に注意してください")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "albumin", condition: .below, threshold: 4.0, scoreBoost: 25),
                RecommendCondition(biomarker: "muscle_mass_percentage", condition: .below, threshold: 35, scoreBoost: 30)
            ],
            tags: ["高タンパク", "筋肉維持", "ダイエット", "運動"],
            features: [
                "筋肉量の維持",
                "代謝の維持・向上",
                "満腹感の持続",
                "食事誘発性熱産生の増加"
            ],
            expectedResults: [
                "体脂肪 -3〜5%",
                "筋肉量維持または増加",
                "基礎代謝の維持",
                "リバウンドしにくい体へ"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 5. メタボリックリセット
        DietProgram(
            id: "metabolic-reset",
            nameJa: "メタボリックリセット",
            nameEn: "Metabolic Reset",
            category: .biohacking,
            description: "長期間のダイエットで低下した代謝を回復。カロリーを段階的に増やしながら、代謝適応をリセットします。",
            descriptionEn: "Recover metabolism lowered by long-term dieting. Gradually increase calories to reset metabolic adaptation.",
            difficulty: .advanced,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "mr-w1",
                    weekNumber: 1,
                    name: "現状把握",
                    nameEn: "Assessment",
                    description: "現在の代謝状態を確認",
                    focusPoints: [
                        "現在のカロリー摂取量を正確に記録",
                        "体重・体温・エネルギーレベルを記録",
                        "ストレスレベルの確認"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "mr-w2",
                    weekNumber: 2,
                    name: "カロリー増加 Phase 1",
                    nameEn: "Calorie Increase Phase 1",
                    description: "+100〜150kcal/日",
                    focusPoints: [
                        "炭水化物を中心に増やす",
                        "体重変動をモニタリング",
                        "むくみと脂肪増加を区別"
                    ],
                    calorieMultiplier: 1.1
                ),
                ProgramPhase(
                    id: "mr-w3",
                    weekNumber: 3,
                    name: "カロリー増加 Phase 2",
                    nameEn: "Calorie Increase Phase 2",
                    description: "さらに+100〜150kcal/日",
                    focusPoints: [
                        "運動パフォーマンスの確認",
                        "睡眠の質をチェック",
                        "ホルモンバランスの安定"
                    ],
                    calorieMultiplier: 1.15
                ),
                ProgramPhase(
                    id: "mr-w4",
                    weekNumber: 4,
                    name: "維持カロリー到達",
                    nameEn: "Reach Maintenance",
                    description: "新しい維持カロリーで安定",
                    focusPoints: [
                        "代謝の回復を実感",
                        "新しいTDEEを確立",
                        "次のステップを計画"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "mr-b1", mealType: .breakfast, name: "オートミールボウル", nameEn: "Oatmeal Bowl", calories: 450, protein: 20, fat: 15, carbs: 60, imageURL: nil),
                SampleMeal(id: "mr-l1", mealType: .lunch, name: "玄米と焼き魚定食", nameEn: "Brown Rice & Grilled Fish Set", calories: 650, protein: 35, fat: 20, carbs: 75, imageURL: nil),
                SampleMeal(id: "mr-d1", mealType: .dinner, name: "パスタと野菜", nameEn: "Pasta with Vegetables", calories: 600, protein: 25, fat: 18, carbs: 80, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [
                RecommendCondition(biomarker: "T3", condition: .below, threshold: 80, scoreBoost: 40),
                RecommendCondition(biomarker: "cortisol_morning", condition: .above, threshold: 25, scoreBoost: 30)
            ],
            tags: ["代謝回復", "リバースダイエット", "バイオハッキング"],
            features: [
                "代謝適応のリセット",
                "ホルモンバランスの改善",
                "エネルギーレベルの回復",
                "長期的なダイエット成功への準備"
            ],
            expectedResults: [
                "TDEE +200〜400kcal",
                "エネルギー向上",
                "睡眠の質改善",
                "次のダイエットの基盤構築"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 6. 抗炎症ダイエット
        DietProgram(
            id: "anti-inflammatory",
            nameJa: "抗炎症ダイエット",
            nameEn: "Anti-Inflammatory Diet",
            category: .biohacking,
            description: "慢性炎症を抑える食事で、疲労感の軽減、肌質改善、免疫力向上を目指します。地中海式をベースにした食事法。",
            descriptionEn: "Reduce chronic inflammation to decrease fatigue, improve skin, and boost immunity. Based on Mediterranean diet principles.",
            difficulty: .beginner,
            targetGoal: .maintain,
            deficitIntensity: 0.05,
            basePFC: PFCRatio(protein: 20, fat: 35, carbs: 45),
            phases: [
                ProgramPhase(
                    id: "ai-w1",
                    weekNumber: 1,
                    name: "炎症食品の除去",
                    nameEn: "Remove Inflammatory Foods",
                    description: "加工食品、精製糖を減らす",
                    focusPoints: [
                        "加工食品を避ける",
                        "砂糖入り飲料をやめる",
                        "トランス脂肪酸を避ける"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ai-w2",
                    weekNumber: 2,
                    name: "オメガ3強化",
                    nameEn: "Omega-3 Enhancement",
                    description: "抗炎症脂質を増やす",
                    focusPoints: [
                        "青魚を週3回以上",
                        "オリーブオイルを毎日",
                        "ナッツを間食に"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ai-w3",
                    weekNumber: 3,
                    name: "抗酸化食品の導入",
                    nameEn: "Introduce Antioxidants",
                    description: "カラフルな野菜と果物",
                    focusPoints: [
                        "毎食に野菜を追加",
                        "ベリー類を取り入れる",
                        "緑茶・ターメリックの活用"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "ai-w4",
                    weekNumber: 4,
                    name: "習慣化と最適化",
                    nameEn: "Habituation & Optimization",
                    description: "ライフスタイルとして定着",
                    focusPoints: [
                        "外食時の選び方",
                        "スパイスの活用",
                        "睡眠と運動の統合"
                    ],
                    calorieMultiplier: 0.95
                )
            ],
            sampleMeals: [
                SampleMeal(id: "ai-b1", mealType: .breakfast, name: "ベリーヨーグルトボウル", nameEn: "Berry Yogurt Bowl", calories: 350, protein: 18, fat: 12, carbs: 45, imageURL: nil),
                SampleMeal(id: "ai-l1", mealType: .lunch, name: "地中海風サラダ", nameEn: "Mediterranean Salad", calories: 500, protein: 25, fat: 25, carbs: 40, imageURL: nil),
                SampleMeal(id: "ai-d1", mealType: .dinner, name: "サーモンとアスパラガス", nameEn: "Salmon with Asparagus", calories: 550, protein: 35, fat: 30, carbs: 30, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [
                RecommendCondition(biomarker: "CRP", condition: .above, threshold: 1.0, scoreBoost: 50),
                RecommendCondition(biomarker: "IL6", condition: .above, threshold: 2.0, scoreBoost: 40),
                RecommendCondition(biomarker: "homocysteine", condition: .above, threshold: 10, scoreBoost: 30)
            ],
            tags: ["抗炎症", "地中海式", "オメガ3", "免疫"],
            features: [
                "慢性炎症の軽減",
                "オメガ3脂肪酸の増加",
                "抗酸化物質の摂取強化",
                "腸内環境の改善"
            ],
            expectedResults: [
                "CRP値の改善",
                "疲労感の軽減",
                "肌質の改善",
                "関節痛の軽減"
            ],
            imageURL: nil,
            layer: .focus,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 7. ガット（腸内環境）リセット
        DietProgram(
            id: "gut-reset",
            nameJa: "ガットリセット",
            nameEn: "Gut Reset",
            category: .biohacking,
            description: "腸内細菌叢を改善し、消化機能、免疫、メンタルヘルスを向上。プレバイオティクス&プロバイオティクスを強化。",
            descriptionEn: "Improve gut microbiome to enhance digestion, immunity, and mental health. Emphasize prebiotics & probiotics.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: PFCRatio(protein: 22, fat: 28, carbs: 50),
            phases: [
                ProgramPhase(
                    id: "gut-w1",
                    weekNumber: 1,
                    name: "腸を休める",
                    nameEn: "Rest Your Gut",
                    description: "刺激物を減らし、消化を楽に",
                    focusPoints: [
                        "アルコールを控える",
                        "カフェインを減らす",
                        "よく噛んで食べる"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "gut-w2",
                    weekNumber: 2,
                    name: "発酵食品の導入",
                    nameEn: "Introduce Fermented Foods",
                    description: "プロバイオティクスを増やす",
                    focusPoints: [
                        "納豆、味噌を毎日",
                        "ヨーグルトを追加",
                        "キムチ、ぬか漬け"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "gut-w3",
                    weekNumber: 3,
                    name: "食物繊維強化",
                    nameEn: "Boost Fiber",
                    description: "プレバイオティクスを増やす",
                    focusPoints: [
                        "野菜の量を増やす",
                        "全粒穀物に切り替え",
                        "レジスタントスターチの活用"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "gut-w4",
                    weekNumber: 4,
                    name: "多様性の確保",
                    nameEn: "Ensure Diversity",
                    description: "30種類以上の植物食品を目指す",
                    focusPoints: [
                        "週に30種類の野菜・果物",
                        "ハーブ・スパイスも1種類",
                        "季節の食材を取り入れる"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "gut-b1", mealType: .breakfast, name: "納豆ご飯と味噌汁", nameEn: "Natto Rice & Miso Soup", calories: 400, protein: 18, fat: 12, carbs: 55, imageURL: nil),
                SampleMeal(id: "gut-l1", mealType: .lunch, name: "野菜たっぷりスープ", nameEn: "Vegetable-Rich Soup", calories: 450, protein: 20, fat: 15, carbs: 55, imageURL: nil),
                SampleMeal(id: "gut-d1", mealType: .dinner, name: "雑穀米と焼き野菜", nameEn: "Mixed Grain Rice & Roasted Vegetables", calories: 500, protein: 22, fat: 15, carbs: 65, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "SIBO", severity: .warning, message: "SIBOの場合は発酵食品で症状が悪化する可能性があります")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "gut_diversity_score", condition: .below, threshold: 70, scoreBoost: 40)
            ],
            tags: ["腸活", "腸内環境", "プロバイオティクス", "食物繊維"],
            features: [
                "腸内細菌叢の改善",
                "消化機能の向上",
                "免疫力アップ",
                "メンタルヘルスへの好影響"
            ],
            expectedResults: [
                "消化の改善",
                "便通の正常化",
                "エネルギーレベルの向上",
                "肌質改善"
            ],
            imageURL: nil,
            layer: .focus,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 8. インスリン・コントロール
        DietProgram(
            id: "insulin-control",
            nameJa: "インスリン・コントロール",
            nameEn: "Insulin Control",
            category: .biohacking,
            description: "血糖値の乱高下を防ぎ、インスリン感受性を改善。脂肪蓄積スイッチをOFFにするロカボアプローチ。",
            descriptionEn: "Prevent blood sugar spikes, improve insulin sensitivity. A low-carb approach to turn off fat storage.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.1,
            basePFC: PFCRatio(protein: 30, fat: 40, carbs: 30),
            phases: [
                ProgramPhase(
                    id: "ic-w1",
                    weekNumber: 1,
                    name: "血糖値モニタリング",
                    nameEn: "Blood Sugar Monitoring",
                    description: "食後血糖値のパターンを把握",
                    focusPoints: [
                        "食後2時間の血糖値を記録",
                        "GI値の高い食品を特定",
                        "血糖値スパイクの原因を把握"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "ic-w2",
                    weekNumber: 2,
                    name: "低GI食への移行",
                    nameEn: "Transition to Low GI",
                    description: "高GI食品を低GI食品に置き換え",
                    focusPoints: [
                        "白米→玄米・オートミール",
                        "食物繊維を先に食べる",
                        "タンパク質と脂質で血糖値を安定"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "ic-w3",
                    weekNumber: 3,
                    name: "食事順序の最適化",
                    nameEn: "Optimize Eating Order",
                    description: "ベジファースト＆プロテインファースト",
                    focusPoints: [
                        "野菜→タンパク質→炭水化物の順",
                        "よく噛んでゆっくり食べる",
                        "間食は低GIスナックに"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "ic-w4",
                    weekNumber: 4,
                    name: "習慣化と維持",
                    nameEn: "Build Habits",
                    description: "インスリン感受性改善の定着",
                    focusPoints: [
                        "食後の軽い運動を追加",
                        "外食時の対処法",
                        "長期的な血糖値管理"
                    ],
                    calorieMultiplier: 0.9
                )
            ],
            sampleMeals: [
                SampleMeal(id: "ic-b1", mealType: .breakfast, name: "オートミールと卵", nameEn: "Oatmeal with Eggs", calories: 380, protein: 22, fat: 15, carbs: 40, imageURL: nil),
                SampleMeal(id: "ic-l1", mealType: .lunch, name: "玄米と鶏肉サラダ", nameEn: "Brown Rice & Chicken Salad", calories: 500, protein: 35, fat: 18, carbs: 45, imageURL: nil),
                SampleMeal(id: "ic-d1", mealType: .dinner, name: "魚とキヌアボウル", nameEn: "Fish & Quinoa Bowl", calories: 480, protein: 32, fat: 20, carbs: 40, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "インスリン量の調整が必要です。医師に相談してください")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "HbA1c", condition: .above, threshold: 5.6, scoreBoost: 40),
                RecommendCondition(biomarker: "fasting_glucose", condition: .above, threshold: 100, scoreBoost: 35),
                RecommendCondition(biomarker: "fasting_insulin", condition: .above, threshold: 10, scoreBoost: 30)
            ],
            tags: ["インスリン", "血糖値", "低GI", "ロカボ"],
            features: [
                "血糖値スパイクの防止",
                "インスリン感受性の改善",
                "脂肪蓄積の抑制",
                "エネルギーレベルの安定"
            ],
            expectedResults: [
                "空腹時血糖値の改善",
                "HbA1cの低下",
                "体脂肪減少",
                "食後の眠気軽減"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 9. ターボ・カーボサイクル
        DietProgram(
            id: "turbo-carb-cycling",
            nameJa: "ターボ・カーボサイクル",
            nameEn: "Turbo Carb Cycling",
            category: .biohacking,
            description: "トレーニング日は炭水化物を摂り、休息日は脂質を増やす。筋肉を落とさず脂肪を削るアスリート向けプラン。",
            descriptionEn: "High carbs on training days, high fat on rest days. Preserve muscle while cutting fat for athletes.",
            difficulty: .advanced,
            targetGoal: .lose,
            deficitIntensity: 0.15,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "tcc-w1",
                    weekNumber: 1,
                    name: "サイクル理解",
                    nameEn: "Understanding Cycles",
                    description: "トレーニング日と休息日のパターン設定",
                    focusPoints: [
                        "週のトレーニングスケジュール確定",
                        "高炭水化物日のメニュー把握",
                        "低炭水化物日のメニュー把握"
                    ],
                    calorieMultiplier: 0.9,
                    pfcOverride: .balanced
                ),
                ProgramPhase(
                    id: "tcc-w2",
                    weekNumber: 2,
                    name: "サイクル実践",
                    nameEn: "Practice Cycling",
                    description: "炭水化物量を日によって調整",
                    focusPoints: [
                        "トレ日: 炭水化物50%、脂質20%",
                        "休息日: 炭水化物25%、脂質45%",
                        "タンパク質は常に30%を維持"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "tcc-w3",
                    weekNumber: 3,
                    name: "タイミング最適化",
                    nameEn: "Optimize Timing",
                    description: "トレ前後の栄養摂取を最適化",
                    focusPoints: [
                        "トレ前2時間: 炭水化物を摂取",
                        "トレ後30分: プロテイン+炭水化物",
                        "休息日は脂質で満腹感を維持"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "tcc-w4",
                    weekNumber: 4,
                    name: "微調整と定着",
                    nameEn: "Fine-tune & Maintain",
                    description: "体感を基に調整",
                    focusPoints: [
                        "パフォーマンスの変化を記録",
                        "体組成の変化を確認",
                        "持続可能なサイクルに調整"
                    ],
                    calorieMultiplier: 0.85
                )
            ],
            sampleMeals: [
                SampleMeal(id: "tcc-b1", mealType: .breakfast, name: "オートミール&バナナ（トレ日）", nameEn: "Oatmeal & Banana (Training)", calories: 450, protein: 20, fat: 10, carbs: 70, imageURL: nil),
                SampleMeal(id: "tcc-l1", mealType: .lunch, name: "アボカド&卵（休息日）", nameEn: "Avocado & Eggs (Rest)", calories: 420, protein: 25, fat: 32, carbs: 12, imageURL: nil),
                SampleMeal(id: "tcc-d1", mealType: .dinner, name: "鶏胸肉&さつまいも", nameEn: "Chicken & Sweet Potato", calories: 550, protein: 45, fat: 12, carbs: 55, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "血糖値の変動が大きくなる可能性があります")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "muscle_mass_percentage", condition: .above, threshold: 35, scoreBoost: 30)
            ],
            tags: ["カーボサイクル", "アスリート", "筋肉維持", "脂肪燃焼", "NEW"],
            features: [
                "トレーニングに合わせた栄養摂取",
                "筋肉量の維持",
                "効率的な脂肪燃焼",
                "パフォーマンス維持"
            ],
            expectedResults: [
                "体脂肪 -3〜5%",
                "筋肉量維持",
                "トレーニングパフォーマンス維持",
                "メリハリのある体型"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 10. テストステロン・サポート
        DietProgram(
            id: "testosterone-support",
            nameJa: "テストステロン・サポート",
            nameEn: "Testosterone Support",
            category: .biohacking,
            description: "男性活力の最大化。良質な脂質と亜鉛・マグネシウムを重点的に摂取し、テストステロン生成をブースト。",
            descriptionEn: "Maximize male vitality. Focus on quality fats, zinc & magnesium to boost testosterone production.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: PFCRatio(protein: 28, fat: 38, carbs: 34),
            phases: [
                ProgramPhase(
                    id: "ts-w1",
                    weekNumber: 1,
                    name: "ホルモン基盤づくり",
                    nameEn: "Hormone Foundation",
                    description: "テストステロン生成に必要な栄養素を確保",
                    focusPoints: [
                        "亜鉛を1日15mg以上（牡蠣、牛肉）",
                        "マグネシウムを1日400mg（ナッツ、緑野菜）",
                        "ビタミンD3のサプリメント検討"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ts-w2",
                    weekNumber: 2,
                    name: "良質な脂質の強化",
                    nameEn: "Quality Fats",
                    description: "コレステロール＝テストステロンの原料",
                    focusPoints: [
                        "卵を1日2〜3個",
                        "オリーブオイル、アボカドを毎日",
                        "飽和脂肪酸も適度に摂取"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ts-w3",
                    weekNumber: 3,
                    name: "アンチエストロゲン食品",
                    nameEn: "Anti-Estrogen Foods",
                    description: "エストロゲン優位を防ぐ",
                    focusPoints: [
                        "ブロッコリー、キャベツを積極的に",
                        "大豆製品は控えめに",
                        "アルコールを減らす"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ts-w4",
                    weekNumber: 4,
                    name: "ライフスタイル統合",
                    nameEn: "Lifestyle Integration",
                    description: "食事以外の要素も最適化",
                    focusPoints: [
                        "筋トレを週3回以上",
                        "睡眠を7〜8時間確保",
                        "ストレス管理"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "ts-b1", mealType: .breakfast, name: "卵3個とアボカド", nameEn: "3 Eggs with Avocado", calories: 450, protein: 25, fat: 35, carbs: 10, imageURL: nil),
                SampleMeal(id: "ts-l1", mealType: .lunch, name: "牛肉ステーキとブロッコリー", nameEn: "Beef Steak & Broccoli", calories: 600, protein: 45, fat: 35, carbs: 20, imageURL: nil),
                SampleMeal(id: "ts-d1", mealType: .dinner, name: "牡蠣とホウレン草", nameEn: "Oysters & Spinach", calories: 400, protein: 30, fat: 20, carbs: 25, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "prostate_issues", severity: .warning, message: "前立腺に問題がある場合は医師に相談してください")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "testosterone", condition: .below, threshold: 300, scoreBoost: 50),
                RecommendCondition(biomarker: "free_testosterone", condition: .below, threshold: 10, scoreBoost: 40)
            ],
            tags: ["テストステロン", "男性", "ホルモン", "活力"],
            features: [
                "テストステロン生成をサポート",
                "亜鉛・マグネシウムの強化",
                "良質な脂質の摂取",
                "エストロゲン優位の防止"
            ],
            expectedResults: [
                "エネルギーレベルの向上",
                "筋力・筋肉量の改善",
                "メンタルの安定",
                "活力の回復"
            ],
            imageURL: nil,
            layer: .focus,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 11. ニューロ・フォーカス
        DietProgram(
            id: "neuro-focus",
            nameJa: "ニューロ・フォーカス",
            nameEn: "Neuro-Focus",
            category: .biohacking,
            description: "脳機能の最適化。血糖値スパイクを排除し、MCTオイルやコリンで脳へ安定したエネルギーを供給。",
            descriptionEn: "Optimize brain function. Eliminate blood sugar spikes, supply stable energy with MCT oil and choline.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: PFCRatio(protein: 25, fat: 45, carbs: 30),
            phases: [
                ProgramPhase(
                    id: "nf-w1",
                    weekNumber: 1,
                    name: "脳燃料の切り替え",
                    nameEn: "Switch Brain Fuel",
                    description: "糖質依存から脂質燃焼へ",
                    focusPoints: [
                        "MCTオイルを朝のコーヒーに追加",
                        "糖質を徐々に減らす",
                        "ケトン体への適応を開始"
                    ],
                    calorieMultiplier: 1.0,
                    pfcOverride: PFCRatio(protein: 25, fat: 40, carbs: 35)
                ),
                ProgramPhase(
                    id: "nf-w2",
                    weekNumber: 2,
                    name: "コリン強化",
                    nameEn: "Choline Boost",
                    description: "アセチルコリンの原料を確保",
                    focusPoints: [
                        "卵黄を毎日（コリン豊富）",
                        "レバーを週2回",
                        "ブルーベリーで抗酸化"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "nf-w3",
                    weekNumber: 3,
                    name: "オメガ3と抗炎症",
                    nameEn: "Omega-3 & Anti-inflammatory",
                    description: "脳の炎症を抑える",
                    focusPoints: [
                        "青魚を週4回以上",
                        "ターメリックを料理に",
                        "加工食品を排除"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "nf-w4",
                    weekNumber: 4,
                    name: "認知パフォーマンス最適化",
                    nameEn: "Optimize Cognitive Performance",
                    description: "集中力と記憶力の向上",
                    focusPoints: [
                        "断続的ファスティングの導入",
                        "睡眠の質を改善",
                        "瞑想やマインドフルネス"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "nf-b1", mealType: .breakfast, name: "MCTバターコーヒー＆卵", nameEn: "MCT Butter Coffee & Eggs", calories: 400, protein: 20, fat: 35, carbs: 5, imageURL: nil),
                SampleMeal(id: "nf-l1", mealType: .lunch, name: "サーモンとアボカドサラダ", nameEn: "Salmon Avocado Salad", calories: 550, protein: 35, fat: 38, carbs: 15, imageURL: nil),
                SampleMeal(id: "nf-d1", mealType: .dinner, name: "鶏レバーと野菜", nameEn: "Chicken Liver & Vegetables", calories: 450, protein: 35, fat: 25, carbs: 20, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [
                RecommendCondition(biomarker: "homocysteine", condition: .above, threshold: 10, scoreBoost: 30)
            ],
            tags: ["脳機能", "集中力", "認知", "MCT", "NEW"],
            features: [
                "血糖値スパイクの排除",
                "ケトン体による安定エネルギー",
                "コリンによる神経伝達サポート",
                "オメガ3による脳の抗炎症"
            ],
            expectedResults: [
                "集中力の向上",
                "午後のエネルギー低下防止",
                "記憶力の改善",
                "メンタルクリアリティ"
            ],
            imageURL: nil,
            layer: .focus,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 12. ロンジェビティ・ブループリント
        DietProgram(
            id: "longevity-blueprint",
            nameJa: "ロンジェビティ・ブループリント",
            nameEn: "Longevity Blueprint",
            category: .biohacking,
            description: "細胞レベルの若返り。カロリー制限模倣とポリフェノール摂取を中心とした、長寿プログラム。",
            descriptionEn: "Cellular rejuvenation. Longevity program focusing on calorie restriction mimetics and polyphenols.",
            difficulty: .advanced,
            targetGoal: .maintain,
            deficitIntensity: 0.1,
            basePFC: PFCRatio(protein: 20, fat: 35, carbs: 45),
            phases: [
                ProgramPhase(
                    id: "lb-w1",
                    weekNumber: 1,
                    name: "オートファジー活性化",
                    nameEn: "Activate Autophagy",
                    description: "細胞の自食作用を促進",
                    focusPoints: [
                        "16:8ファスティングを導入",
                        "タンパク質を適度に制限",
                        "スペルミジン豊富な食品（納豆、チーズ）"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "lb-w2",
                    weekNumber: 2,
                    name: "ポリフェノール強化",
                    nameEn: "Polyphenol Boost",
                    description: "抗酸化物質で細胞を守る",
                    focusPoints: [
                        "ベリー類を毎日",
                        "緑茶・抹茶を習慣に",
                        "ダークチョコレート（カカオ70%以上）"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "lb-w3",
                    weekNumber: 3,
                    name: "カロリー制限模倣",
                    nameEn: "CR Mimetics",
                    description: "適度なカロリー制限で長寿遺伝子を活性化",
                    focusPoints: [
                        "TDEE -10〜15%を維持",
                        "レスベラトロール（赤ワイン、ぶどう）",
                        "NMNサプリメントの検討"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "lb-w4",
                    weekNumber: 4,
                    name: "ブルーゾーン食",
                    nameEn: "Blue Zone Diet",
                    description: "世界の長寿地域の食事パターン",
                    focusPoints: [
                        "豆類を毎日",
                        "野菜中心の食事",
                        "適度な魚介類"
                    ],
                    calorieMultiplier: 0.9
                )
            ],
            sampleMeals: [
                SampleMeal(id: "lb-b1", mealType: .breakfast, name: "ベリーヨーグルト＆ナッツ", nameEn: "Berry Yogurt & Nuts", calories: 350, protein: 15, fat: 18, carbs: 35, imageURL: nil),
                SampleMeal(id: "lb-l1", mealType: .lunch, name: "レンズ豆スープと全粒パン", nameEn: "Lentil Soup & Whole Grain Bread", calories: 450, protein: 20, fat: 12, carbs: 60, imageURL: nil),
                SampleMeal(id: "lb-d1", mealType: .dinner, name: "グリル魚と地中海野菜", nameEn: "Grilled Fish & Mediterranean Vegetables", calories: 480, protein: 35, fat: 22, carbs: 35, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "underweight", severity: .warning, message: "BMI 18.5未満の方はカロリー制限を避けてください")
            ],
            recommendConditions: [],
            tags: ["長寿", "アンチエイジング", "オートファジー", "ブルーゾーン"],
            features: [
                "オートファジーの活性化",
                "長寿遺伝子（サーチュイン）の活性化",
                "細胞の抗酸化",
                "ブルーゾーンの知恵を活用"
            ],
            expectedResults: [
                "細胞レベルの若返り",
                "エネルギーレベルの向上",
                "肌質の改善",
                "慢性炎症の軽減"
            ],
            imageURL: nil,
            layer: .focus,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 13. バランスダイエット
        DietProgram(
            id: "balanced-diet",
            nameJa: "バランスダイエット",
            nameEn: "Balanced Diet",
            category: .balanced,
            description: "極端な制限なく、三大栄養素をバランス良く摂取。長期継続しやすく、リバウンドしにくい王道のダイエット法。",
            descriptionEn: "No extreme restrictions. Balanced intake of macronutrients. Easy to maintain long-term with low rebound risk.",
            difficulty: .beginner,
            targetGoal: .lose,
            deficitIntensity: 0.1,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "bd-w1",
                    weekNumber: 1,
                    name: "現状把握と目標設定",
                    nameEn: "Assessment & Goal Setting",
                    description: "現在の食習慣を記録",
                    focusPoints: [
                        "全ての食事を記録",
                        "目標カロリーを設定",
                        "無理のない範囲でスタート"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "bd-w2",
                    weekNumber: 2,
                    name: "食事の見直し",
                    nameEn: "Review Your Meals",
                    description: "バランスの取れた食事へ移行",
                    focusPoints: [
                        "主食・主菜・副菜を揃える",
                        "間食を見直す",
                        "飲み物のカロリーに注意"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "bd-w3",
                    weekNumber: 3,
                    name: "運動の導入",
                    nameEn: "Introduce Exercise",
                    description: "食事+軽い運動",
                    focusPoints: [
                        "1日8,000歩を目標",
                        "週2回の軽い筋トレ",
                        "ストレッチの習慣化"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "bd-w4",
                    weekNumber: 4,
                    name: "習慣化",
                    nameEn: "Build Habits",
                    description: "新しい食習慣の定着",
                    focusPoints: [
                        "外食時の対処法",
                        "週末の過ごし方",
                        "モチベーション維持"
                    ],
                    calorieMultiplier: 0.9
                )
            ],
            sampleMeals: [
                SampleMeal(id: "bd-b1", mealType: .breakfast, name: "和朝食セット", nameEn: "Japanese Breakfast Set", calories: 400, protein: 20, fat: 12, carbs: 55, imageURL: nil),
                SampleMeal(id: "bd-l1", mealType: .lunch, name: "定食スタイル", nameEn: "Set Meal Style", calories: 550, protein: 28, fat: 18, carbs: 60, imageURL: nil),
                SampleMeal(id: "bd-d1", mealType: .dinner, name: "魚中心の夕食", nameEn: "Fish-Centered Dinner", calories: 500, protein: 30, fat: 18, carbs: 50, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["バランス", "初心者", "王道", "継続しやすい"],
            features: [
                "極端な制限なし",
                "三大栄養素のバランス",
                "長期継続しやすい",
                "リバウンドしにくい"
            ],
            expectedResults: [
                "体重 -2〜3kg/月",
                "食習慣の改善",
                "健康的な減量",
                "新しい食生活の確立"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 14. スタンダード・バランス (Lifesum Standard)
        DietProgram(
            id: "lifesum-standard",
            nameJa: "スタンダード・バランス",
            nameEn: "Lifesum Standard",
            category: .balanced,
            description: "基本的な栄養バランスの取れた食事。無理なく続けたい方向けのベースラインプログラム。",
            descriptionEn: "Basic nutritionally balanced meals. A baseline program for those who want to continue without strain.",
            difficulty: .beginner,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "ls-w1",
                    weekNumber: 1,
                    name: "食事記録の習慣化",
                    nameEn: "Build Logging Habit",
                    description: "まずは記録することから",
                    focusPoints: [
                        "毎食の記録を習慣に",
                        "量の把握",
                        "食事のタイミングを意識"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ls-w2",
                    weekNumber: 2,
                    name: "バランスの確認",
                    nameEn: "Check Balance",
                    description: "三大栄養素のバランスを確認",
                    focusPoints: [
                        "PFCバランスを確認",
                        "野菜の摂取量を増やす",
                        "タンパク質を意識"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ls-w3",
                    weekNumber: 3,
                    name: "微調整",
                    nameEn: "Fine Tuning",
                    description: "目標に合わせて調整",
                    focusPoints: [
                        "カロリー目標の調整",
                        "間食の見直し",
                        "水分摂取の確認"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ls-w4",
                    weekNumber: 4,
                    name: "継続",
                    nameEn: "Continue",
                    description: "習慣として定着",
                    focusPoints: [
                        "無理のないペースで継続",
                        "外食時の対応",
                        "モチベーション維持"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "ls-b1", mealType: .breakfast, name: "トーストと卵", nameEn: "Toast & Eggs", calories: 380, protein: 18, fat: 15, carbs: 45, imageURL: nil),
                SampleMeal(id: "ls-l1", mealType: .lunch, name: "お弁当スタイル", nameEn: "Bento Style", calories: 550, protein: 25, fat: 18, carbs: 65, imageURL: nil),
                SampleMeal(id: "ls-d1", mealType: .dinner, name: "家庭料理定食", nameEn: "Home Cooking Set", calories: 500, protein: 28, fat: 16, carbs: 58, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["スタンダード", "初心者", "基本", "継続しやすい"],
            features: [
                "制限なしのバランス食",
                "記録の習慣化",
                "無理なく続けられる",
                "どんな目標にも対応"
            ],
            expectedResults: [
                "食習慣の改善",
                "栄養バランスの向上",
                "体調の安定",
                "食への意識向上"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 15. 3週間集中ダイエット
        DietProgram(
            id: "3-week-weight-loss",
            nameJa: "3週間集中ダイエット",
            nameEn: "3 Week Weight Loss",
            category: .balanced,
            description: "21日間で結果を出すための、少しカロリー設定を厳しくした短期集中プログラム。",
            descriptionEn: "A 21-day intensive program with stricter calorie settings to achieve results.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.2,
            basePFC: PFCRatio(protein: 30, fat: 25, carbs: 45),
            phases: [
                ProgramPhase(
                    id: "3wk-w1",
                    weekNumber: 1,
                    name: "スタートダッシュ",
                    nameEn: "Start Dash",
                    description: "最初の1週間でリズムを作る",
                    focusPoints: [
                        "カロリー目標を厳守",
                        "間食を完全にカット",
                        "水分を2L以上"
                    ],
                    calorieMultiplier: 0.8
                ),
                ProgramPhase(
                    id: "3wk-w2",
                    weekNumber: 2,
                    name: "加速期",
                    nameEn: "Acceleration",
                    description: "体重減少を加速",
                    focusPoints: [
                        "運動を追加（1日30分）",
                        "夕食の炭水化物を半分に",
                        "タンパク質を増やす"
                    ],
                    calorieMultiplier: 0.8
                ),
                ProgramPhase(
                    id: "3wk-w3",
                    weekNumber: 3,
                    name: "仕上げ",
                    nameEn: "Finish",
                    description: "最後の追い込み",
                    focusPoints: [
                        "食事管理を継続",
                        "運動頻度を維持",
                        "リバウンド防止策を学ぶ"
                    ],
                    calorieMultiplier: 0.8
                )
            ],
            sampleMeals: [
                SampleMeal(id: "3wk-b1", mealType: .breakfast, name: "プロテインスムージー", nameEn: "Protein Smoothie", calories: 300, protein: 25, fat: 8, carbs: 35, imageURL: nil),
                SampleMeal(id: "3wk-l1", mealType: .lunch, name: "サラダボウル", nameEn: "Salad Bowl", calories: 400, protein: 30, fat: 15, carbs: 40, imageURL: nil),
                SampleMeal(id: "3wk-d1", mealType: .dinner, name: "グリル魚と野菜", nameEn: "Grilled Fish & Vegetables", calories: 380, protein: 35, fat: 15, carbs: 25, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "摂食障害の既往がある方は避けてください")
            ],
            recommendConditions: [],
            tags: ["短期集中", "ダイエット", "21日", "NEW"],
            features: [
                "21日間の短期集中",
                "厳格なカロリー管理",
                "運動との組み合わせ",
                "明確なゴール設定"
            ],
            expectedResults: [
                "体重 -2〜4kg",
                "体脂肪率の減少",
                "食習慣の見直し",
                "達成感"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 16. クリーン・イーティング
        DietProgram(
            id: "clean-eating",
            nameJa: "クリーン・イーティング",
            nameEn: "Clean Eating",
            category: .balanced,
            description: "加工食品を避け、自然食品（ホールフード）のみを食べるデトックスプラン。",
            descriptionEn: "A detox plan that avoids processed foods and eats only whole foods.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0.05,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "ce-w1",
                    weekNumber: 1,
                    name: "加工食品の特定",
                    nameEn: "Identify Processed Foods",
                    description: "普段食べている加工食品を把握",
                    focusPoints: [
                        "食品ラベルを読む習慣",
                        "添加物の多い食品を特定",
                        "代替食品をリストアップ"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "ce-w2",
                    weekNumber: 2,
                    name: "置き換え開始",
                    nameEn: "Start Replacing",
                    description: "加工食品を自然食品に置き換え",
                    focusPoints: [
                        "スナック菓子→ナッツ・果物",
                        "清涼飲料水→水・お茶",
                        "加工肉→新鮮な肉・魚"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "ce-w3",
                    weekNumber: 3,
                    name: "完全移行",
                    nameEn: "Full Transition",
                    description: "できる限り自然食品のみに",
                    focusPoints: [
                        "自炊を増やす",
                        "原材料が5つ以下の食品",
                        "季節の野菜・果物を取り入れる"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "ce-w4",
                    weekNumber: 4,
                    name: "習慣化",
                    nameEn: "Build Habits",
                    description: "クリーンイーティングを日常に",
                    focusPoints: [
                        "買い物リストの作成",
                        "週末の作り置き",
                        "外食時の選び方"
                    ],
                    calorieMultiplier: 0.95
                )
            ],
            sampleMeals: [
                SampleMeal(id: "ce-b1", mealType: .breakfast, name: "オートミール＆ベリー", nameEn: "Oatmeal & Berries", calories: 380, protein: 12, fat: 10, carbs: 60, imageURL: nil),
                SampleMeal(id: "ce-l1", mealType: .lunch, name: "グリルチキンサラダ", nameEn: "Grilled Chicken Salad", calories: 450, protein: 35, fat: 20, carbs: 30, imageURL: nil),
                SampleMeal(id: "ce-d1", mealType: .dinner, name: "焼き魚と蒸し野菜", nameEn: "Grilled Fish & Steamed Vegetables", calories: 420, protein: 32, fat: 18, carbs: 28, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["クリーン", "ホールフード", "自然食品", "デトックス"],
            features: [
                "加工食品の排除",
                "自然食品のみ",
                "添加物フリー",
                "体内デトックス"
            ],
            expectedResults: [
                "体調の改善",
                "肌質の向上",
                "エネルギーレベルの安定",
                "消化機能の改善"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 17. 地中海式ダイエット
        DietProgram(
            id: "mediterranean",
            nameJa: "地中海式ダイエット",
            nameEn: "Mediterranean Diet",
            category: .balanced,
            description: "野菜、果物、魚、ナッツ、オリーブオイルを中心とした、心血管に優しい食事法。",
            descriptionEn: "A heart-healthy diet centered on vegetables, fruits, fish, nuts, and olive oil.",
            difficulty: .beginner,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: PFCRatio(protein: 20, fat: 40, carbs: 40),
            phases: [
                ProgramPhase(
                    id: "med-w1",
                    weekNumber: 1,
                    name: "オリーブオイルの導入",
                    nameEn: "Introduce Olive Oil",
                    description: "調理油をオリーブオイルに",
                    focusPoints: [
                        "調理にオリーブオイルを使用",
                        "サラダにもオリーブオイル",
                        "バターの使用を減らす"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "med-w2",
                    weekNumber: 2,
                    name: "魚介類の強化",
                    nameEn: "More Seafood",
                    description: "週に3〜4回は魚を",
                    focusPoints: [
                        "肉を魚に置き換え",
                        "青魚を積極的に",
                        "貝類も取り入れる"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "med-w3",
                    weekNumber: 3,
                    name: "野菜と豆類",
                    nameEn: "Vegetables & Legumes",
                    description: "植物性食品を増やす",
                    focusPoints: [
                        "毎食に野菜を追加",
                        "豆類を週3回以上",
                        "ナッツを間食に"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "med-w4",
                    weekNumber: 4,
                    name: "ワインと楽しむ",
                    nameEn: "Enjoy with Wine",
                    description: "適度な赤ワインも",
                    focusPoints: [
                        "食事をゆっくり楽しむ",
                        "赤ワインを適量（任意）",
                        "家族や友人との食事"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "med-b1", mealType: .breakfast, name: "全粒パンとフムス", nameEn: "Whole Grain Bread & Hummus", calories: 400, protein: 15, fat: 18, carbs: 48, imageURL: nil),
                SampleMeal(id: "med-l1", mealType: .lunch, name: "グリークサラダ", nameEn: "Greek Salad", calories: 450, protein: 18, fat: 30, carbs: 28, imageURL: nil),
                SampleMeal(id: "med-d1", mealType: .dinner, name: "グリルシーバスとロースト野菜", nameEn: "Grilled Sea Bass & Roasted Vegetables", calories: 520, protein: 38, fat: 28, carbs: 30, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [
                RecommendCondition(biomarker: "LDL", condition: .above, threshold: 140, scoreBoost: 30),
                RecommendCondition(biomarker: "triglycerides", condition: .above, threshold: 150, scoreBoost: 25)
            ],
            tags: ["地中海式", "心臓", "オリーブオイル", "魚"],
            features: [
                "心血管の健康をサポート",
                "良質な脂質の摂取",
                "抗酸化物質が豊富",
                "続けやすい食事スタイル"
            ],
            expectedResults: [
                "LDLコレステロールの改善",
                "血圧の安定",
                "炎症マーカーの低下",
                "心臓病リスクの軽減"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 18. バイタリティ
        DietProgram(
            id: "vitality",
            nameJa: "バイタリティ",
            nameEn: "Vitality",
            category: .balanced,
            description: "エネルギッシュな毎日を送るための、ビタミン・ミネラル重視のプラン。",
            descriptionEn: "A plan focusing on vitamins and minerals for energetic daily life.",
            difficulty: .beginner,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "vit-w1",
                    weekNumber: 1,
                    name: "鉄分強化",
                    nameEn: "Iron Boost",
                    description: "疲労回復の基盤を作る",
                    focusPoints: [
                        "赤身肉を週2〜3回",
                        "ほうれん草、小松菜を毎日",
                        "ビタミンCと一緒に摂取"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "vit-w2",
                    weekNumber: 2,
                    name: "ビタミンB群",
                    nameEn: "B Vitamins",
                    description: "エネルギー代謝をサポート",
                    focusPoints: [
                        "豚肉、レバーを取り入れる",
                        "玄米、全粒穀物",
                        "卵を毎日"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "vit-w3",
                    weekNumber: 3,
                    name: "マグネシウム＆亜鉛",
                    nameEn: "Magnesium & Zinc",
                    description: "細胞レベルのエネルギー産生",
                    focusPoints: [
                        "ナッツ類を毎日",
                        "カボチャの種、ゴマ",
                        "牡蠣、牛肉で亜鉛補給"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "vit-w4",
                    weekNumber: 4,
                    name: "総合バランス",
                    nameEn: "Total Balance",
                    description: "すべてのミネラルをバランス良く",
                    focusPoints: [
                        "カラフルな野菜を摂る",
                        "海藻類を追加",
                        "果物でビタミンC補給"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "vit-b1", mealType: .breakfast, name: "卵とホウレン草のオムレツ", nameEn: "Spinach Omelette", calories: 400, protein: 25, fat: 28, carbs: 12, imageURL: nil),
                SampleMeal(id: "vit-l1", mealType: .lunch, name: "レバニラ定食", nameEn: "Liver & Chives Set", calories: 550, protein: 35, fat: 22, carbs: 50, imageURL: nil),
                SampleMeal(id: "vit-d1", mealType: .dinner, name: "牛肉と野菜の炒め", nameEn: "Beef & Vegetable Stir Fry", calories: 500, protein: 32, fat: 25, carbs: 35, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [
                RecommendCondition(biomarker: "ferritin", condition: .below, threshold: 30, scoreBoost: 40),
                RecommendCondition(biomarker: "vitamin_B12", condition: .below, threshold: 300, scoreBoost: 35)
            ],
            tags: ["活力", "ビタミン", "ミネラル", "疲労回復"],
            features: [
                "ビタミン・ミネラル強化",
                "鉄分補給",
                "エネルギー代謝のサポート",
                "疲労感の軽減"
            ],
            expectedResults: [
                "エネルギーレベルの向上",
                "疲労感の軽減",
                "集中力の改善",
                "肌・髪の健康"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 19. シュガー・デトックス
        DietProgram(
            id: "sugar-detox",
            nameJa: "シュガー・デトックス",
            nameEn: "Sugar Detox",
            category: .balanced,
            description: "21日間、砂糖や甘味料への依存を断ち切り、味覚をリセットするプログラム。",
            descriptionEn: "A 21-day program to break sugar addiction and reset your taste buds.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0.05,
            basePFC: PFCRatio(protein: 28, fat: 35, carbs: 37),
            phases: [
                ProgramPhase(
                    id: "sd-w1",
                    weekNumber: 1,
                    name: "添加糖の排除",
                    nameEn: "Eliminate Added Sugar",
                    description: "明らかな砂糖を断つ",
                    focusPoints: [
                        "お菓子、デザートを断つ",
                        "清涼飲料水を水に置き換え",
                        "コーヒー・紅茶は無糖で"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "sd-w2",
                    weekNumber: 2,
                    name: "隠れた糖質の排除",
                    nameEn: "Eliminate Hidden Sugar",
                    description: "加工食品の糖質をチェック",
                    focusPoints: [
                        "ソース、ドレッシングに注意",
                        "パン、シリアルの糖質を確認",
                        "果物は適量に"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "sd-w3",
                    weekNumber: 3,
                    name: "味覚リセット",
                    nameEn: "Taste Reset",
                    description: "自然な甘みを感じる力を取り戻す",
                    focusPoints: [
                        "野菜の甘みを感じる",
                        "良質な脂質で満足感",
                        "塩味、酸味、旨味を楽しむ"
                    ],
                    calorieMultiplier: 0.95
                )
            ],
            sampleMeals: [
                SampleMeal(id: "sd-b1", mealType: .breakfast, name: "卵とアボカドプレート", nameEn: "Eggs & Avocado Plate", calories: 420, protein: 22, fat: 32, carbs: 12, imageURL: nil),
                SampleMeal(id: "sd-l1", mealType: .lunch, name: "グリルチキンと野菜", nameEn: "Grilled Chicken & Vegetables", calories: 480, protein: 38, fat: 25, carbs: 25, imageURL: nil),
                SampleMeal(id: "sd-d1", mealType: .dinner, name: "サーモンとブロッコリー", nameEn: "Salmon & Broccoli", calories: 450, protein: 35, fat: 28, carbs: 15, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "血糖値管理に影響があります。医師に相談してください")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "fasting_glucose", condition: .above, threshold: 100, scoreBoost: 35),
                RecommendCondition(biomarker: "triglycerides", condition: .above, threshold: 150, scoreBoost: 30)
            ],
            tags: ["砂糖断ち", "デトックス", "味覚リセット", "21日"],
            features: [
                "砂糖への依存を断つ",
                "味覚のリセット",
                "血糖値の安定化",
                "自然な甘みを感じる力"
            ],
            expectedResults: [
                "甘いものへの欲求減少",
                "エネルギーレベルの安定",
                "体重減少",
                "肌質の改善"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 20. ホルモンバランス
        DietProgram(
            id: "hormonal-balance",
            nameJa: "ホルモンバランス",
            nameEn: "Hormonal Balance",
            category: .balanced,
            description: "ホルモン変動に合わせ、良質な脂質や食物繊維を摂る女性向けのケアプラン。",
            descriptionEn: "A care plan for women that adjusts to hormonal fluctuations with quality fats and fiber.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: PFCRatio(protein: 22, fat: 35, carbs: 43),
            phases: [
                ProgramPhase(
                    id: "hb-w1",
                    weekNumber: 1,
                    name: "月経期",
                    nameEn: "Menstrual Phase",
                    description: "鉄分とビタミンB群を強化",
                    focusPoints: [
                        "鉄分豊富な食品（赤身肉、ほうれん草）",
                        "温かい食事を心がける",
                        "カフェインを控える"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "hb-w2",
                    weekNumber: 2,
                    name: "卵胞期",
                    nameEn: "Follicular Phase",
                    description: "エストロゲンをサポート",
                    focusPoints: [
                        "亜麻仁、ゴマなどの種子類",
                        "発酵食品で腸内環境を整える",
                        "緑黄色野菜を増やす"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "hb-w3",
                    weekNumber: 3,
                    name: "排卵期〜黄体期前半",
                    nameEn: "Ovulation & Early Luteal",
                    description: "プロゲステロンをサポート",
                    focusPoints: [
                        "亜鉛、マグネシウムを摂取",
                        "炭水化物は複合糖質で",
                        "良質な脂質を確保"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "hb-w4",
                    weekNumber: 4,
                    name: "黄体期後半（PMS期）",
                    nameEn: "Late Luteal (PMS)",
                    description: "PMSを軽減",
                    focusPoints: [
                        "塩分を控えめに（むくみ防止）",
                        "ビタミンB6（バナナ、鶏肉）",
                        "カルシウムを摂取"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "hb-b1", mealType: .breakfast, name: "亜麻仁入りヨーグルト", nameEn: "Flaxseed Yogurt", calories: 380, protein: 18, fat: 18, carbs: 38, imageURL: nil),
                SampleMeal(id: "hb-l1", mealType: .lunch, name: "鮭と野菜のランチ", nameEn: "Salmon & Vegetable Lunch", calories: 500, protein: 30, fat: 22, carbs: 48, imageURL: nil),
                SampleMeal(id: "hb-d1", mealType: .dinner, name: "温かい鍋料理", nameEn: "Warm Hot Pot", calories: 480, protein: 32, fat: 18, carbs: 45, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["女性", "ホルモン", "PMS", "月経"],
            features: [
                "月経周期に合わせた栄養",
                "ホルモンバランスをサポート",
                "PMS症状の軽減",
                "女性特有のニーズに対応"
            ],
            expectedResults: [
                "PMSの軽減",
                "月経痛の軽減",
                "肌質の改善",
                "エネルギーレベルの安定"
            ],
            imageURL: nil,
            layer: .focus,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 21. イート・リフト・リピート
        DietProgram(
            id: "eat-lift-repeat",
            nameJa: "イート・リフト・リピート",
            nameEn: "Eat, Lift, Repeat",
            category: .balanced,
            description: "筋トレをする人向け。筋肉の合成に必要な炭水化物とタンパク質をしっかり摂る増量・維持プラン。",
            descriptionEn: "For weight trainers. A bulking/maintenance plan with adequate carbs and protein for muscle synthesis.",
            difficulty: .intermediate,
            targetGoal: .gain,
            deficitIntensity: -0.1,
            basePFC: PFCRatio(protein: 30, fat: 25, carbs: 45),
            phases: [
                ProgramPhase(
                    id: "elr-w1",
                    weekNumber: 1,
                    name: "カロリー増加開始",
                    nameEn: "Start Calorie Surplus",
                    description: "まずはTDEE+200〜300kcal",
                    focusPoints: [
                        "毎食タンパク質30g以上",
                        "トレ後に炭水化物を摂取",
                        "間食で追加カロリー"
                    ],
                    calorieMultiplier: 1.1
                ),
                ProgramPhase(
                    id: "elr-w2",
                    weekNumber: 2,
                    name: "トレーニング栄養学",
                    nameEn: "Training Nutrition",
                    description: "トレ前後の栄養を最適化",
                    focusPoints: [
                        "トレ2時間前に炭水化物",
                        "トレ直後にプロテイン+糖質",
                        "クレアチンの検討"
                    ],
                    calorieMultiplier: 1.15
                ),
                ProgramPhase(
                    id: "elr-w3",
                    weekNumber: 3,
                    name: "ボリューム増加",
                    nameEn: "Volume Increase",
                    description: "食事量を増やしながら質を維持",
                    focusPoints: [
                        "食事回数を増やす",
                        "消化しやすい食品を選ぶ",
                        "睡眠を8時間確保"
                    ],
                    calorieMultiplier: 1.15
                ),
                ProgramPhase(
                    id: "elr-w4",
                    weekNumber: 4,
                    name: "調整と維持",
                    nameEn: "Adjust & Maintain",
                    description: "体重・体組成を確認して調整",
                    focusPoints: [
                        "週0.25〜0.5kgの増加を目安",
                        "体脂肪率も確認",
                        "長期的な計画を立てる"
                    ],
                    calorieMultiplier: 1.1
                )
            ],
            sampleMeals: [
                SampleMeal(id: "elr-b1", mealType: .breakfast, name: "オートミール＆卵3個", nameEn: "Oatmeal & 3 Eggs", calories: 550, protein: 30, fat: 20, carbs: 55, imageURL: nil),
                SampleMeal(id: "elr-l1", mealType: .lunch, name: "鶏むね肉と玄米大盛り", nameEn: "Chicken Breast & Large Brown Rice", calories: 700, protein: 50, fat: 15, carbs: 80, imageURL: nil),
                SampleMeal(id: "elr-d1", mealType: .dinner, name: "牛肉とパスタ", nameEn: "Beef & Pasta", calories: 750, protein: 45, fat: 25, carbs: 85, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["筋トレ", "増量", "バルク", "筋肉"],
            features: [
                "筋肉合成をサポート",
                "トレーニングに合わせた栄養",
                "適切なカロリー余剰",
                "タンパク質の十分な摂取"
            ],
            expectedResults: [
                "筋肉量の増加",
                "筋力の向上",
                "トレーニングパフォーマンス向上",
                "健康的な体重増加"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 22. ランナーズ・ダイエット
        DietProgram(
            id: "runners-diet",
            nameJa: "ランナーズ・ダイエット",
            nameEn: "Runner's Diet",
            category: .balanced,
            description: "持久力維持のため、炭水化物比率を高めに設定したランナー専用プラン。",
            descriptionEn: "A plan for runners with higher carbohydrate ratio to maintain endurance.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0,
            basePFC: PFCRatio(protein: 18, fat: 25, carbs: 57),
            phases: [
                ProgramPhase(
                    id: "rd-w1",
                    weekNumber: 1,
                    name: "炭水化物の重要性",
                    nameEn: "Carb Importance",
                    description: "ランナーにとっての燃料を理解",
                    focusPoints: [
                        "走る前に炭水化物を摂取",
                        "全粒穀物を中心に",
                        "適度な脂質も忘れずに"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "rd-w2",
                    weekNumber: 2,
                    name: "レース前栄養",
                    nameEn: "Pre-Race Nutrition",
                    description: "カーボローディングの基礎",
                    focusPoints: [
                        "3日前から炭水化物を増やす",
                        "食物繊維は控えめに",
                        "水分補給を意識"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "rd-w3",
                    weekNumber: 3,
                    name: "リカバリー栄養",
                    nameEn: "Recovery Nutrition",
                    description: "走った後の回復",
                    focusPoints: [
                        "走後30分以内に糖質+タンパク質",
                        "炎症を抑える食品",
                        "鉄分の補給"
                    ],
                    calorieMultiplier: 1.0
                ),
                ProgramPhase(
                    id: "rd-w4",
                    weekNumber: 4,
                    name: "統合と最適化",
                    nameEn: "Integrate & Optimize",
                    description: "トレーニングサイクルに合わせる",
                    focusPoints: [
                        "練習量に応じて食事量を調整",
                        "電解質の補給",
                        "長距離走前の食事計画"
                    ],
                    calorieMultiplier: 1.0
                )
            ],
            sampleMeals: [
                SampleMeal(id: "rd-b1", mealType: .breakfast, name: "バナナとオートミール", nameEn: "Banana & Oatmeal", calories: 450, protein: 12, fat: 10, carbs: 80, imageURL: nil),
                SampleMeal(id: "rd-l1", mealType: .lunch, name: "パスタと鶏肉", nameEn: "Pasta & Chicken", calories: 600, protein: 30, fat: 15, carbs: 85, imageURL: nil),
                SampleMeal(id: "rd-d1", mealType: .dinner, name: "玄米と魚の定食", nameEn: "Brown Rice & Fish Set", calories: 550, protein: 28, fat: 15, carbs: 75, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["ランニング", "持久力", "炭水化物", "アスリート"],
            features: [
                "持久力運動に最適化",
                "炭水化物重視",
                "リカバリーをサポート",
                "カーボローディング対応"
            ],
            expectedResults: [
                "持久力の向上",
                "リカバリーの改善",
                "パフォーマンス向上",
                "怪我の予防"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 23. 1週間ヴィーガン体験
        DietProgram(
            id: "vegan-for-a-week",
            nameJa: "1週間ヴィーガン体験",
            nameEn: "Vegan for a Week",
            category: .balanced,
            description: "7日間限定で動物性食品を完全に抜く、植物性中心の食生活トライアル。",
            descriptionEn: "A 7-day trial of completely plant-based eating, eliminating all animal products.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0.05,
            basePFC: PFCRatio(protein: 15, fat: 30, carbs: 55),
            phases: [
                ProgramPhase(
                    id: "vfw-w1",
                    weekNumber: 1,
                    name: "7日間チャレンジ",
                    nameEn: "7-Day Challenge",
                    description: "完全植物性食品のみで1週間",
                    focusPoints: [
                        "肉・魚・卵・乳製品を排除",
                        "豆類でタンパク質を確保",
                        "ナッツ・種子で脂質を摂取"
                    ],
                    calorieMultiplier: 0.95
                )
            ],
            sampleMeals: [
                SampleMeal(id: "vfw-b1", mealType: .breakfast, name: "豆乳スムージー", nameEn: "Soy Milk Smoothie", calories: 350, protein: 15, fat: 12, carbs: 45, imageURL: nil),
                SampleMeal(id: "vfw-l1", mealType: .lunch, name: "豆腐と野菜の炒め物", nameEn: "Tofu & Vegetable Stir Fry", calories: 450, protein: 20, fat: 20, carbs: 50, imageURL: nil),
                SampleMeal(id: "vfw-d1", mealType: .dinner, name: "レンズ豆カレー", nameEn: "Lentil Curry", calories: 500, protein: 22, fat: 15, carbs: 70, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "B12_deficiency", severity: .warning, message: "B12サプリメントの摂取を検討してください")
            ],
            recommendConditions: [],
            tags: ["ヴィーガン", "植物性", "チャレンジ", "7日間", "NEW"],
            features: [
                "7日間の短期体験",
                "完全植物性食品",
                "環境にも優しい",
                "新しい食の発見"
            ],
            expectedResults: [
                "消化機能の改善",
                "新しいレシピの発見",
                "環境への貢献",
                "植物性食品への理解"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 24. 16:8 夕食抜きファスティング
        DietProgram(
            id: "16-8-evening-fasting",
            nameJa: "16:8 夕食抜きファスティング",
            nameEn: "16:8 Evening Fasting",
            category: .fasting,
            description: "夕食を抜き、消化器官を休ませながら睡眠の質を高める断食スタイル。",
            descriptionEn: "Skip dinner to rest your digestive system and improve sleep quality.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.1,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "16-8e-w1",
                    weekNumber: 1,
                    name: "夕食時間を早める",
                    nameEn: "Earlier Dinner",
                    description: "まずは18時までに夕食を終える",
                    focusPoints: [
                        "18時までに夕食を終える",
                        "朝食は翌朝8時以降",
                        "夜の空腹感に慣れる"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "16-8e-w2",
                    weekNumber: 2,
                    name: "16時間断食開始",
                    nameEn: "Start 16-Hour Fast",
                    description: "夕食を15時頃に移動",
                    focusPoints: [
                        "最後の食事を15〜16時に",
                        "翌朝7〜8時に朝食",
                        "夜は水・ハーブティーのみ"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "16-8e-w3",
                    weekNumber: 3,
                    name: "睡眠の質向上",
                    nameEn: "Improve Sleep Quality",
                    description: "空腹で眠ることのメリットを実感",
                    focusPoints: [
                        "就寝3時間前は食べない",
                        "睡眠の質を記録",
                        "朝の目覚めを確認"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "16-8e-w4",
                    weekNumber: 4,
                    name: "習慣化",
                    nameEn: "Build Habit",
                    description: "ライフスタイルとして定着",
                    focusPoints: [
                        "社会的イベントへの対応",
                        "週末のルール",
                        "長期継続のコツ"
                    ],
                    calorieMultiplier: 0.9
                )
            ],
            sampleMeals: [
                SampleMeal(id: "16-8e-b1", mealType: .breakfast, name: "しっかり朝食", nameEn: "Substantial Breakfast", calories: 600, protein: 30, fat: 25, carbs: 60, imageURL: nil),
                SampleMeal(id: "16-8e-l1", mealType: .lunch, name: "メイン食事", nameEn: "Main Meal", calories: 700, protein: 40, fat: 28, carbs: 70, imageURL: nil),
                SampleMeal(id: "16-8e-s1", mealType: .snack, name: "午後の軽食", nameEn: "Afternoon Snack", calories: 300, protein: 15, fat: 15, carbs: 25, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "摂食障害の既往がある方には推奨しません"),
                Contraindication(condition: "pregnancy", severity: .prohibited, message: "妊娠中・授乳中は推奨しません")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "sleep_quality", condition: .below, threshold: 70, scoreBoost: 35)
            ],
            tags: ["ファスティング", "16:8", "夕食抜き", "睡眠"],
            features: [
                "睡眠の質向上",
                "消化器官の休息",
                "朝型生活への移行",
                "夜の食欲をコントロール"
            ],
            expectedResults: [
                "睡眠の質向上",
                "朝の目覚め改善",
                "体重減少",
                "消化不良の改善"
            ],
            imageURL: nil,
            layer: .timing,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 25. 5:2 ダイエット
        DietProgram(
            id: "5-2-diet",
            nameJa: "5:2 ダイエット",
            nameEn: "5:2 Diet",
            category: .fasting,
            description: "週に5日は普通に食べ、2日だけ摂取カロリーを大幅に（約500kcal）制限する方法。",
            descriptionEn: "Eat normally 5 days a week, restrict calories to about 500kcal on 2 days.",
            difficulty: .intermediate,
            targetGoal: .lose,
            deficitIntensity: 0.15,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "52-w1",
                    weekNumber: 1,
                    name: "最初の断食日",
                    nameEn: "First Fasting Days",
                    description: "週2日の断食を開始",
                    focusPoints: [
                        "連続しない2日を選ぶ（例：月・木）",
                        "断食日は500〜600kcalに制限",
                        "タンパク質を優先的に摂取"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "52-w2",
                    weekNumber: 2,
                    name: "断食日の最適化",
                    nameEn: "Optimize Fasting Days",
                    description: "断食日の食事を工夫",
                    focusPoints: [
                        "野菜スープで満腹感",
                        "水分を十分に摂る",
                        "空腹感との付き合い方"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "52-w3",
                    weekNumber: 3,
                    name: "通常日の管理",
                    nameEn: "Manage Normal Days",
                    description: "通常日も食べ過ぎない",
                    focusPoints: [
                        "通常日はTDEEを目安に",
                        "断食の反動で食べ過ぎない",
                        "バランスの良い食事"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "52-w4",
                    weekNumber: 4,
                    name: "習慣化",
                    nameEn: "Build Habit",
                    description: "週2日断食を習慣に",
                    focusPoints: [
                        "自分に合った断食日を見つける",
                        "社会的イベントへの対応",
                        "長期継続のコツ"
                    ],
                    calorieMultiplier: 0.85
                )
            ],
            sampleMeals: [
                SampleMeal(id: "52-b1", mealType: .breakfast, name: "断食日朝食：卵1個", nameEn: "Fasting Day: 1 Egg", calories: 80, protein: 7, fat: 5, carbs: 1, imageURL: nil),
                SampleMeal(id: "52-l1", mealType: .lunch, name: "断食日昼食：サラダ", nameEn: "Fasting Day: Salad", calories: 150, protein: 10, fat: 8, carbs: 10, imageURL: nil),
                SampleMeal(id: "52-d1", mealType: .dinner, name: "断食日夕食：野菜スープ", nameEn: "Fasting Day: Vegetable Soup", calories: 250, protein: 15, fat: 8, carbs: 25, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "摂食障害の既往がある方には推奨しません"),
                Contraindication(condition: "pregnancy", severity: .prohibited, message: "妊娠中・授乳中は推奨しません"),
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "低血糖リスクがあります。医師に相談してください")
            ],
            recommendConditions: [],
            tags: ["ファスティング", "5:2", "週2断食", "柔軟"],
            features: [
                "週5日は普通に食べられる",
                "柔軟なスケジュール",
                "社会生活との両立",
                "断食の効果を得られる"
            ],
            expectedResults: [
                "体重減少",
                "インスリン感受性の改善",
                "断食への適応",
                "食事への意識向上"
            ],
            imageURL: nil,
            layer: .timing,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 26. 6:1 ダイエット
        DietProgram(
            id: "6-1-diet",
            nameJa: "6:1 ダイエット",
            nameEn: "6:1 Diet",
            category: .fasting,
            description: "週に6日は普通に食べ、1日だけ完全断食（水やお茶のみ）を行う方法。",
            descriptionEn: "Eat normally 6 days a week, complete fasting (water and tea only) on 1 day.",
            difficulty: .advanced,
            targetGoal: .lose,
            deficitIntensity: 0.1,
            basePFC: .balanced,
            phases: [
                ProgramPhase(
                    id: "61-w1",
                    weekNumber: 1,
                    name: "24時間断食に挑戦",
                    nameEn: "24-Hour Fast Challenge",
                    description: "初めての完全断食",
                    focusPoints: [
                        "夕食後〜翌日夕食まで24時間",
                        "水、お茶、ブラックコーヒーのみ",
                        "電解質の補給も検討"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "61-w2",
                    weekNumber: 2,
                    name: "断食の深化",
                    nameEn: "Deepen Fasting",
                    description: "断食中の過ごし方を学ぶ",
                    focusPoints: [
                        "軽い運動は可能",
                        "空腹感のピークは数時間で過ぎる",
                        "断食明けの食事は控えめに"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "61-w3",
                    weekNumber: 3,
                    name: "通常日の質向上",
                    nameEn: "Improve Normal Days",
                    description: "6日間の食事の質も高める",
                    focusPoints: [
                        "通常日もTDEE内で食べる",
                        "断食の反動で食べ過ぎない",
                        "栄養バランスを意識"
                    ],
                    calorieMultiplier: 0.9
                ),
                ProgramPhase(
                    id: "61-w4",
                    weekNumber: 4,
                    name: "習慣化",
                    nameEn: "Build Habit",
                    description: "週1断食を習慣に",
                    focusPoints: [
                        "曜日を固定（例：月曜断食）",
                        "予定に合わせて柔軟に変更可",
                        "長期継続のメンタル管理"
                    ],
                    calorieMultiplier: 0.9
                )
            ],
            sampleMeals: [
                SampleMeal(id: "61-b1", mealType: .breakfast, name: "通常日朝食", nameEn: "Normal Day Breakfast", calories: 450, protein: 25, fat: 18, carbs: 50, imageURL: nil),
                SampleMeal(id: "61-l1", mealType: .lunch, name: "通常日昼食", nameEn: "Normal Day Lunch", calories: 550, protein: 30, fat: 20, carbs: 60, imageURL: nil),
                SampleMeal(id: "61-d1", mealType: .dinner, name: "通常日夕食", nameEn: "Normal Day Dinner", calories: 500, protein: 28, fat: 18, carbs: 55, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "摂食障害の既往がある方には推奨しません"),
                Contraindication(condition: "pregnancy", severity: .prohibited, message: "妊娠中・授乳中は推奨しません"),
                Contraindication(condition: "diabetes_type1", severity: .prohibited, message: "完全断食は低血糖リスクが高いため推奨しません")
            ],
            recommendConditions: [],
            tags: ["ファスティング", "6:1", "週1断食", "24時間断食"],
            features: [
                "週に1日だけの断食",
                "オートファジーの活性化",
                "シンプルなルール",
                "柔軟なスケジュール"
            ],
            expectedResults: [
                "体重減少",
                "インスリン感受性の改善",
                "メンタルクリアリティ",
                "断食への耐性"
            ],
            imageURL: nil,
            layer: .timing,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 27. プロテイン・ウェイトロス
        DietProgram(
            id: "protein-weight-loss",
            nameJa: "プロテイン・ウェイトロス",
            nameEn: "Protein Weight Loss",
            category: .highProtein,
            description: "減量に特化し、脂質も控えめにしながらタンパク質を最大化するストイックなプラン。",
            descriptionEn: "Specialized for weight loss. Maximize protein while keeping fat moderate for a strict plan.",
            difficulty: .advanced,
            targetGoal: .lose,
            deficitIntensity: 0.2,
            basePFC: PFCRatio(protein: 40, fat: 25, carbs: 35),
            phases: [
                ProgramPhase(
                    id: "pwl-w1",
                    weekNumber: 1,
                    name: "高タンパク移行",
                    nameEn: "High Protein Transition",
                    description: "タンパク質中心の食事に切り替え",
                    focusPoints: [
                        "毎食タンパク質40g以上",
                        "脂質は控えめに（揚げ物禁止）",
                        "炭水化物は複合糖質のみ"
                    ],
                    calorieMultiplier: 0.85
                ),
                ProgramPhase(
                    id: "pwl-w2",
                    weekNumber: 2,
                    name: "カロリー制限強化",
                    nameEn: "Stricter Calorie Restriction",
                    description: "さらにカロリーを絞る",
                    focusPoints: [
                        "TDEE -20%を維持",
                        "空腹感はタンパク質で満たす",
                        "プロテインドリンクの活用"
                    ],
                    calorieMultiplier: 0.8
                ),
                ProgramPhase(
                    id: "pwl-w3",
                    weekNumber: 3,
                    name: "筋トレとの連携",
                    nameEn: "Coordinate with Training",
                    description: "運動で脂肪燃焼を加速",
                    focusPoints: [
                        "週3回以上の筋トレ",
                        "トレ後のプロテイン摂取",
                        "有酸素は控えめに"
                    ],
                    calorieMultiplier: 0.8
                ),
                ProgramPhase(
                    id: "pwl-w4",
                    weekNumber: 4,
                    name: "仕上げと維持",
                    nameEn: "Finish & Maintain",
                    description: "結果を確認し次のステップへ",
                    focusPoints: [
                        "体組成の変化を確認",
                        "リバウンド防止策",
                        "維持カロリーへの移行計画"
                    ],
                    calorieMultiplier: 0.8
                )
            ],
            sampleMeals: [
                SampleMeal(id: "pwl-b1", mealType: .breakfast, name: "卵白オムレツ", nameEn: "Egg White Omelette", calories: 280, protein: 35, fat: 8, carbs: 15, imageURL: nil),
                SampleMeal(id: "pwl-l1", mealType: .lunch, name: "鶏むね肉と野菜", nameEn: "Chicken Breast & Vegetables", calories: 350, protein: 45, fat: 10, carbs: 20, imageURL: nil),
                SampleMeal(id: "pwl-d1", mealType: .dinner, name: "白身魚のグリル", nameEn: "Grilled White Fish", calories: 320, protein: 40, fat: 12, carbs: 15, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "kidney_disease", severity: .warning, message: "高タンパク食は腎臓に負担がかかる場合があります"),
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "厳格なカロリー制限は摂食障害のリスクがあります")
            ],
            recommendConditions: [],
            tags: ["高タンパク", "減量", "ストイック", "筋肉維持"],
            features: [
                "タンパク質を最大化",
                "厳格なカロリー制限",
                "筋肉量の維持",
                "効率的な脂肪燃焼"
            ],
            expectedResults: [
                "体脂肪 -4〜6%",
                "筋肉量の維持",
                "明確な体型の変化",
                "代謝の維持"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 28. パレオ・ダイエット
        DietProgram(
            id: "paleo",
            nameJa: "パレオ・ダイエット",
            nameEn: "Paleo Diet",
            category: .highProtein,
            description: "旧石器時代の食事法。肉・魚・野菜を中心にし、穀物・乳製品・加工食品を避ける。",
            descriptionEn: "Paleolithic diet. Focus on meat, fish, vegetables. Avoid grains, dairy, and processed foods.",
            difficulty: .intermediate,
            targetGoal: .maintain,
            deficitIntensity: 0.05,
            basePFC: PFCRatio(protein: 30, fat: 40, carbs: 30),
            phases: [
                ProgramPhase(
                    id: "paleo-w1",
                    weekNumber: 1,
                    name: "穀物の排除",
                    nameEn: "Eliminate Grains",
                    description: "米、小麦、パスタを抜く",
                    focusPoints: [
                        "ご飯、パン、麺類を排除",
                        "野菜で炭水化物を補う",
                        "さつまいも、かぼちゃはOK"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "paleo-w2",
                    weekNumber: 2,
                    name: "乳製品の排除",
                    nameEn: "Eliminate Dairy",
                    description: "牛乳、チーズ、ヨーグルトを抜く",
                    focusPoints: [
                        "乳製品を完全に排除",
                        "カルシウムは小魚、緑野菜で補給",
                        "ナッツミルクで代替"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "paleo-w3",
                    weekNumber: 3,
                    name: "加工食品の排除",
                    nameEn: "Eliminate Processed Foods",
                    description: "自然食品のみに",
                    focusPoints: [
                        "原材料が5つ以上の食品を避ける",
                        "添加物、保存料を排除",
                        "自炊を基本に"
                    ],
                    calorieMultiplier: 0.95
                ),
                ProgramPhase(
                    id: "paleo-w4",
                    weekNumber: 4,
                    name: "パレオライフスタイル",
                    nameEn: "Paleo Lifestyle",
                    description: "原始人の食事を習慣に",
                    focusPoints: [
                        "草食牛肉、放し飼い卵を選ぶ",
                        "季節の野菜を中心に",
                        "外食時の対処法"
                    ],
                    calorieMultiplier: 0.95
                )
            ],
            sampleMeals: [
                SampleMeal(id: "paleo-b1", mealType: .breakfast, name: "卵とベーコン、野菜", nameEn: "Eggs, Bacon & Vegetables", calories: 450, protein: 28, fat: 35, carbs: 10, imageURL: nil),
                SampleMeal(id: "paleo-l1", mealType: .lunch, name: "グリルステーキとサラダ", nameEn: "Grilled Steak & Salad", calories: 550, protein: 40, fat: 35, carbs: 15, imageURL: nil),
                SampleMeal(id: "paleo-d1", mealType: .dinner, name: "焼き魚とロースト野菜", nameEn: "Grilled Fish & Roasted Vegetables", calories: 480, protein: 35, fat: 28, carbs: 25, imageURL: nil)
            ],
            contraindications: [],
            recommendConditions: [],
            tags: ["パレオ", "原始人食", "穀物フリー", "乳製品フリー"],
            features: [
                "穀物・乳製品を排除",
                "加工食品を排除",
                "自然食品のみ",
                "高タンパク・高脂質"
            ],
            expectedResults: [
                "体重減少",
                "消化機能の改善",
                "エネルギーレベルの安定",
                "炎症の軽減"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: true,
            canStackWithFocus: true
        ),

        // MARK: - 29. ケトジェニック（厳格）
        DietProgram(
            id: "ketogenic-strict",
            nameJa: "ケトジェニック（厳格）",
            nameEn: "Ketogenic Strict",
            category: .lowCarb,
            description: "糖質を1日20g以下に抑え、確実にケトーシスに入れる上級者向けプラン。",
            descriptionEn: "Keep carbs under 20g/day to ensure ketosis. For advanced users.",
            difficulty: .advanced,
            targetGoal: .lose,
            deficitIntensity: 0.15,
            basePFC: .keto,
            phases: [
                ProgramPhase(
                    id: "ks-w1",
                    weekNumber: 1,
                    name: "ケト導入",
                    nameEn: "Keto Introduction",
                    description: "糖質を20g以下に制限",
                    focusPoints: [
                        "糖質は1日20g以下",
                        "脂質を70%以上に",
                        "ケトフルー（適応期の不調）に備える"
                    ],
                    calorieMultiplier: 0.9,
                    pfcOverride: .keto
                ),
                ProgramPhase(
                    id: "ks-w2",
                    weekNumber: 2,
                    name: "ケトーシス確認",
                    nameEn: "Confirm Ketosis",
                    description: "体がケトン体を使い始める",
                    focusPoints: [
                        "ケトン体を測定（尿、血液）",
                        "電解質の補給（塩、マグネシウム）",
                        "水分を十分に摂る"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: .keto
                ),
                ProgramPhase(
                    id: "ks-w3",
                    weekNumber: 3,
                    name: "脂肪適応",
                    nameEn: "Fat Adaptation",
                    description: "体が脂肪を効率的に燃やす",
                    focusPoints: [
                        "エネルギーレベルの安定を実感",
                        "空腹感が減少",
                        "MCTオイルの活用"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: .keto
                ),
                ProgramPhase(
                    id: "ks-w4",
                    weekNumber: 4,
                    name: "維持と最適化",
                    nameEn: "Maintain & Optimize",
                    description: "長期的なケトライフ",
                    focusPoints: [
                        "野菜で食物繊維を確保",
                        "外食時の対処法",
                        "継続のコツ"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: .keto
                )
            ],
            sampleMeals: [
                SampleMeal(id: "ks-b1", mealType: .breakfast, name: "バターコーヒー＆卵", nameEn: "Butter Coffee & Eggs", calories: 450, protein: 20, fat: 42, carbs: 2, imageURL: nil),
                SampleMeal(id: "ks-l1", mealType: .lunch, name: "アボカドサーモンサラダ", nameEn: "Avocado Salmon Salad", calories: 550, protein: 30, fat: 45, carbs: 8, imageURL: nil),
                SampleMeal(id: "ks-d1", mealType: .dinner, name: "リブアイステーキとバター", nameEn: "Ribeye Steak with Butter", calories: 600, protein: 40, fat: 48, carbs: 2, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "ケトアシドーシスのリスクがあります。医師に相談してください"),
                Contraindication(condition: "kidney_disease", severity: .warning, message: "腎機能に影響がある場合は避けてください"),
                Contraindication(condition: "pregnancy", severity: .prohibited, message: "妊娠中・授乳中は推奨しません")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "fasting_insulin", condition: .above, threshold: 15, scoreBoost: 40),
                RecommendCondition(biomarker: "triglycerides", condition: .above, threshold: 200, scoreBoost: 35)
            ],
            tags: ["ケトジェニック", "厳格", "糖質制限", "ケトーシス", "NEW"],
            features: [
                "糖質1日20g以下",
                "確実なケトーシス",
                "脂肪燃焼の最大化",
                "空腹感の軽減"
            ],
            expectedResults: [
                "急速な体重減少",
                "体脂肪の大幅減少",
                "血糖値の安定",
                "メンタルクリアリティ"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: false,
            canStackWithFocus: true
        ),

        // MARK: - 30. ケト・バーン
        DietProgram(
            id: "keto-burn",
            nameJa: "ケト・バーン",
            nameEn: "Keto Burn",
            category: .lowCarb,
            description: "ケトジェニックの中でも、特に体脂肪燃焼を加速させるためのPFC比率に調整された特化プラン。",
            descriptionEn: "A specialized keto plan with PFC ratios adjusted to accelerate body fat burning.",
            difficulty: .advanced,
            targetGoal: .lose,
            deficitIntensity: 0.2,
            basePFC: PFCRatio(protein: 30, fat: 65, carbs: 5),
            phases: [
                ProgramPhase(
                    id: "kb-w1",
                    weekNumber: 1,
                    name: "脂肪燃焼モード突入",
                    nameEn: "Enter Fat Burn Mode",
                    description: "糖質を徹底排除",
                    focusPoints: [
                        "糖質は1日20g以下",
                        "タンパク質は適度に（過剰は糖新生を促す）",
                        "良質な脂質を中心に"
                    ],
                    calorieMultiplier: 0.85,
                    pfcOverride: PFCRatio(protein: 28, fat: 67, carbs: 5)
                ),
                ProgramPhase(
                    id: "kb-w2",
                    weekNumber: 2,
                    name: "脂肪燃焼加速",
                    nameEn: "Accelerate Fat Burn",
                    description: "カロリー制限を強化",
                    focusPoints: [
                        "TDEE -20%を維持",
                        "間食を減らす",
                        "ファスティングとの併用も検討"
                    ],
                    calorieMultiplier: 0.8,
                    pfcOverride: PFCRatio(protein: 30, fat: 65, carbs: 5)
                ),
                ProgramPhase(
                    id: "kb-w3",
                    weekNumber: 3,
                    name: "運動との組み合わせ",
                    nameEn: "Combine with Exercise",
                    description: "HIITで脂肪燃焼をブースト",
                    focusPoints: [
                        "週2〜3回のHIIT",
                        "空腹時の軽い有酸素",
                        "筋トレで代謝維持"
                    ],
                    calorieMultiplier: 0.8,
                    pfcOverride: PFCRatio(protein: 32, fat: 63, carbs: 5)
                ),
                ProgramPhase(
                    id: "kb-w4",
                    weekNumber: 4,
                    name: "結果確認と次のステップ",
                    nameEn: "Review & Next Steps",
                    description: "成果を確認し維持へ移行",
                    focusPoints: [
                        "体組成の変化を確認",
                        "維持プランへの移行",
                        "リバウンド防止策"
                    ],
                    calorieMultiplier: 0.8,
                    pfcOverride: PFCRatio(protein: 30, fat: 65, carbs: 5)
                )
            ],
            sampleMeals: [
                SampleMeal(id: "kb-b1", mealType: .breakfast, name: "MCTオイルコーヒーのみ", nameEn: "MCT Oil Coffee Only", calories: 200, protein: 0, fat: 22, carbs: 0, imageURL: nil),
                SampleMeal(id: "kb-l1", mealType: .lunch, name: "牛肉とチーズのプレート", nameEn: "Beef & Cheese Plate", calories: 600, protein: 40, fat: 48, carbs: 3, imageURL: nil),
                SampleMeal(id: "kb-d1", mealType: .dinner, name: "サーモンとアボカド", nameEn: "Salmon & Avocado", calories: 550, protein: 35, fat: 45, carbs: 5, imageURL: nil)
            ],
            contraindications: [
                Contraindication(condition: "diabetes_type1", severity: .warning, message: "ケトアシドーシスのリスクがあります。医師に相談してください"),
                Contraindication(condition: "eating_disorder_history", severity: .prohibited, message: "厳格な食事制限は摂食障害のリスクがあります"),
                Contraindication(condition: "pregnancy", severity: .prohibited, message: "妊娠中・授乳中は推奨しません")
            ],
            recommendConditions: [
                RecommendCondition(biomarker: "body_fat_percentage", condition: .above, threshold: 25, scoreBoost: 40)
            ],
            tags: ["ケト", "脂肪燃焼", "ハードコア", "短期集中", "NEW"],
            features: [
                "脂肪燃焼に特化",
                "厳格なカロリー制限",
                "HIITとの組み合わせ",
                "短期間で結果"
            ],
            expectedResults: [
                "体脂肪 -5〜8%",
                "急速な体重減少",
                "ウエストサイズの減少",
                "エネルギーレベルの向上"
            ],
            imageURL: nil,
            layer: .base,
            canStackWithFasting: false,
            canStackWithFocus: true
        )
    ]

    // MARK: - Helper Methods

    /// IDでプログラムを検索
    static func find(by id: String) -> DietProgram? {
        programs.first { $0.id == id }
    }

    /// カテゴリ・ゴールでフィルタリング
    static func filter(category: ProgramCategory? = nil, goal: GoalType? = nil, difficulty: ProgramDifficulty? = nil) -> [DietProgram] {
        programs.filter { program in
            if let cat = category, program.category != cat { return false }
            if let g = goal, program.targetGoal != g { return false }
            if let d = difficulty, program.difficulty != d { return false }
            return true
        }
    }

    /// タグで検索
    static func search(tag: String) -> [DietProgram] {
        let lowercasedTag = tag.lowercased()
        return programs.filter { program in
            program.tags.contains { $0.lowercased().contains(lowercasedTag) }
        }
    }

    /// 初心者向けプログラム
    static var beginnerPrograms: [DietProgram] {
        filter(difficulty: .beginner)
    }

    /// おすすめプログラム（デフォルト表示用）
    static var featuredPrograms: [DietProgram] {
        [
            find(by: "calibration"),
            find(by: "balanced-diet"),
            find(by: "low-carb-28")
        ].compactMap { $0 }
    }
}
