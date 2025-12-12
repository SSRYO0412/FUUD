//
//  BloodTestDetailView.swift
//  AWStest
//
//  血液検査項目詳細画面（Virgilデザイン）
//

import SwiftUI
import Charts

struct BloodTestDetailView: View {
    let bloodItem: BloodTestService.BloodItem
    @EnvironmentObject var bloodTestService: BloodTestService

    // 肝臓系項目かどうかを判定
    var isLiverRelated: Bool {
        let key = bloodItem.key.lowercased()
        switch key {
        case "ast", "got", "alt", "gpt", "ggt", "γ-gtp", "gamma_gtp", "alp":
            return true
        default:
            return false
        }
    }

    // 腎臓系項目かどうかを判定
    var isKidneyRelated: Bool {
        let key = bloodItem.key.lowercased()
        switch key {
        case "bun", "urea_nitrogen", "cre", "creatinine", "ua", "uric_acid":
            return true
        default:
            return false
        }
    }

    // HbA1c項目かどうかを判定
    var isHbA1c: Bool {
        let key = bloodItem.key.lowercased()
        return key == "hba1c" || key == "hemoglobin_a1c"
    }

    // 項目の説明を取得
    var itemDescription: [String]? {
        let key = bloodItem.key.lowercased()
        switch key {
        // 肝機能系
        case "ast", "got":
            return [
                "肝臓や心臓・筋肉のダメージを示す酵素で、肝炎・脂肪肝・筋損傷などのリスクをチェックする指標です。",
                "放置して高値が続くと、肝機能低下や肝硬変、心筋ダメージなどにつながる可能性があります。",
                "現代人では、過度な飲酒・残業続き・ハードすぎる運動で「だるい・疲れが抜けない」原因になりやすい項目です。",
                "対策として、飲酒量のコントロール・睡眠確保・筋トレやランニングの負荷管理（休養日を入れる）が重要です。",
                "タンパク質・抗酸化成分（ビタミンC/E、NAC、ミルクシスルなど）を意識した食事・サプリで肝臓と筋肉の回復をサポートできます。"
            ]
        case "alt", "gpt":
            return [
                "主に肝臓に存在する酵素で、「肝臓そのもののダメージ」をよりダイレクトに反映します。",
                "放置すると脂肪肝→肝炎→肝硬変といった長期的な肝疾患リスクが高まり、生活習慣病の温床になります。",
                "糖質・脂質のとり過ぎや内臓脂肪の増加とリンクしやすく、「太りやすい・痩せにくい・眠い」体質の背景になりがちです。",
                "改善には、夜遅い時間の過食を避け、糖質・脂質を抑えつつ、地味な有酸素運動（早歩き・ジョグ）を習慣化することが有効です。",
                "オメガ3脂肪酸（青魚・サプリ）、食物繊維、ビタミンB群を意識した食事が、脂肪肝と代謝の改善に役立ちます。"
            ]
        case "ggt", "γ-gtp", "gamma_gtp":
            return [
                "アルコールや薬剤、胆道系のトラブルで上がりやすい酵素で、「飲み方」や肝の解毒負荷のバロメーターです。",
                "高値を放置すると、アルコール性肝障害や脂肪肝、生活習慣病の進行につながるリスクがあります。",
                "「週末だけ激しく飲む」「毎日少しずつ飲む」など現代的な飲酒パターンの影響がダイレクトに出て、むくみ・肌荒れ・睡眠の質低下を招きやすい指標です。",
                "改善には、休肝日をしっかり作る・飲む量と頻度を明確に制限する・ノンアル飲料に置き換えるなどの行動が効果的です。",
                "タウリン・ビタミンB群・シリマリン（ミルクシスル）などを含む食事・サプリで解毒と回復をサポートできます。"
            ]
        case "alp":
            return [
                "肝臓・胆道系・骨の代謝に関わる酵素で、胆汁の流れや骨の状態をみる指標です。",
                "異常値を放置すると、胆道系疾患や骨代謝異常（骨粗鬆症など）の進行リスクがあります。",
                "ビタミンD不足・座りっぱなし生活・運動不足が重なると、骨の弱りや姿勢の崩れ→見た目の老け感に繋がりやすい項目です。",
                "日光に当たる時間を確保し、スクワットや階段昇降など骨に荷重がかかる運動を取り入れることが重要です。",
                "ビタミンD・カルシウム・ビタミンK2を食事やサプリで補うことで、骨と肝胆道系の健康維持に役立ちます。"
            ]
        case "t-bil", "tbil", "total_bilirubin":
            return [
                "赤血球分解でできる色素で、肝臓・胆道系・溶血の状態をみる指標です。",
                "異常値を放置すると、肝疾患・胆道系疾患・溶血性貧血などが進行し、黄疸や全身倦怠感が続く可能性があります。",
                "一部の人ではやや高めでも体質（ギルバート症候群など）の場合があり、抗酸化力と関連する可能性も指摘されています。",
                "アルコール・薬剤・過度な断食・極端なダイエットを見直し、肝臓への負担を減らす生活が重要です。",
                "バランスの良い食事・十分な水分・抗酸化食品（色の濃い野菜・果物）やサプリで、解毒と抗酸化システムをサポートできます。"
            ]
        case "d-bil", "dbil", "direct_bilirubin":
            return [
                "肝臓で処理された後のビリルビンで、胆汁の流れや肝細胞の障害をよりピンポイントで示します。",
                "高値を放置すると、胆道閉塞や肝障害が悪化し、強い黄疸・かゆみ・脂溶性ビタミン不足などに繋がります。",
                "脂肪の多い食事・アルコール・一部薬剤など現代生活の要因で胆汁の流れが乱れると、消化不良やお腹の張りの原因になることがあります。",
                "揚げ物や過度な高脂肪食を控え、適度な運動と体重管理で胆汁の流れを保つことが肝胆道系のケアになります。",
                "胆汁酸サポート系サプリやレシチン、ビタミンA/D/E/Kなどの脂溶性ビタミンを、医師や専門家と相談しながら活用することで、脂質消化と肝胆の健康をサポートできます。"
            ]

        // 血糖・代謝系
        case "hba1c", "hemoglobin_a1c":
            return [
                "過去1〜2か月の平均的な血糖コントロールを示す指標で、糖尿病リスク評価の中心となります。",
                "高い状態を放置すると、網膜症・腎症・神経障害・心筋梗塞・脳梗塞などの合併症リスクがじわじわ上昇します。",
                "「食後すぐ眠くなる」「脂肪が落ちない」「肌のくすみ・たるみ」が気になる現代人にとって、糖化と老化スピードを示すウェルネス指標でもあります。",
                "改善には、糖質の質と量（精製炭水化物を減らし、食物繊維とたんぱく質を増やす）と、毎食後の軽いウォーキングなどが効果的です。",
                "マグネシウム・クロム・α-リポ酸・イヌリン（食物繊維）などを意識した食事・サプリが、血糖コントロールと体重管理をサポートします。"
            ]

        // 脂質系
        case "tg", "triglyceride":
            return [
                "余ったエネルギーが蓄えられた形で、食べ過ぎ・飲み過ぎ・運動不足がダイレクトに反映される脂質指標です。",
                "高値を放置すると、動脈硬化・脂肪肝・膵炎などのリスクが高まり、将来の心血管イベントに繋がる可能性があります。",
                "「下腹だけ落ちない」「朝だるい」「検診で脂肪肝と言われた」といった現代的な悩みと強く関連します。",
                "改善には、甘い飲料・スイーツ・アルコールを減らし、週150分以上の有酸素運動＋日常の歩数アップが基本です。",
                "オメガ3（魚油・亜麻仁油）、水溶性食物繊維、MCTなどを取り入れると、TG低下と脂肪燃焼効率アップに役立ちます。"
            ]
        case "hdl", "hdl_cholesterol":
            return [
                "「善玉コレステロール」と呼ばれ、余分なコレステロールを回収して動脈硬化を防ぐ方向に働きます。",
                "低値を放置すると、LDLが普通でも血管トラブル（心筋梗塞・脳梗塞）のリスクが上がりやすくなります。",
                "運動不足・喫煙・高糖質食など現代的ライフスタイルで下がりやすく、「血管年齢」やスタミナ低下の背景になりがちです。",
                "毎日のウォーキング・ジョギング・軽い筋トレ、禁煙、良質な脂質（オリーブオイル・ナッツ・青魚）を増やすことで改善しやすい指標です。",
                "オメガ3脂肪酸・ナイアシンなどを意識した食事・サプリで、HDLをサポートし、全体の脂質バランスを整えられます。"
            ]
        case "ldl", "ldl_cholesterol":
            return [
                "「悪玉コレステロール」と呼ばれ、増えすぎると血管の壁にたまり動脈硬化を進めます。",
                "高値を放置すると、心筋梗塞・脳梗塞など、命に関わるイベントのリスクが長期的に上昇します。",
                "飽和脂肪・トランス脂肪・過剰なカロリー、ストレス・睡眠不足などが重なると「内臓脂肪＋血管老化」のセットを招きやすい項目です。",
                "改善には、揚げ物や加工肉を控え、魚・豆類・オリーブオイル中心の地中海食＋有酸素運動の組み合わせが王道です。",
                "植物ステロール・水溶性食物繊維（オーツ・野菜・サプリ）を取り入れることで、LDL低下を後押しできます。"
            ]
        case "tc", "tcho", "total_cholesterol":
            return [
                "血中コレステロール全体の量を示し、動脈硬化や心血管疾患リスクの大まかな指標になります。",
                "高値を放置すると、心筋梗塞・脳梗塞などのリスクが長期的に上昇し、血管年齢の加速につながります。",
                "逆に低すぎるとホルモン・ビタミンD・細胞膜の材料が不足し、メンタル不調や疲れやすさ、肌のパサつきといった悩みにも繋がりかねません。",
                "バランスの良い脂質（魚・ナッツ・オリーブオイル）を取りつつ、加工食品・揚げ物・過剰カロリーを減らすことが重要です。",
                "必要に応じて、オメガ3サプリ・植物ステロール・食物繊維サプリを組み合わせ、LDL/HDLバランスも合わせてチェックしていきます。"
            ]

        // 鉄・貧血系
        case "fe", "iron":
            return [
                "血液中を流れている「今使える鉄」の量で、貧血や鉄不足の有無をみる指標です。",
                "低値を放置すると、貧血が進行し、動悸・息切れ・頭痛・冷え・集中力低下などが続く慢性的な不調につながります。",
                "「いつも眠い」「午後にパフォーマンスが落ちる」「髪や爪が弱い」など、現代人のささいな悩みの背景になりやすい項目です。",
                "赤身肉・魚・レバー・卵黄・緑色野菜をバランスよく摂り、ビタミンCと一緒に摂ることで吸収を高められます。",
                "必要に応じて医師の管理下で鉄サプリを用いながら、過度なダイエットや極端な菜食を避けることが重要です。"
            ]
        case "uibc":
            return [
                "「まだ鉄を運べる空き容量」を示す指標で、Fe・フェリチンと組み合わせて鉄不足の段階を評価します。",
                "鉄不足状態を放置すると、見かけ上の数値が正常でも、隠れ貧血が進行し、慢性的な疲労やパフォーマンス低下が続きます。",
                "「数値は正常と言われたけど、ずっとだるい」という現代人のモヤモヤを可視化するのに役立ちます。",
                "改善には、ヘム鉄食品（赤身肉・魚）とビタミンC、銅・亜鉛など鉄代謝に関わるミネラルをバランスよく摂ることが大切です。",
                "専門家の管理のもとでの鉄サプリ＋月経やスポーツ量を考慮した栄養設計が、パフォーマンスと見た目の両方を守ります。"
            ]
        case "ferritin":
            return [
                "体内に蓄えられている「貯金としての鉄」の量を示す、鉄不足評価で最も重要な指標の一つです。",
                "低値を放置すると、将来的な貧血リスクだけでなく、筋力・持久力低下、抜け毛や肌のくすみなどの「なんとなく老けた」感につながります。",
                "女性・アスリート・忙しいビジネスパーソンでは、フェリチン不足が「根性では解決しない疲れ」の原因になりがちです。",
                "赤身肉・魚・大豆製品・緑黄色野菜を意識しつつ、過度な節制ダイエットを避けることが重要です。",
                "医師のフォローのもと、鉄サプリ・ビタミンC・ビタミンB群を組み合わせて「鉄の貯金」を回復させることで、パフォーマンスと見た目の両方が改善しやすくなります。"
            ]

        // 腎機能系
        case "bun", "urea_nitrogen":
            return [
                "タンパク質代謝で出る老廃物で、腎臓がどれだけうまく処理できているかを見る指標です。",
                "異常値を放置すると、腎機能低下や尿毒症、心血管リスクの上昇につながる可能性があります。",
                "高タンパク食＋水分不足＋ハードトレーニングという現代アスリート・トレーニーのライフスタイルで乱れやすい項目です。",
                "こまめな水分補給・過度な高タンパク食の見直し・塩分を控えた食事が腎臓の負担軽減に役立ちます。",
                "腎臓に配慮したプロテイン量設定や、カリウム・マグネシウム・オメガ3を含む食事・サプリで「攻めつつ守る」栄養戦略が重要です。"
            ]
        case "cre", "creatinine":
            return [
                "筋肉から出る老廃物で、腎臓のろ過機能（GFR）を評価するための主要マーカーです。",
                "高値を放置すると、慢性腎臓病の進行や、将来的な透析リスク上昇に繋がり得ます。",
                "筋肉量が多い人ではやや高めになりやすい一方、脱水・サプリの乱用・鎮痛薬多用など現代的要因で悪化しやすい項目です。",
                "水分を十分に摂る・NSAIDs（痛み止め）の乱用を避ける・血圧と血糖を管理することが腎臓保護の基本です。",
                "必要に応じて、腎臓に優しい食事（塩分・動物性たんぱくを抑える）やオメガ3などのサプリを取り入れ、医師とモニタリングしながら調整します。"
            ]
        case "ua", "uric_acid":
            return [
                "プリン体代謝の最終産物で、高いと痛風発作や腎障害、動脈硬化リスクと関係します。",
                "高尿酸血症を放置すると、痛風発作だけでなく、腎機能低下やメタボリックシンドロームの進行に繋がります。",
                "「ビール・肉・ストレス多め・水分少なめ」という現代人のパターンで上がりやすく、関節痛やなんとなくの疲労感の原因にもなります。",
                "改善には、水をしっかり飲む・アルコール（特にビール・日本酒）と肉・内臓系の摂取を控える・体重を落とすことが重要です。",
                "ビタミンC・乳製品・コーヒーなどは尿酸値改善にプラスに働くとされ、必要に応じて医師の処方薬と併用します。"
            ]

        // タンパク質系
        case "tp", "total_protein":
            return [
                "血液中の総タンパク質量で、栄養状態や慢性炎症、肝臓・腎臓の機能をざっくりとみる指標です。",
                "異常を放置すると、免疫力低下・浮腫み・筋力低下・回復力の低下などが長期的に進行します。",
                "忙しさで食事を抜きがち・糖質ばかり・ジャンクが多い現代人では、筋肉と肌・髪のクオリティ低下の背景になりやすい項目です。",
                "各食事で良質なタンパク源（肉・魚・卵・大豆）をしっかり摂り、極端なダイエットを避けることが基本です。",
                "プロテインサプリ・EAA・コラーゲンなどを、食事で足りない分の補完として上手に活用するのが有効です。"
            ]
        case "alb", "albumin":
            return [
                "血漿タンパクの中心で、栄養状態と肝臓・腎臓の働きを反映します。",
                "低値を放置すると、浮腫み・易疲労・免疫低下・傷の治りにくさなどが持続し、全身状態の悪化に繋がります。",
                "高ストレス・不規則な食生活・長時間労働で「いつも疲れている」現代人では、じわじわ低下しやすい項目です。",
                "タンパク質とカロリーを適切に摂りながら、アルコールを控え、睡眠を確保することが重要です。",
                "オメガ3・抗酸化成分・ビタミンB群を含む食事やサプリで、肝機能をサポートしつつアルブミン低下を防ぐことができます。"
            ]
        case "palb", "prealbumin":
            return [
                "変動が早く、最近の栄養状態を反映しやすいタンパク質で、短期的な栄養不足のチェックに使われます。",
                "低値を放置すると、短期間でも筋肉量減少・免疫力低下・手術やケガからの回復遅延などに繋がります。",
                "忙しい時期に「気づいたら1日ほぼカフェラテだけ」みたいな生活が続くと、見た目にはわからなくてもpAlbが落ちやすいです。",
                "各食事でタンパク質とエネルギーをしっかり確保し、間食もプロテインバーやナッツなど「栄養のあるもの」にすることが大切です。",
                "短期的にプロテインサプリやEAAを活用しながら、最低限の食事リズムを整えることで数値改善を狙えます。"
            ]

        // 炎症・筋肉系
        case "crp", "c_reactive_protein":
            return [
                "体内の炎症レベルを示すマーカーで、感染症・ケガ・慢性炎症などがあると上昇します。",
                "高値を放置すると、動脈硬化・糖尿病・認知症などの慢性疾患リスクが上がることが知られています。",
                "寝不足・ストレス・ジャンクフード・過度なトレーニングなどが重なると「隠れ炎症」が続き、疲労感や老け見えの原因になります。",
                "十分な睡眠・ストレスマネジメント・抗炎症的な食事（魚・オリーブオイル・野菜・フルーツ）・適度な運動が炎症低下に有効です。",
                "オメガ3・クルクミン・ポリフェノールなどのサプリは、ライフスタイル改善と組み合わせることで炎症コントロールをサポートします。"
            ]
        case "ck", "cpk", "creatine_kinase":
            return [
                "筋肉や心筋のダメージで上がる酵素で、トレーニング負荷やケガの程度を反映します。",
                "極端な高値を放置すると、横紋筋融解症や腎機能障害のリスクがあり、救急対応が必要になることもあります。",
                "「気合いで追い込みすぎる」現代トレーニーでは、CKの慢性的な高め状態が回復不良・パフォーマンス頭打ちの原因になりがちです。",
                "トレーニング量と強度の周期化（オフ・イージーデイを作る）・睡眠確保・ストレッチやマッサージが重要です。",
                "十分なタンパク質・EAA/BCAA・クレアチン・電解質・オメガ3などで筋ダメージからの回復を支えることができます。"
            ]
        case "mg", "magnesium":
            return [
                "数百以上の酵素反応に関わるミネラルで、筋肉・神経・心臓・睡眠の質などに深く関与します。",
                "不足を放置すると、筋けいれん・不整脈・不眠・イライラ・血圧上昇など、多彩な不調が長期的に現れます。",
                "カフェイン・アルコール・ストレス・加工食品中心の生活で消耗しやすく、現代人では潜在的不足が非常に多いミネラルです。",
                "ナッツ・種子類・全粒穀物・海藻・豆類を意識して摂ることで、日常的なマグネシウム補給ができます。",
                "睡眠前のマグネシウムサプリ（クエン酸Mg・グリシネートなど）は、筋リラックスと睡眠の質向上に役立つことがあります。"
            ]

        default:
            return nil
        }
    }

