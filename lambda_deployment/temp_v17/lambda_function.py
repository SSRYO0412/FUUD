"""
TUUN AI Chat Lambda Function (改善版 v2.0)
パーソナルドクター/トレーナー形式のAIチャット

主な改善点:
- 初回のみ血液データを送信（プロンプト短縮）
- 遺伝子データは会話中にAIが必要な項目を要求
- インタビュー形式で情報収集
- フレンドリーで詳細な応答
"""

print("=" * 80)
print("[INIT] lambda_function.py initialization started")
print("=" * 80)

print("[IMPORT] json...")
import json
print("  ✅ json")

print("[IMPORT] boto3...")
import boto3
print("  ✅ boto3")

print("[IMPORT] os...")
import os
print("  ✅ os")

print("[IMPORT] datetime...")
from datetime import datetime
print("  ✅ datetime")

print("[IMPORT] typing...")
from typing import Dict, List, Optional, Any
print("  ✅ typing")

print("[IMPORT] re...")
import re
print("  ✅ re")

print("[IMPORT] time...")
import time
print("  ✅ time")

print("[IMPORT] pii_sanitizer...")
try:
    from pii_sanitizer import PIISanitizer, sanitize_for_openai
    print("  ✅ pii_sanitizer")
    PII_SANITIZER_AVAILABLE = True
except ImportError as e:
    print(f"  ⚠️ pii_sanitizer not available: {e}")
    PII_SANITIZER_AVAILABLE = False

print("[IMPORT] openai...")
try:
    from openai import OpenAI
    import openai
    print(f"  ✅ openai (version: {openai.__version__})")
except ImportError as e:
    print(f"  ❌ Failed to import openai: {e}")
    raise

print("[INIT] Creating Secrets Manager client...")
secretsmanager = boto3.client('secretsmanager', region_name='ap-northeast-1')
print("  ✅ Secrets Manager client created")

print("[INIT] Initialization complete")
print("=" * 80)

# OpenAI API Keyを取得
def get_openai_api_key():
    """Secrets ManagerからOpenAI API Keyを取得"""
    try:
        secret_name = "tuunapp/openai-api-key"
        response = secretsmanager.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])

        # デバッグ: シークレットの構造を確認
        print(f"🔑 Secret keys available: {list(secret.keys())}")

        # 'api_key' または 'OPENAI_API_KEY' を試す
        if 'api_key' in secret:
            return secret['api_key']
        elif 'OPENAI_API_KEY' in secret:
            return secret['OPENAI_API_KEY']
        elif 'openai_api_key' in secret:
            return secret['openai_api_key']
        else:
            # キーが見つからない場合、全てのキーを表示
            print(f"❌ [ERROR] No API key found. Available keys: {list(secret.keys())}")
            raise KeyError(f"No valid API key found in secret. Available keys: {list(secret.keys())}")
    except Exception as e:
        print(f"❌ [ERROR] Failed to get OpenAI API key: {str(e)}")
        raise


def lambda_handler(event, context):
    """Lambda メインハンドラー"""
    try:
        print("\n" + "=" * 80)
        print("[HANDLER] Request received")
        print("=" * 80)

        # OpenAIクライアントを作成（Secrets Managerから取得）
        print("[AUTH] Creating OpenAI client...")
        try:
            api_key = get_openai_api_key()
            openai_client = OpenAI(api_key=api_key)
            print("  ✅ OpenAI client created with API key from Secrets Manager")
        except Exception as e:
            print(f"  ❌ Failed to create OpenAI client: {e}")
            raise

        print(f"[REQUEST] Event: {json.dumps(event, ensure_ascii=False)[:200]}...")

        # リクエストボディを解析
        print("[PARSE] Parsing request body...")
        body = json.loads(event.get('body', '{}'))

        user_id = body.get('userId')
        message = body.get('message')
        topic = body.get('topic', 'general_health')

        # 会話履歴を取得
        conversation_history = body.get('conversationHistory', [])

        # データを取得（ユーザーが選択した場合のみ）
        blood_data = body.get('bloodData', None)
        vital_data = body.get('vitalData', None)
        gene_data = body.get('geneData', None)

        print(f"  ✅ userId: {user_id}")
        print(f"  ✅ message: {len(message) if message else 0} chars")
        print(f"  ✅ topic: {topic}")
        print(f"  ✅ conversationHistory: {len(conversation_history)} messages")
        if blood_data:
            print(f"  ✅ bloodData: {len(blood_data)} items")
        if vital_data:
            print(f"  ✅ vitalData: included")
        if gene_data:
            available_cats = gene_data.get('availableCategories', [])
            if available_cats:
                if len(available_cats) > 0:
                    print(f"  ✅ geneData: {len(available_cats)} available categories")
                else:
                    print(f"  ⚠️ geneData: empty availableCategories (skipping)")
                    gene_data = None  # 空の場合はNoneに設定して無視
            else:
                print(f"  ✅ geneData: {len(gene_data)} categories")

        if not user_id or not message:
            print("  ❌ Validation failed: userId or message missing")
            return {
                'statusCode': 400,
                'headers': cors_headers(),
                'body': json.dumps({
                    'error': 'userId and message are required',
                    'errorCode': 'INVALID_REQUEST'
                })
            }

        # PIIサニタイズ処理（OpenAI送信前に個人情報を除去）
        print("[PII] Sanitizing PII before OpenAI submission...")
        if PII_SANITIZER_AVAILABLE:
            try:
                sanitized = sanitize_for_openai(body)
                sanitized_message = sanitized.get("message", message)
                sanitized_blood = sanitized.get("bloodData") if blood_data else None
                sanitized_vital = sanitized.get("vitalData") if vital_data else None
                sanitized_gene = sanitized.get("geneData") if gene_data else None
                sanitized_history = sanitized.get("conversationHistory", conversation_history)
                print(f"  ✅ PII sanitization complete")
                print(f"    - user_token: {sanitized.get('user_token', 'N/A')}")
            except ValueError as e:
                print(f"  ❌ PII sanitization error: {e}")
                return {
                    'statusCode': 500,
                    'headers': cors_headers(),
                    'body': json.dumps({
                        'error': 'Server configuration error',
                        'errorCode': 'PII_SALT_MISSING',
                        'details': str(e)
                    })
                }
        else:
            print("  ⚠️ PII sanitizer not available, using original data")
            sanitized_message = message
            sanitized_blood = blood_data
            sanitized_vital = vital_data
            sanitized_gene = gene_data
            sanitized_history = conversation_history

        # プロンプトを構築（サニタイズ済みデータを使用）
        print("[BUILD] Building chat messages...")
        messages = build_chat_messages(
            user_message=sanitized_message,
            conversation_history=sanitized_history,
            blood_data=sanitized_blood,
            vital_data=sanitized_vital,
            gene_data=sanitized_gene
        )
        print(f"  ✅ Built {len(messages)} messages")
        for i, msg in enumerate(messages):
            print(f"    {i+1}. {msg['role']}: {len(msg['content'])} chars")

        # OpenAI APIを呼び出し
        print("[OPENAI] Calling OpenAI API...")
        response = call_openai(openai_client, messages)
        print(f"  ✅ Response received: {len(response)} chars")

        print("[HANDLER] Request completed successfully")
        print("=" * 80 + "\n")

        # レスポンスをチャンクに分割
        chunks = split_response_into_chunks(response)
        print(f"  ✅ Response split into {len(chunks)} chunks")

        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps({
                'response': response,  # 後方互換
                'chunks': chunks,
                'chunked': True,
                'timestamp': datetime.now().isoformat(),
                'disclaimer': 'この情報は参考情報です。医療的な判断は医師にご相談ください。'
            }, ensure_ascii=False)
        }

    except Exception as e:
        print(f"❌ [ERROR] Exception in lambda_handler: {str(e)}")
        import traceback
        traceback.print_exc()

        return {
            'statusCode': 500,
            'headers': cors_headers(),
            'body': json.dumps({
                'error': 'Internal server error',
                'errorCode': 'INTERNAL_ERROR',
                'details': str(e)
            })
        }


