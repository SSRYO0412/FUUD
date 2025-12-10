# TUUN AI Chat Lambda Function - デプロイガイド

## 📦 概要

このLambda関数は、TUUN AIチャットの改善版です。

### 主な改善点
- 初回のみ血液データ送信（プロンプト長75%削減）
- 遺伝子データは会話中に必要な項目のみ要求
- インタビュー形式で情報収集
- パーソナルドクター/トレーナー口調
- セクション別チャンク出力

---

## 🚀 ZIPファイル作成手順（重要）

### 手順1: 直近のZIPファイルを確認
```bash
ls -la /Users/sasakiryo/Documents/TestFlight/lambda_deployment/*.zip | sort -t'v' -k2 -n | tail -5
```

### 手順2: 新しいバージョンのディレクトリを作成して展開
```bash
cd /Users/sasakiryo/Documents/TestFlight/lambda_deployment
rm -rf temp_vXX  # XX = 新しいバージョン番号
mkdir temp_vXX
cd temp_vXX
unzip -q ../deployment_vYY_previous_name.zip  # YY = 直前のバージョン
```

### 手順3: 変更したファイルのみを差し替え
```bash
# lambda_function.pyを差し替える場合
cp ../lambda_function.py ./lambda_function.py
```

### 手順4: 新しいZIPを作成
```bash
cd /Users/sasakiryo/Documents/TestFlight/lambda_deployment/temp_vXX
zip -r ../deployment_vXX_description.zip . -x "*.DS_Store"
```

### 手順5: 確認
```bash
ls -la ../deployment_vXX_description.zip
```

---

## 🚨 サーバーエラー履歴と対策（完全版）

### エラー1: モジュールインポートエラー (v2→v3で修正)

| エラー | 原因 | 対策 |
|--------|------|------|
| `No module named 'multidict'` | ZIPに依存モジュール不足 | パッケージ再構築 |
| `No module named 'aiohttp'` | 非同期HTTPライブラリ依存関係不足 | httpxベースの同期クライアントに変更 |

---

### エラー2: API Key取得エラー (v3で修正)

| エラー | 原因 | 対策 |
|--------|------|------|
| `Failed to get OpenAI API key: 'api_key'` | Secrets Managerのキー名不一致 | 複数キー名に対応 |

**修正コード (lambda_function.py):**
```python
def get_openai_api_key():
    secret = json.loads(response['SecretString'])
    if 'api_key' in secret:
        return secret['api_key']
    elif 'OPENAI_API_KEY' in secret:
        return secret['OPENAI_API_KEY']
    elif 'openai_api_key' in secret:
        return secret['openai_api_key']
```

---

### エラー3: 構文エラー (v4で修正)

| エラー | 原因 | 対策 |
|--------|------|------|
| `Syntax error: =model="gpt-5.1-chat-latest"` | `model=`の前に`=`が余分 | タイポ修正 |

---

### エラー4: OpenAI APIパラメータエラー (v4で修正)

| エラー | 原因 | 対策 |
|--------|------|------|
| `'max_tokens' is not supported` | gpt-5.1では非対応 | `max_completion_tokens`に変更 |
| `'temperature' does not support 0.7` | gpt-5.1では固定値 | `temperature`パラメータ削除 |

**修正コード:**
```python
response = client.chat.completions.create(
    model="gpt-5.1-chat-latest",
    messages=messages,
    max_completion_tokens=2500  # max_tokensではなくmax_completion_tokens
    # temperatureは指定しない（デフォルト1）
)
```

---

### エラー5: データ形式エラー (v9, v11で修正)

| エラー | 原因 | 対策 |
|--------|------|------|
| `'str' object has no attribute 'get'` | データが文字列として渡された | バリデーション追加 |
| `'list' object has no attribute 'get'` | 血液データが配列形式 | v9: 配列形式に対応 |
| `'list' object has no attribute 'items'` | 遺伝子データが配列形式 | v11: isinstance()チェック追加 |
| `'NoneType' object has no attribute 'get'` | Noneデータ | Noneチェック追加 |

**血液データ対策 (v9):**
```python
def build_blood_data_context(blood_data: Dict) -> str:
    # 配列形式の血液データに対応
    for item in blood_data:  # dictではなくlistとしてループ
        key = item.get('key', '')
        # ...
```

**遺伝子データ対策 (v11):**
```python
def build_gene_data_context(gene_data: Dict) -> str:
    for category, markers in gene_data.items():
        if isinstance(markers, dict):
            # 自動検出形式: {title, genotypes, impact}
            # ...
        elif isinstance(markers, list):
            # 従来形式: [{title, genotypes}, ...]
            # ...
```

---

### エラー6: レートリミットエラー (v14で修正)

| エラー | 原因 | 対策 |
|--------|------|------|
| `Rate limit reached... Limit 30000 TPM` | OpenAI APIのレート制限 | 指数バックオフでリトライ実装 |

**修正コード:**
```python
import time

def call_openai(client, messages, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(...)
            return response.choices[0].message.content
        except Exception as e:
            if "rate_limit" in str(e).lower() or "429" in str(e):
                wait_time = (2 ** attempt) + 1  # 1, 3, 5秒
                print(f"Rate limit hit, waiting {wait_time}s...")
                time.sleep(wait_time)
                continue
            raise
    raise Exception("Max retries exceeded")
```

---