    // 絵文字マッピング（BloodItemCardと同じロジック）
    var emoji: String {
        let key = bloodItem.key.lowercased()
        switch key {
        // 血糖・代謝系
        case "hba1c", "hemoglobin_a1c": return ""
        case "glucose", "glu", "blood_sugar": return "🩸"
        case "ga", "glycoalbumin": return "🍰"
        case "1,5-ag", "1_5_ag": return "🍯"

        // 肝機能系（カスタム画像を使用）
        case "ast", "got": return ""
        case "alt", "gpt": return ""
        case "ggt", "γ-gtp", "gamma_gtp": return ""
        case "alp": return ""
        case "t-bil", "tbil", "total_bilirubin": return "💛"
        case "d-bil", "dbil", "direct_bilirubin": return "💛"

        // 脂質系
        case "tc", "tcho", "total_cholesterol": return "🧈"
        case "tg", "triglyceride": return "🥓"
        case "hdl", "hdl_cholesterol": return "👼"
        case "ldl", "ldl_cholesterol": return "👿"
        case "apob", "apo_b": return "🔬"
        case "lp(a)", "lipoprotein_a": return "🧬"

        // タンパク質系
        case "tp", "total_protein": return "🥩"
        case "alb", "albumin": return "🥚"
        case "palb", "prealbumin": return "🥛"

        // 腎機能系（カスタム画像を使用）
        case "bun", "urea_nitrogen": return ""
        case "cre", "creatinine": return ""
        case "ua", "uric_acid": return ""
        case "egfr": return "🚰"

        // 炎症・免疫系
        case "crp", "c_reactive_protein": return "🔥"
        case "wbc", "white_blood_cell": return "🛡️"
        case "neutrophil": return "⚔️"

        // 血液成分系
        case "rbc", "red_blood_cell": return "🔴"
        case "hb", "hemoglobin": return "🩸"
        case "ht", "hematocrit": return "📊"
        case "mcv": return "📏"
        case "mch": return "📐"
        case "mchc": return "🎨"
        case "plt", "platelet": return "🩹"

        // ミネラル・ビタミン系
        case "fe", "iron": return "⚙️"
        case "ferritin": return "🧲"
        case "zn", "zinc": return "⚡"
        case "mg", "magnesium": return "💚"
        case "ca", "calcium": return "🦴"
        case "vitamin_d", "vit_d": return "☀️"
        case "vitamin_b12", "vit_b12": return "🌟"

        // 筋肉・運動系
        case "ck", "cpk", "creatine_kinase": return "💪"
        case "mb", "myoglobin": return "🏃"
        case "lac", "lactate": return "🔋"

        // 甲状腺系
        case "tsh": return "🦋"
        case "ft3", "ft4": return "🦋"

        // ホルモン系
        case "cortisol": return "😰"
        case "testosterone": return "💪"
        case "estrogen": return "🌸"

        default: return "🔬"
        }
    }