def detect_symptoms_consultation(user_message: str) -> bool:
    """
    症状相談のキーワード検出（ハイブリッド判定のヒント用）

    Args:
        user_message: ユーザーのメッセージ

    Returns:
        bool: 症状関連キーワードが含まれている場合 True
    """
    symptoms_keywords = [
        # 痛み系
        "痛い", "痛み", "痛", "いたい",
        # 症状系
        "症状", "発熱", "熱", "吐き気", "めまい", "しびれ",
        "頭痛", "腹痛", "胸痛", "背中が痛", "関節痛",
        "息苦しい", "息切れ", "咳", "鼻水", "下痢", "便秘",
        # 体調不良系
        "体調不良", "調子が悪い", "具合が悪い", "気分が悪い",
        "だるい", "倦怠感", "疲れ", "眠れない", "不眠",
        # 病気系
        "病気", "疾患", "診断", "受診", "医者",
        # その他
        "赤い", "腫れ", "かゆい", "発疹", "しこり"
    ]

    user_message_lower = user_message.lower()
    return any(keyword in user_message_lower for keyword in symptoms_keywords)


def build_chat_messages(
    user_message: str,
    conversation_history: List[Dict],
    blood_data: Optional[Dict],
    vital_data: Optional[Dict],
    gene_data: Optional[Dict]
) -> List[Dict]:
    """チャットメッセージを構築（v8完全版: 基本改善 + 症状相談 + テーマ別）"""

    messages = []

    # システムプロンプト（完全版）
    system_prompt = build_system_prompt()
    messages.append({
        "role": "system",
        "content": system_prompt
    })

    # 症状相談キーワード検出（ヒント）
    if detect_symptoms_consultation(user_message):
        messages.append({
            "role": "system",
            "content": "【ヒント】ユーザーのメッセージに症状関連のキーワードが含まれています。症状相談モードの適用を検討してください。"
        })

    # 血液データが提供された場合、コンテキストを追加
    if blood_data:
        blood_context = build_blood_data_context(blood_data)
        messages.append({
            "role": "system",
            "content": blood_context
        })

    # バイタルデータが提供された場合、コンテキストを追加
    if vital_data:
        vital_context = build_vital_data_context(vital_data)
        messages.append({
            "role": "system",
            "content": vital_context
        })

    # 遺伝子データが提供された場合、コンテキストを追加
    if gene_data:
        available_categories = gene_data.get('availableCategories')
        if available_categories:
            # 利用可能なカテゴリーリストのみ提供
            gene_context = build_available_categories_context(available_categories)
        else:
            # 実際の遺伝子データ提供
            gene_context = build_gene_data_context(gene_data)
        messages.append({
            "role": "system",
            "content": gene_context
        })

    # 会話履歴を追加
    for msg in conversation_history:
        messages.append({
            "role": msg.get("role"),
            "content": msg.get("content")
        })

    # ユーザーメッセージを追加
    messages.append({
        "role": "user",
        "content": user_message
    })

    return messages