## 📋 バージョン履歴

| バージョン | 日付 | 説明 |
|-----------|------|------|
| v2 | 11/24 08:51 | 初期デプロイ |
| v3 | 11/24 09:19 | モジュールインポートエラー修正 |
| v4_2stage | 11/24 10:09 | 2段階抽出対応、APIパラメータ修正 |
| v5_improved_prompt | 11/24 10:59 | プロンプト改善 |
| v6_comma_fix | 11/24 13:38 | カンマ区切り修正 |
| v7_ux_improvement | 11/24 14:53 | UX改善 |
| v8_data_selection_ux | 11/25 05:03 | データ選択UX |
| v9_blood_array_fix | 11/25 15:42 | 血液データ配列形式対応 |
| v10_chat_ux_chunks | 11/25 21:06 | チャットUXチャンク出力 |
| v11_gene_auto_detect | 11/26 15:05 | 遺伝子自動検出対応 |
| v12_initial_format_improvement | 11/26 16:10 | 初回フォーマット改善 |
| v13_section_chunks | 11/26 16:14 | セクション別チャンク出力 |
| v14_rate_limit_retry | TBD | レートリミット対策 |

---

## 🔧 AWS Lambda デプロイ方法

### AWS Console経由（推奨）:
1. AWS Lambda コンソールを開く
2. 関数 `chat-api-function` を選択
3. 「コード」タブ → 「アップロード元」→ 「.zipファイル」
4. `deployment_vXX_*.zip` を選択してアップロード
5. 「デプロイ」ボタンをクリック

### AWS CLI経由:
```bash
aws lambda update-function-code \
  --function-name chat-api-function \
  --zip-file fileb://deployment_vXX_description.zip \
  --profile tuun \
  --region ap-northeast-1
```

---

## 🐛 トラブルシューティング

### CloudWatch Logsでエラー確認
```bash
AWS_PROFILE=tuun aws logs filter-log-events \
  --log-group-name /aws/lambda/chat-api-function \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s000) \
  --region ap-northeast-1
```

### 最新ログのtail
```bash
AWS_PROFILE=tuun aws logs tail /aws/lambda/chat-api-function \
  --follow --region ap-northeast-1
```

### よくあるエラーと対処

| エラー | 対処 |
|--------|------|
| `Module not found: openai` | ZIPに依存関係が含まれているか確認 |
| `Secrets Manager access denied` | Lambda実行ロールに権限追加 |
| `Rate limit exceeded` | v14以降で自動リトライ対応 |

---

## 📁 重要ファイル

| ファイル | 説明 |
|----------|------|
| `lambda_function.py` | メインのLambda関数 |
| `deployment_vXX_*.zip` | デプロイ用パッケージ |
| `temp_vXX/` | 作業用一時ディレクトリ |
| `README.md` | このドキュメント |

---

## 🔑 設定

### 環境変数

| 変数名 | 必須 | 説明 |
|--------|------|------|
| `PII_SALT` | **必須** | ユーザーID匿名化用のソルト（32文字以上推奨） |
| `ALLOW_SNP_TO_OPENAI` | 任意 | `true`でSNP rs番号をOpenAIに送信（デフォルト: `false`） |

**PII_SALTの生成方法:**
```bash
openssl rand -hex 32
```

### Lambdaタイムアウト
- 推奨: 30秒

### メモリ
- 推奨: 512MB

### IAMロール権限
- `secretsmanager:GetSecretValue` (tuunapp/openai-api-key)
- CloudWatch Logs書き込み権限

---

## 🔒 PIIフィルタリング (v17~)

### 概要

`pii_sanitizer.py`モジュールにより、OpenAI APIへ送信する前に個人識別情報（PII）を除去します。

### サニタイズ対象

| データ種別 | 処理内容 |
|-----------|----------|
| ユーザーID | ソルト付きSHA256ハッシュで匿名化 (`user_abc123def456`) |
| メールアドレス | `[EMAIL]`にマスク |
| 電話番号 | `[PHONE]`にマスク |
| SNP rs番号 | 完全除去（影響スコアのみ保持） |
| バイタルデータ | 相対的レベル（high/moderate/low）に変換 |

### SNP rs番号の送信を許可する場合

遺伝子の具体的なrs番号（例: `rs762551`）をOpenAIに送信したい場合：

**方法1: 環境変数で制御（推奨）**

Lambda環境変数に追加:
```
ALLOW_SNP_TO_OPENAI=true
```

`pii_sanitizer.py`を以下のように修正:
```python
@staticmethod
def sanitize_gene_data(gene_data: Dict) -> Dict:
    # SNP除去をスキップ
    if os.environ.get('ALLOW_SNP_TO_OPENAI', 'false').lower() == 'true':
        return gene_data  # そのまま返す

    # 既存のサニタイズ処理...
```

**方法2: PIIフィルタリング全体を無効化**

`lambda_function.py`の該当部分を修正:
```python
# PII_SANITIZER_AVAILABLE = True  # コメントアウト
PII_SANITIZER_AVAILABLE = False  # 強制無効化
```

### 注意事項

- `PII_SALT`が未設定の場合、Lambda関数は500エラーを返します
- SNP送信を許可する場合、ユーザーへの同意取得とOpenAIのデータ利用ポリシーを確認してください
- 本番環境では`ALLOW_SNP_TO_OPENAI=false`（デフォルト）を推奨