    // ステータス色
    var statusColor: Color {
        switch bloodItem.statusColor {
        case "green":
            return Color(hex: "00C853")
        case "orange":
            return Color(hex: "FFCB05")
        case "red":
            return Color(hex: "ED1C24")
        default:
            return .gray
        }
    }

    var body: some View {
        ZStack {
            // Background
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            // Orb Background Animation
            OrbBackground()

            ScrollView {
                VStack(spacing: VirgilSpacing.lg) {
                    // ヘッダースコアカード
                VStack(spacing: VirgilSpacing.sm) {
                    // アイコン（肝臓系・腎臓系・HbA1cはカスタム画像、それ以外は絵文字）
                    if isLiverRelated {
                        Image("liver_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if isKidneyRelated {
                        Image("kidney_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if isHbA1c {
                        Image("sugar_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else {
                        Text(emoji)
                            .font(.system(size: 32))
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(bloodItem.value)
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(statusColor)

                        Text(bloodItem.unit)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text(bloodItem.status)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(8)

                    Text(bloodItem.nameJp.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // 説明セクション（詳細情報の上に追加）
                if let descriptions = itemDescription {
                    VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                        Text("この項目について")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                            ForEach(Array(descriptions.enumerated()), id: \.offset) { _, text in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.virgilTextSecondary)
                                    Text(text)
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundColor(.virgilTextPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(VirgilSpacing.md)
                    .liquidGlassCard()
                }

                // 詳細情報カード
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("詳細情報")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        DetailInfoRow(label: "検査項目", value: bloodItem.nameJp)
                        DetailInfoRow(label: "項目キー", value: bloodItem.key.uppercased())
                        DetailInfoRow(label: "測定値", value: "\(bloodItem.value) \(bloodItem.unit)")
                        DetailInfoRow(label: "判定", value: bloodItem.status, valueColor: statusColor)
                        DetailInfoRow(label: "基準範囲", value: bloodItem.reference)
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // 推奨事項カード
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("推奨事項")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        ForEach(Array(getRecommendations().enumerated()), id: \.offset) { index, recommendation in
                            BloodRecommendationCard(
                                icon: index == 0 ? "💡" : (index == 1 ? "🎯" : "📋"),
                                text: recommendation,
                                priority: index == 0 ? "高" : (index == 1 ? "中" : "低")
                            )
                        }
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()

                // 履歴トレンドカード
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("履歴トレンド")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    if bloodTestService.hasHistory {
                        let history = bloodTestService.getValueHistory(for: bloodItem.key)

                        if history.isEmpty {
                            emptyHistoryView
                        } else {
                            VStack(spacing: VirgilSpacing.sm) {
                                ForEach(Array(history.enumerated()), id: \.offset) { index, record in
                                    HistoryRecordRow(
                                        timestamp: record.timestamp,
                                        value: record.value,
                                        unit: bloodItem.unit,
                                        isLatest: index == 0,
                                        previousValue: index < history.count - 1 ? history[index + 1].value : nil
                                    )
                                }
                            }
                        }
                    } else {
                        emptyHistoryView
                    }
                }
                .padding(VirgilSpacing.md)
                .liquidGlassCard()
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.md)
            .padding(.bottom, 100)
            }
        }
        .navigationTitle(bloodItem.nameJp)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Helper Methods

    private func getRecommendations() -> [String] {
        // 血液検査項目に基づく簡単な推奨事項生成
        let status = bloodItem.status.lowercased()
        let key = bloodItem.key.lowercased()

        var recommendations: [String] = []

        if ["正常", "normal"].contains(status) {
            recommendations.append("現在の値は正常範囲内です。現在の生活習慣を維持してください。")
            recommendations.append("定期的な健康診断を受けることをお勧めします。")
        } else {
            recommendations.append("値が基準範囲外です。医師に相談することをお勧めします。")

            if key.contains("glucose") || key.contains("血糖") {
                recommendations.append("食事のバランスを見直し、適度な運動を心がけてください。")
                recommendations.append("糖質の摂取量に注意してください。")
            } else if key.contains("cholesterol") || key.contains("コレステロール") {
                recommendations.append("飽和脂肪酸の摂取を控え、オメガ3脂肪酸を摂取してください。")
                recommendations.append("定期的な有酸素運動を行ってください。")
            } else if key.contains("pressure") || key.contains("血圧") {
                recommendations.append("塩分摂取量を控えてください。")
                recommendations.append("ストレス管理と十分な睡眠を心がけてください。")
            } else {
                recommendations.append("バランスの取れた食事と適度な運動を心がけてください。")
                recommendations.append("十分な休息とストレス管理を行ってください。")
            }
        }

        return recommendations
    }

    // MARK: - Helper Views

    private var emptyHistoryView: some View {
        VStack(spacing: VirgilSpacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.virgilTextSecondary)

            Text("まだ履歴データがありません")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(VirgilSpacing.xl)
        .background(Color.black.opacity(0.02))
        .cornerRadius(12)
    }

}

// MARK: - Detail Info Row

struct DetailInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color? = nil

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(valueColor ?? .virgilTextPrimary)

            Spacer()
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(6)
    }
}

// MARK: - Blood Recommendation Card

struct BloodRecommendationCard: View {
    let icon: String
    let text: String
    let priority: String

    private var priorityColor: Color {
        switch priority {
        case "高": return Color(hex: "ED1C24")
        case "中": return Color(hex: "FFCB05")
        case "低": return Color(hex: "0088CC")
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            Text(icon)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                Text(text)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.virgilTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(priority)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(priorityColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(priorityColor.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - History Record Row

struct HistoryRecordRow: View {
    let timestamp: String
    let value: String
    let unit: String
    let isLatest: Bool
    let previousValue: String?

    private var formattedDate: String {
        // ISO8601形式からフォーマット変換
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            displayFormatter.locale = Locale(identifier: "ja_JP")
            return displayFormatter.string(from: date)
        }
        return timestamp
    }

    private var trendIcon: String? {
        guard let prevValue = previousValue,
              let currentNum = Double(value),
              let prevNum = Double(prevValue) else {
            return nil
        }

        if currentNum > prevNum {
            return "arrow.up.right"
        } else if currentNum < prevNum {
            return "arrow.down.right"
        } else {
            return "arrow.right"
        }
    }

    private var trendColor: Color {
        guard let prevValue = previousValue,
              let currentNum = Double(value),
              let prevNum = Double(prevValue) else {
            return .gray
        }

        if currentNum > prevNum {
            return Color(hex: "ED1C24") // 上昇 = 赤
        } else if currentNum < prevNum {
            return Color(hex: "00C853") // 下降 = 緑（検査値の場合、低い方が良いことが多い）
        } else {
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                HStack(spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)

                    if isLatest {
                        Text("最新")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(Color(hex: "0088CC"))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(hex: "0088CC").opacity(0.1))
                            .cornerRadius(4)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.virgilTextPrimary)

                    Text(unit)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                }
            }

            Spacer()

            if let icon = trendIcon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(trendColor)
            }
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct BloodTestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BloodTestDetailView(
                bloodItem: BloodTestService.BloodItem(
                    key: "glucose",
                    nameJp: "血糖値",
                    value: "95",
                    unit: "mg/dL",
                    status: "正常",
                    reference: "70-110"
                )
            )
        }
    }
}