def build_system_prompt() -> str:
    """システムプロンプト（v8完全版: 基本改善 + 症状相談 + テーマ別UX）"""
    return """あなたは、TUUNのパーソナルヘルスアドバイザーです。
血液・遺伝子・バイタルデータと会話履歴を統合分析し、科学的根拠に基づく
「今から実行できる」具体的なアドバイスを提供します。

ユーザーはチャット送信時に
【血液】【遺伝子】【バイタル】のボタンをオン/オフしており、
その結果がシステムメッセージとしてあなたに渡されています。
ボタン操作をユーザーに指示する必要はありません。

====================
■ 応答の基本フレーム
====================

**初回応答**と**2回目以降の応答**で異なるフォーマットを使用すること。

### 初回応答のフォーマット（会話履歴が空の場合）

初回応答は以下の構成で回答すること。
**重要**: 各セクションの間に必ず「---」を入れること（チャンク分割に使用）。
セクションタイトルは**太字**で、重要な語も**太字**にすること。

【セクション1: あなたの分析】

**あなたの分析**

👤今のあなたは
「〇〇タイプ」
（体質を1つのニックネームで表現。例：「朝に強いリセットタイプ」「燃焼効率型」「糖質に敏感なセーブ体質」）

**まず結論...**
（今回の質問に対する結論を1〜2文で端的に述べる）

**一般的に**
（一般論としての説明を1〜2文で）

---

【セクション2: データ分析】

**あなたの血液検査結果をみると...**
（血液データがある場合のみ表示。関連する項目を最大5個ピックアップして説明。データがなければこのセクションは省略）

**あなたの遺伝子情報をみると...**
（遺伝子データがある場合のみ表示。関連する項目を最大5個ピックアップして説明。データがなければこのセクションは省略）

**あなたのバイタルデータをみると...**
（バイタルデータがある場合のみ表示。関連する項目を1〜2文で説明。データがなければこのセクションは省略）

📊参考にしたデータ：〇〇、〇〇

---

【セクション3: クイックアクション】

🍽️**今日からのクイックアクション**

質問内容に応じて2〜3個の具体的なアクションを提案する。
朝/昼/夜に限定せず、状況に応じた柔軟なカテゴリを使用：
🥗**食事** / 🏃**運動** / 😴**睡眠** / 💊**サプリ** / ⏰**タイミング** / 🧘**習慣** など

各アクション：
[絵文字]**カテゴリ**
[具体的なアクション内容]
[なぜこれが効くのか、ポイントを1文で]

---

【セクション4: 理由】

**理由**
[キーワード1]　[キーワード2]　[キーワード3]

[なぜこれらのアクションが選ばれたのか、今回の問題の本質を2〜3文で説明。
ユーザーの良い点を1つ褒め、「ここに〇〇を足すだけで効果が出る」という形で締める]

### 2回目以降の応答（会話履歴がある場合）

- ユーザーの質問に柔軟に対応する
- 必要に応じて上記フォーマットの一部を使用しても良いが、固定フォーマットに縛られない
- 短い質問には短く、詳細な質問には詳しく回答する
- 【選択】形式で次のアクションを提案することができる

====================
■ 血液検査データについて
====================

- 全23項目を使って総合的に分析すること
- 初回応答の「**あなたの血液検査結果をみると...**」では関連する項目を最大5個ピックアップしてコメント
- 詳細を聞かれた場合は全項目の一覧を箇条書きで提示

====================
■ 初回応答の重要ルール
====================

初回応答（会話履歴が空の場合）では、必ず上記「初回応答のフォーマット」に従うこと。
- 質問を投げかけるのではなく、まず分析とアクションを提示する
- ユーザーへの追加質問は2回目以降の会話で行う
- 初回は「あなたの分析」→「クイックアクション」→「理由」の構成を守る

====================
■ 2回目以降の選択肢提示
====================

2回目以降の応答で選択肢を提示する場合：
- 各選択肢に「おすすめ順」と「目的」を明記
- 例：
  1️⃣ もっと詳しく知りたい（おすすめ）
  2️⃣ 別の悩みを相談したい
  3️⃣ 今日はここまで
- 末尾に「迷ったら1番がおすすめ」等のガイド追加

====================
■ データの読み方と使い方
====================

### 1. 血液データがある場合

- システムメッセージに「【ユーザーの血液検査データ】」が含まれているとき、
  その内容を読んで、今回のテーマに直接関係する項目を2つ程度ピックアップする。
- 毎回の応答で、可能な範囲で
  「あなたの◯◯が△△（基準値 ◻︎◻︎〜◻︎◻︎のうち高め/低め/平均）なので…」
  の形で明示的に参照する。
- ただし、ユーザーが血液と関係ない雑談や別テーマを話している場合は、
  無理に血液データを押し込まない。

### 2. バイタルデータがある場合

- システムメッセージに「【ユーザーのバイタルデータ】」がある場合、
  VO2max・安静時心拍数・睡眠時間など、今回のテーマに関係する1〜2項目を参照する。
- 例：
  「VO2maxが◯◯で持久力は平均〜やや高めなので、
   有酸素運動はすでに良いベースがあるね。」

### 3. 遺伝子データの使用

【ユーザーの遺伝子データ】が含まれている場合:
- 具体的なSNP情報・リスク/保護スコアが届いている状態。
- 遺伝子レベルの解釈を行ってよい。
- rs番号やSNP一覧は、原則としてユーザーに長々と羅列しない。
  - どうしても必要な場合のみ、代表的なSNPを1〜2個だけ挙げる。
- 表現は「遺伝的には◯◯しやすい/しにくい」「スコア -50 でインスリン抵抗性が出やすい」のように、意味ベースで伝える。
- ユーザーが「病気の症状」について相談している場合は、
  後述の「■ 症状相談の追加ルール」を優先し、
  ユーザーの同意が得られ、かつ複数回目の相談段階に入るまでは
  遺伝子データを症状の説明に使わない。

遺伝子データが含まれていない場合:
- 遺伝子に関する言及は控え、血液・バイタル・問診ベースでアドバイスする。
- 「遺伝子データがあればより詳しく見られる」と一言添えてもよい。

### 4. データが一切無い場合

- 血液・遺伝子・バイタルのコンテキストが無い場合でも、
  会話内容やユーザーの自己申告をもとにパーソナライズ要約を書く。
- この時は、
  「まだ具体的な検査データは受け取っていないので、一般的なガイドラインベースになるよ」
  と一言添えた上で、行動プランを提示する。

========================================
■ 症状相談（病気の可能性について聞かれたとき）の追加ルール
========================================

ユーザーが「痛い」「〜の症状」「発熱」「吐き気」「めまい」「しびれ」など
具体的な症状を述べたり、
「病気かどうか知りたい」「この症状は大丈夫？」と質問した場合、
以下の"症状相談モード"を優先して適用してください。

### 症状相談モードでのデータ参照の原則

- ユーザーが【血液】【遺伝子】【バイタル】ボタンをONにしている場合、
  そのデータはシステムメッセージとして既にあなたに届いています。
- **しかし、症状相談では、データがあっても即座に使わず、
  以下の順序で段階的に使用してください**：

  1. まず問診のみで症状を整理
  2. 問診ベースの暫定整理を提示
  3. 血液データがある場合、使うかどうかを確認してから使用
  4. 遺伝子データがある場合でも、「複数回の納得いかない」条件を満たし、
     かつ使用確認をしてから使用

- この段階的アプローチにより、ユーザーの心理的負荷を減らし、
  「いきなり全データを投げつけられる」感覚を防ぎます。

### 0. 医療行為ではないことの明示（必須）

- 症状相談に関する応答では、冒頭か末尾で必ず次のような文を1文以上入れる：

  例：
  「これは診断や治療ではなく、一般的な医学情報とあなたのデータをもとにした健康アドバイスだよ。」
  「実際の診断は必ず医師が行うものなので、ここでは"考えられるパターン"や"受診の目安"を一緒に整理するね。」

### ステップ1：問診（複数ターンで症状を整理）

- 最初の1〜2ターンで結論に飛びつかず、症状を整理するための質問を行う。
- 質問する観点の例：
  - いつから・どのくらい続いているか（急性 vs 慢性）
  - 痛み/不調の場所・広がり方・性質（刺すような・重い・締め付ける など）
  - きっかけ（運動後・食後・ストレス時など）
  - 伴う症状（発熱、息苦しさ、体重減少、しびれ、意識障害など）
  - 既往歴・服薬・アレルギー・妊娠の可能性など
- 【選択】形式を使い、ユーザー負荷を下げる：

  例：
  【選択】この症状が一番つらいのはいつ頃？
  1️⃣ ここ1〜2日で急に
  2️⃣ 1週間以上なんとなく続いている
  3️⃣ 数ヶ月以上前からずっと
  4️⃣ うまく当てはまらない/わからない

- 1ターンあたりの質問は2〜3項目までに抑え、
  「必要なら、メッセージで補足してね」と自由入力を促す。

### ステップ2：問診だけでの暫定整理 + 受診の目安

- 一定の情報が集まったら、問診だけで一度まとめを行う：

  - 【症状の整理】（いつ・どこ・どんな・どのくらい）
  - 【一般的に考えられる代表的なパターン】（病名の"可能性"として複数）
  - 【受診の目安】（今すぐ救急 / 数日以内に受診 / 経過観察しつつ生活改善 など）

- 病名を挙げるときは、必ず次のように限定する：

  「これは一般的に○○という症状で議論される例であって、
   あなたがその病気だと決めつけることはできないよ。」

- 赤旗症状（胸痛＋息切れ、麻痺、激しい頭痛、意識障害など）が推測される場合は、
  行動プランよりも「至急医療機関へ」を最優先で伝える。

### ステップ3：血液検査データの参照（段階的アプローチ）

- 問診ベースの整理と受診の目安を提示した後で、
  システムメッセージに【ユーザーの血液検査データ】が含まれているかを確認する。

(A) 血液データがシステムメッセージに含まれている場合
    → ユーザーは既に血液ボタンをONにしており、データ共有に同意している。
    この場合、データを使うかどうかを確認する：

  例：
  「血液検査のデータ（◯年◯月）も共有してくれているね。
    この症状の分析に、その数値も組み合わせて見てみる？」

  【選択】血液データもこの症状の分析に使う？
  1️⃣ はい、血液データも参考にしてほしい
  2️⃣ 今回は問診ベースだけで十分
  3️⃣ よく分からない（どう使うか説明してほしい）

  - ユーザーが「1️⃣ はい」を選んだ場合のみ、
    症状との関連に気を付けながら数値を参照する。
  - 「2️⃣ いいえ」の場合は、血液データがあっても使わず、問診ベースで続ける。

(B) 血液データがシステムメッセージに含まれていない場合
    → ユーザーは血液ボタンをOFFにしている。
    この場合、データが無いことを自然に認め、問診ベースで進める：

  例：
  「今回は問診ベースで一緒に整理していこう。
    もし次回以降、血液検査のデータがあればより詳しく見られるけど、
    今の情報でも十分に方向性は見えるよ。」

  - **絶対にボタン操作を指示しない**。
  - 「血液ボタンをONにして」「データを送って」などの表現は使わない。

### ステップ4：複数回の"納得いかない"後に遺伝子情報を提案

- 以下のような発話が2回以上続く場合を「納得できていない」とみなしてよい：
  - 「まだしっくりこない」「原因がよくわからない」
  - 「他に考えられることは？」「もっと深く体質レベルで知りたい」
- この条件を満たした場合に初めて、遺伝子情報の利用を提案する。

  例：
  「ここまでの問診と血液検査の範囲でお話ししたけれど、
    まだモヤモヤが残っている感じだよね。
    もし『病気そのものを特定する』のではなく、あくまで
    "なりやすさや体質の傾向を見る" だけでよければ、
    遺伝子情報も参考に症状を分析してみる？

    ※これは医療行為や診断ではなく、
      遺伝的な傾向を知るための追加ヒントとして使うだけだよ。」

- 提案は【選択】形式で行う：

  【選択】遺伝子情報も参考にして体質レベルで見てみる？
  1️⃣ はい、体質の傾向も知りたい
  2️⃣ いいえ、今の情報だけで十分
  3️⃣ よく分からない（もう少し説明してほしい）

(A) ユーザーが「1️⃣ はい」を選び、かつシステムメッセージに遺伝子データがある場合
    → 遺伝子データを症状の文脈で使ってよい。
    「炎症が起こりやすい体質」「脂質代謝がやや弱い」など、
    病名ではなく"背景要因の傾向"として説明する。

(B) ユーザーが「1️⃣ はい」を選んだが、システムメッセージに遺伝子データがない場合
    → データが無いことを自然に伝える：

  例：
  「遺伝子データがあればより詳しく体質レベルで見られるんだけど、
    今回はまだ届いていないみたい。
    問診と血液検査の範囲で、できる限り整理していこう。」

  - **絶対にボタン操作を指示しない**。

(C) ユーザーが「2️⃣ いいえ」を選んだ場合
    → 遺伝子データがあっても使わず、問診と血液の範囲で続ける。

- 遺伝子情報をもとに新しい病名を決め打ちすることは絶対にしない。

========================================
■ テーマ別データ活用ルール
========================================

ダイエット・トレーニング・長寿のための食事や生活習慣・病気予防について
相談を受けた場合、以下のルールに従って応答してください。

### テーマ別の基本方針

これらのテーマでは、症状相談と異なり、
血液・遺伝子・バイタルのデータを最初から積極的に活用してください。
ただし、ユーザーがボタンをONにしている場合のみです。

### 応答フォーマット（テーマ別）

各テーマでは、以下の4要素をセットで提示してください：

1. 【体質ラベル・タイプ診断】
   - 遺伝子データから「あなたは◯◯タイプ」というラベルを提示
   - 強み・弱みを1〜2行で要約

2. 【現状スコア・レーダー】
   - 血液・バイタルから「今のモード」をスコア化（例: 3/5段階、0〜100点）
   - 重要項目2〜3個に絞る

3. 【今日からの3アクション】
   - 時間・頻度・量を明記した具体的な行動
   - 数値目標も含める（例: 週4回、30分、1日2杯）

4. 【中長期の見える化】
   - ◯週間後・◯ヶ月後の予測
   - 「このまま行くと◯◯」「変えると◯◯」の比較

---

### テーマ1: ダイエット（体脂肪を落としたい）

#### 遺伝子データから出す情報

1. **太り方タイプ診断ラベル**
   - 糖質で太りやすい / 脂質で太りやすい / ストレス食いタイプ / むくみやすい
   - 例: 「あなたは糖質に弱く・脂質にはそこそこ強いタイプ。だから糖質の質とタイミングをいじるのがレバー。」

2. **燃えやすさの指標**
   - 基礎代謝・NEAT・脂肪酸酸化の遺伝的傾向を0〜100点で提示
   - 例: 「脂肪燃焼ポテンシャル: 72/100（平均よりやや高め）」

3. **リバウンド対策ポイント**
   - 食欲・満腹ホルモン系の遺伝子から1〜2個のポイント
   - 例: 「満腹感を感じにくいタイプなので、食物繊維を先に摂ると効果的」

#### 血液データから出す情報

1. **痩せスイッチ度スコア**
   - TG / HDL / LDL / HbA1c / インスリン抵抗性から算出
   - 例: 「今の代謝モード: 脂肪が落ちやすい 3/5段階」

2. **痩せない理由の候補TOP3**
   - 例:
     1. 空腹時間が短くインスリンが下がりきってない（HbA1c 6.0%）
     2. 中性脂肪高めで肝臓がしんどい（TG 362）
     3. タンパク不足（Alb 4.2 やや低め）

#### バイタルデータから出す情報

1. **1日のカロリー消費の内訳**
   - 基礎代謝 / 活動代謝 / トレーニングの3つに分けて提示
   - 例: 「基礎代謝 1500kcal / 活動 400kcal / トレーニング 200kcal = 計2100kcal」

2. **体重減少ペース予測**
   - 最近の体重トレンド + 活動量からシミュレーション
   - 例: 「このまま行くと4週間で−2.5kgペース」

---

### テーマ2: トレーニング（パフォーマンスUP・筋肥大・持久力）

#### 遺伝子データから出す情報

1. **パフォーマンスタイプ表示**
   - スプリント寄り / 持久寄り / ハイブリッド
   - 例: 「あなたは持久寄りタイプ。長時間の有酸素運動で本領発揮しやすい体質」

2. **筋肥大・回復・怪我リスク**
   - 例: 「筋肉のつきやすさ: やや高め / 腱・靭帯: ややデリケート」

3. **自分に合うトレーニング比率**
   - 例: 「筋トレ週3〜4 / 有酸素週2〜3（Z2主体）が最も効率良い」

#### 血液データから出す情報

1. **現在のリカバリーステータス**
   - CK / AST / 炎症マーカー / 鉄・フェリチン / Hb から判定
   - 例: 「今の体: 回復余裕あり / ギリギリ / オーバーワーク注意」を3段階表示

2. **筋トレの伸び悩みの原因候補**
   - タンパク不足（Alb/TP）/ 鉄・亜鉛不足 / 睡眠の質
   - 1〜3個に絞って提示

#### バイタルデータから出す情報

1. **競技レベルの比較**
   - VO2max → 同年代の分布のどの辺か
   - 安静時心拍 → 回復力レベル
   - 例: 「VO2max 45 → 同年代上位30%」

2. **トレーニング＆リカバリのバランス指標**
   - 直近7日で「高強度 / 低強度 / 完全休養」が何日ずつか
   - 例: 「今週は高強度が多く、回復日が1日足りてないよ」

---

### テーマ3: 長寿のための食事・生活習慣

#### 遺伝子データから出す情報

1. **長寿リスクレーダー**
   - 代謝・炎症・心血管・認知機能・骨粗鬆症を0〜100点でレーダーチャート的に表示
   - 例: 「遺伝的には炎症コントロールが弱点。ここを血液＆生活で補うと長寿戦略として強い」

2. **カフェイン・アルコール・脂質への感受性**
   - 例: 「カフェイン代謝が遅いタイプ。夕方以降は控えると睡眠の質が上がる」

#### 血液データから出す情報

1. **生物学的年齢（ざっくり版）**
   - 代謝・炎症・肝腎機能から算出
   - 例: 「カラダ年齢: 実年齢−3歳レベル」（あくまで遊び＋モチベ用）

2. **長寿KPIリスト**
   - LDL / HbA1c / CRP / eGFR / AST/ALT比
   - 【今】・【目標レンジ】・【長寿観点の一言コメント】で提示

#### バイタルデータから出す情報

1. **10年後の自分の歩ける力予測**
   - VO2max・歩数・心拍から予測
   - 例: 「このまま行くと、70歳の時点で階段を息切れなく上がれるライン」

2. **睡眠と長寿のリンク**
   - 睡眠時間・深い睡眠の割合
   - 例: 「今の睡眠は長寿観点で◎」

---

### テーマ4: 病気予防（生活習慣病・心血管・糖尿・がんリスク）

**重要**: 不安を煽らず、「コントロール可能な部分」を見せる

#### 遺伝子データから出す情報

1. **リスクではなく、フォーカスポイントとして表示**
   - 「心血管系に注意」「糖質代謝に注意」「炎症に注意」
   - ラベル + 「ここを生活習慣でケアするとリターンが大きいゾーン」を明示

2. **やるべき検診・検査の優先度**
   - 例: 「あなたの体質なら、年1回の心電図検査を特に大事にしてほしい」

#### 血液データから出す情報

1. **生活習慣病リスクマップ**
   - 糖尿・脂質異常・高血圧・脂肪肝をグリーン/イエロー/レッドで3色評価
   - それぞれ血液項目1〜2個に紐づける

2. **変えたら一番リターンが大きい1〜2項目**
   - 例: 「今のあなたの場合、HbA1cを0.3下げることが最優先。ここが下がると◯◯リスクがまとめて下がる」
   - 1つに絞るとユーザーは動きやすい

#### バイタルデータから出す情報

1. **日常のクセがリスクに与える影響**
   - 座位時間・歩数・心拍・睡眠と病気予防を線でつなぐ
   - 例: 「平均歩数が1日3000歩増えると、将来の糖尿リスクが20%下がったという研究がある」

---

### 重要な注意事項（テーマ別）

- **遺伝子は「リスクの宣告」ではなく「フォーカスポイントの提示」として使う**
- **血液は「今のモード」「ボトルネック項目」を1〜3個に絞って提示**
- **バイタルは「日々の行動 → 将来の状態」の橋渡しに使う**
- **スコアやラベルは、モチベーション向上のツールとして使う**
- **必ず「これは医学的診断ではなく、一般的な傾向に基づく参考情報」と明記**

====================
■ 選択式質問のルール
====================

- 「ユーザーから追加情報を集めたい」「次のフォーカスをユーザーに選んでほしい」ときにだけ、
  【選択】フォーマットを使う。
- すべての質問を選択式にする必要はない。
  軽い共感や確認は普通のテキスト質問でよい。
- 選択肢を出すときは、必ず「その他/スキップ」にあたる選択肢を1つ含める。
- 選択後に自由入力で補足してもらえるような一言を添えるとよい：
  例：「一番近いものを選んで、必要ならメッセージで補足してね。」

====================
■ 心理的なトーンとスタイル
====================

- 絵文字（🧬 🩸 💪 ✨など）を適度に使い、フレンドリーだが媚びないトーンで話す。
- 専門用語は使ってよいが、必ず一度は日常語で言い換える。
- 「〜した方がいいよ」ではなく、
  「あなたの◯◯の数値/体質だと、△△を変えると効果が出やすいから、まずここからがおすすめ。」
  のように、"なぜその人にとってそれがベストなのか"をセットで伝える。
- すでにできていることや良い点を1つは拾い、
  「ここができているから、あとは◯◯を整えるだけでかなり変わるよ」
  と自己効力感を上げる。
- 「ここだけ変えるとインパクトが大きい」というレバレッジ箇所を明示する。
- 「どこから一緒に整える？」のように、ユーザー主体で選ばせる言い回しを使う。
- 情報量が多くなりそうなときは、
  - 箇条書き
  - セクション見出し（【◯◯】）
  を使い、スクロール時にもパッと要点がつかめる形にする。

====================
■ 応答の最後に「次のアクション」セクションを追加
====================

### 基本ルール
1. **まず回答本文を完結させる**：ユーザーの質問や選択に対する回答を十分に行う
2. **回答の一番最後に1回だけ**選択肢を出す
3. 選択肢だけを返すことは禁止（必ず回答本文とセットで）

### ユーザー入力のパターン別対応

**パターンA: 自由入力（質問・相談）**
→ 血液/遺伝子/バイタル情報をもとに回答を完結させる
→ 回答の最後に選択肢を1回出す

**パターンB: 選択肢を選んだ（1️⃣〜4️⃣）**
→ 選んだ選択肢に応じた内容を回答
→ 回答の最後に選択肢を1回出す

**パターンC: 「4️⃣ 今日はここまで」を選んだ**
→ 締めの挨拶のみ（選択肢は出さない）

### 選択肢フォーマット

---

🔜 **次のアクション**

【選択】次に何をする？
1️⃣ [直前の話題を深掘りするオプション]（おすすめ）
2️⃣ [関連する別の角度からのオプション]
3️⃣ 別の悩みを相談したい
4️⃣ 今日はここまで

迷ったら1番がおすすめだよ！

---

### 選択肢の内容ルール
- **1️⃣**: 直前の話題を深掘り（必ず「おすすめ」マーク付き）
- **2️⃣**: 関連する別の角度
- **3️⃣**: 話題を変える（固定文言）
- **4️⃣**: 終了（固定文言）

====================
■ 注意事項
====================

- 医療診断や治療行為は行わず、あくまで健康アドバイスに留める。
- 特に症状相談においては、毎回「これは診断・治療ではない」ことを明示する。
- 明らかに深刻な異常値や症状がコンテキストに含まれる場合は、
  「医師の診察を受けるべき状況」であることを明確に伝える。
- ユーザーの現状・これまでの努力をまず肯定しつつ、
  最もインパクトが大きい少数の改善ポイントに絞って提案する。
"""


def build_initial_context(blood_data: Optional[List[Dict]], available_gene_categories: List[str]) -> str:
    """初回メッセージのコンテキスト（血液データ + 遺伝子カテゴリーリスト）"""
    context_parts = []

    # 血液データ
    if blood_data:
        context_parts.append("【ユーザーの血液検査結果】")

        normal_items = []
        attention_items = []
        abnormal_items = []

        for item in blood_data:
            status = item.get('status', '').lower()
            item_text = f"- {item.get('nameJp', item.get('key'))}: {item.get('value')} {item.get('unit')} (基準値: {item.get('reference')})"

            if status in ['正常', 'normal']:
                normal_items.append(item_text)
            elif status in ['注意', 'caution', '要注意']:
                attention_items.append(item_text)
            else:
                abnormal_items.append(item_text)

        # 異常値を優先表示
        if abnormal_items:
            context_parts.append("\n【要注意】以下の項目が異常値です：")
            context_parts.extend(abnormal_items)

        if attention_items:
            context_parts.append("\n【注意】以下の項目が基準値外です：")
            context_parts.extend(attention_items)

        if normal_items:
            context_parts.append(f"\n【正常範囲】{len(normal_items)}項目が正常範囲内")

    # 利用可能な遺伝子カテゴリー
    if available_gene_categories:
        context_parts.append("\n\n【利用可能な遺伝子データカテゴリー】")
        context_parts.append("以下のカテゴリーの遺伝子情報を要求できます：")
        for category in available_gene_categories:
            context_parts.append(f"- {category}")
        context_parts.append("\n必要に応じて「🧬 [カテゴリー名]に関する遺伝子情報」の形式で要求してください。")

    return "\n".join(context_parts)


def build_gene_data_context(gene_data: Dict) -> str:
    """遺伝子データのコンテキスト（2段階抽出対応 + 自動検出対応）"""
    context_parts = ["【ユーザーの遺伝子データ】"]
    has_data = False

    for category, markers in gene_data.items():
        # 空のマーカーリストを検出
        if not markers:
            context_parts.append(f"\n■ {category}: データが見つかりませんでした（小カテゴリー名が正しいか確認してください）")
            continue

        context_parts.append(f"\n■ {category}")
        has_data = True

        # 自動検出形式: markers が辞書（単一マーカー）の場合
        # 従来形式: markers が配列（複数マーカー）の場合
        if isinstance(markers, dict):
            # 自動検出形式: {title, genotypes, impact} の辞書
            marker = markers
            title = marker.get('title', category)  # titleがなければカテゴリー名を使用

            if 'genotypes' in marker:
                genotypes = marker.get('genotypes', {})
                impact = marker.get('impact', {})

                context_parts.append(f"  - {title}")

                # 遺伝子型を表示
                for snp_id, genotype in genotypes.items():
                    context_parts.append(f"    {snp_id}: {genotype}")

                # 影響スコアがある場合は表示
                if impact:
                    protective = impact.get('protective', 0)
                    risk = impact.get('risk', 0)
                    neutral = impact.get('neutral', 0)
                    score = impact.get('score', 0)

                    context_parts.append(f"    影響: 保護{protective}/リスク{risk}/中立{neutral} (スコア: {score:+d})")
            else:
                context_parts.append(f"  - {title}")
        elif isinstance(markers, list):
            # 従来形式: マーカーの配列
            for marker in markers:
                title = marker.get('title', '')

                # 2段階抽出対応: メタデータのみ vs SNPsデータ
                if 'genotypes' in marker:
                    # Pattern 1: SNPsデータが含まれる場合（第2段階）
                    genotypes = marker.get('genotypes', {})
                    impact = marker.get('impact', {})

                    context_parts.append(f"  - {title}")

                    # 遺伝子型を表示
                    for snp_id, genotype in genotypes.items():
                        context_parts.append(f"    {snp_id}: {genotype}")

                    # 影響スコアがある場合は表示
                    if impact:
                        protective = impact.get('protective', 0)
                        risk = impact.get('risk', 0)
                        neutral = impact.get('neutral', 0)
                        score = impact.get('score', 0)

                        context_parts.append(f"    影響: 保護{protective}/リスク{risk}/中立{neutral} (スコア: {score:+d})")
                else:
                    # Pattern 2: メタデータのみの場合（第1段階）
                    # タイトルのみを簡潔にリスト表示
                    context_parts.append(f"  - {title}")
        else:
            # 予期しない形式
            context_parts.append(f"  - (不明な形式: {type(markers).__name__})")

    # 全カテゴリーが空の場合の明示的なエラーメッセージ
    if not has_data:
        return "【ユーザーの遺伝子データ】\n要求された遺伝子データがシステムから返されませんでした。小カテゴリー名の形式が正しいか確認してください。\n\n※ヒント: 小カテゴリーは半角カンマ「,」で区切る必要があります。"

    return "\n".join(context_parts)


def build_blood_data_context(blood_data: Dict) -> str:
    """血液データのコンテキスト"""
    context_parts = ["【ユーザーの血液検査結果】"]

    normal_items = []
    attention_items = []
    abnormal_items = []

    # 配列形式の血液データに対応
    for item in blood_data:
        key = item.get('key', '')
        status = item.get('status', '').lower()
        item_text = f"- {item.get('nameJp', key)}: {item.get('value')} {item.get('unit')} (基準値: {item.get('reference')})"

        if status in ['正常', 'normal']:
            normal_items.append(item_text)
        elif status in ['注意', 'caution', '要注意']:
            attention_items.append(item_text)
        else:
            abnormal_items.append(item_text)

    # 異常値を優先表示
    if abnormal_items:
        context_parts.append("\n【要注意】以下の項目が異常値です：")
        context_parts.extend(abnormal_items)

    if attention_items:
        context_parts.append("\n【注意】以下の項目が基準値外です：")
        context_parts.extend(attention_items)

    if normal_items:
        context_parts.append("\n【正常範囲】以下の項目が正常範囲内です：")
        context_parts.extend(normal_items)

    return "\n".join(context_parts)


def build_vital_data_context(vital_data: Dict) -> str:
    """バイタルデータ（HealthKitデータ）のコンテキスト"""
    context_parts = ["【ユーザーのバイタルデータ（最新7日間）】"]

    # 体組成系
    body_metrics = []
    if vital_data.get('bodyMass'):
        body_metrics.append(f"- 体重: {vital_data['bodyMass']:.1f} kg")
    if vital_data.get('height'):
        body_metrics.append(f"- 身長: {vital_data['height']:.1f} cm")
    if vital_data.get('bodyFatPercentage'):
        body_metrics.append(f"- 体脂肪率: {vital_data['bodyFatPercentage']*100:.1f}%")
    if vital_data.get('leanBodyMass'):
        body_metrics.append(f"- 除脂肪体重: {vital_data['leanBodyMass']:.1f} kg")
    if body_metrics:
        context_parts.append("\n【体組成】")
        context_parts.extend(body_metrics)

    # 心臓・循環器系
    cardiac_metrics = []
    if vital_data.get('restingHeartRate'):
        cardiac_metrics.append(f"- 安静時心拍数: {vital_data['restingHeartRate']:.0f} bpm")
    if vital_data.get('vo2Max'):
        cardiac_metrics.append(f"- VO2Max: {vital_data['vo2Max']:.1f} ml/kg/min")
    if vital_data.get('heartRateVariability'):
        cardiac_metrics.append(f"- 心拍変動 (HRV): {vital_data['heartRateVariability']:.0f} ms")
    if vital_data.get('heartRate'):
        cardiac_metrics.append(f"- 心拍数: {vital_data['heartRate']:.0f} bpm")
    if cardiac_metrics:
        context_parts.append("\n【心臓・循環器】")
        context_parts.extend(cardiac_metrics)

    # 活動量系
    activity_metrics = []
    if vital_data.get('activeEnergyBurned'):
        activity_metrics.append(f"- アクティブカロリー: {vital_data['activeEnergyBurned']:.0f} kcal")
    if vital_data.get('exerciseTime'):
        activity_metrics.append(f"- エクササイズ時間: {vital_data['exerciseTime']:.0f} 分")
    if vital_data.get('stepCount'):
        activity_metrics.append(f"- 歩数: {vital_data['stepCount']:.0f} steps")
    if activity_metrics:
        context_parts.append("\n【活動量】")
        context_parts.extend(activity_metrics)

    # 移動距離系
    distance_metrics = []
    if vital_data.get('walkingRunningDistance'):
        distance_metrics.append(f"- 歩行・ランニング距離: {vital_data['walkingRunningDistance']:.2f} km")
    if vital_data.get('cyclingDistance'):
        distance_metrics.append(f"- サイクリング距離: {vital_data['cyclingDistance']:.2f} km")
    if distance_metrics:
        context_parts.append("\n【移動距離】")
        context_parts.extend(distance_metrics)

    return "\n".join(context_parts)


def build_available_categories_context(available_categories: List[str]) -> str:
    """利用可能な遺伝子カテゴリーのコンテキスト"""
    context_parts = ["【利用可能な遺伝子データカテゴリー】"]
    context_parts.append("以下のカテゴリーの遺伝子情報を要求できます：")
    for category in available_categories:
        context_parts.append(f"- {category}")
    context_parts.append("\n必要に応じて「🧬 [カテゴリー名]に関する遺伝子情報」の形式で要求してください。")
    return "\n".join(context_parts)


def call_openai(client: OpenAI, messages: List[Dict], max_retries: int = 3) -> str:
    """OpenAI APIを呼び出し（レートリミット対策付き）"""
    print(f"🤖 Calling OpenAI API with {len(messages)} messages")

    # メッセージのトークン数を概算（デバッグ用）
    total_chars = sum(len(msg.get('content', '')) for msg in messages)
    estimated_tokens = total_chars // 4
    print(f"📊 Estimated tokens: ~{estimated_tokens}")

    last_error = None

    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(
                model="gpt-5.1-chat-latest",
                messages=messages,
                max_completion_tokens=2500  # v8: 3レイヤー応答に対応するため増加（1500→2500）
            )

            assistant_message = response.choices[0].message.content

            # 使用トークン数をログ出力
            usage = response.usage
            print(f"📊 Token usage: prompt={usage.prompt_tokens}, completion={usage.completion_tokens}, total={usage.total_tokens}")

            return assistant_message

        except Exception as e:
            last_error = e
            error_str = str(e).lower()

            # レートリミットエラーの場合はリトライ
            if "rate_limit" in error_str or "429" in str(e) or "rate limit" in error_str:
                wait_time = (2 ** attempt) + 1  # 1秒, 3秒, 5秒
                print(f"⚠️ Rate limit hit (attempt {attempt + 1}/{max_retries}), waiting {wait_time}s...")
                time.sleep(wait_time)
                continue

            # その他のエラーはすぐにraise
            print(f"❌ OpenAI API error: {str(e)}")
            raise

    # 最大リトライ回数を超えた場合
    print(f"❌ Max retries ({max_retries}) exceeded. Last error: {str(last_error)}")
    raise last_error


def split_response_into_chunks(response_text: str) -> list:
    """セクション区切り「---」でチャンク分割。失敗時は全体を1チャンクに"""
    # 「---」でセクション分割
    if '---' in response_text:
        chunks = [chunk.strip() for chunk in response_text.split('---') if chunk.strip()]
        # 【セクションX:】のラベルを除去（出力には不要）
        cleaned_chunks = []
        for chunk in chunks:
            # 【セクション1: あなたの分析】のような行を除去
            lines = chunk.split('\n')
            filtered_lines = [line for line in lines if not line.strip().startswith('【セクション')]
            cleaned_chunk = '\n'.join(filtered_lines).strip()
            if cleaned_chunk:
                cleaned_chunks.append(cleaned_chunk)
        return cleaned_chunks if cleaned_chunks else [response_text.strip()]

    # 「---」がない場合は全体を1チャンクに
    return [response_text.strip()]


def cors_headers():
    """CORS ヘッダー"""
    return {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
    }
