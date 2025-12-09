# CSV一括ユーザー登録 - 手動操作手順書

**作成日**: 2025-12-09
**対象CSV**: `/Users/sasakiryo/Downloads/TUUN利用登録_確定版.csv`

---

## 概要

CSVファイルからユーザーを以下に手動登録する：
1. **Cognito** - ログイン認証用（仮パスワード付き）
2. **DynamoDB** - ユーザープロファイル
3. **S3** - ユーザー専用フォルダ（Cognitoトリガーで自動作成される）

---

## 事前準備

### 仮パスワードの生成

各ユーザーに以下の要件を満たす仮パスワードを生成してください：
- 8文字以上
- 大文字を含む
- 小文字を含む
- 数字を含む
- 記号を含む（!@#$%^&*）

**例**: `Temp@1234`, `User#5678`, `Pass!9012`

### CSVデータ（登録対象）

| メールアドレス | 姓 | 名 | 姓カナ | 名カナ | 生年月日 | 性別 | 仮パスワード |
|--------------|----|----|--------|--------|----------|------|------------|
| courtokuyama@bewibe.com | 奥山 | 滉斗 | オクヤマ | コウト | 1998-08-15 | 男性 | （生成する） |
| rug.arfc@gmail.com | 佐々木 | 遼 | ササキ | リョウ | 1998-04-12 | 男性 | （生成する） |
| ryosasaki@bewibe.com | 佐々木 | 遼 | ササキ | リョウ | 1998-04-12 | 男性 | （生成する） |

**注意**: CSVの1行目（courtokuyama@bewibe.com）は姓名が分離されていないため、「姓=奥山滉斗」「名=空」として登録

---

## Part 1: Cognitoユーザー作成

### 手順

1. **AWSコンソールにログイン**
   - https://console.aws.amazon.com/

2. **Cognito User Poolに移動**
   - サービス → Cognito → ユーザープール → `ap-northeast-1_cwAKljjzb`

3. **各ユーザーを作成**

   「ユーザー」タブ → 「ユーザーを作成」

   | 設定項目 | 値 |
   |---------|-----|
   | ユーザー名 | メールアドレス（例: `courtokuyama@bewibe.com`） |
   | Eメールアドレス | 同上 |
   | Eメールを検証済みとしてマーク | ✅ チェック |
   | 仮パスワード | 生成した仮パスワード |
   | 招待メッセージを送信 | ❌ チェックしない（SUPPRESS） |

4. **繰り返し**

   全ユーザー分（3名）繰り返す

### 確認

作成後、ユーザー一覧で以下を確認：
- ステータス: `FORCE_CHANGE_PASSWORD`（仮パスワード状態）
- メール: 検証済み

---

## Part 2: DynamoDBユーザープロファイル作成

### 手順

1. **DynamoDBに移動**
   - サービス → DynamoDB → テーブル → `Users`

2. **各ユーザーの項目を作成**

   「項目を探索」→「項目を作成」→「JSON」モードに切り替え

#### ユーザー1: courtokuyama@bewibe.com

```json
{
  "id": {
    "S": "courtokuyama@bewibe.com"
  },
  "submission_id": {
    "S": "D4EQyXZ"
  },
  "respondent_id": {
    "S": "KYxaJrV"
  },
  "submitted_at": {
    "S": "2025-12-03 05:05:39"
  },
  "last_name": {
    "S": "奥山滉斗"
  },
  "first_name": {
    "S": ""
  },
  "last_name_kana": {
    "S": "オクヤマコウト"
  },
  "first_name_kana": {
    "S": ""
  },
  "birth_date": {
    "S": "1998-08-15"
  },
  "gender": {
    "S": "男性"
  },
  "temp_password": {
    "S": "（ここに仮パスワードを入力）"
  },
  "created_at": {
    "S": "2025-12-09T00:00:00"
  },
  "registration_source": {
    "S": "bulk_import"
  }
}
```

#### ユーザー2: rug.arfc@gmail.com

```json
{
  "id": {
    "S": "rug.arfc@gmail.com"
  },
  "submission_id": {
    "S": "LZBy0AJ"
  },
  "respondent_id": {
    "S": "9q7qdEK"
  },
  "submitted_at": {
    "S": "2025-12-09 05:46:48"
  },
  "last_name": {
    "S": "佐々木遼"
  },
  "first_name": {
    "S": ""
  },
  "last_name_kana": {
    "S": "ササキリョウ"
  },
  "first_name_kana": {
    "S": ""
  },
  "birth_date": {
    "S": "1998-04-12"
  },
  "gender": {
    "S": "男性"
  },
  "temp_password": {
    "S": "（ここに仮パスワードを入力）"
  },
  "created_at": {
    "S": "2025-12-09T00:00:00"
  },
  "registration_source": {
    "S": "bulk_import"
  }
}
```

#### ユーザー3: ryosasaki@bewibe.com

```json
{
  "id": {
    "S": "ryosasaki@bewibe.com"
  },
  "submission_id": {
    "S": "obYQZMb"
  },
  "respondent_id": {
    "S": "9q7qdEK"
  },
  "submitted_at": {
    "S": "2025-12-09 07:42:46"
  },
  "last_name": {
    "S": "佐々木"
  },
  "first_name": {
    "S": "遼"
  },
  "last_name_kana": {
    "S": "ササキ"
  },
  "first_name_kana": {
    "S": "リョウ"
  },
  "birth_date": {
    "S": "1998-04-12"
  },
  "gender": {
    "S": "男性"
  },
  "temp_password": {
    "S": "（ここに仮パスワードを入力）"
  },
  "created_at": {
    "S": "2025-12-09T00:00:00"
  },
  "registration_source": {
    "S": "bulk_import"
  }
}
```

3. **各項目で「項目を作成」をクリック**

---

## Part 3: S3フォルダ作成

**注意**: Cognitoトリガーが設定されていれば、ユーザーが初回ログインして新パスワード設定完了時に自動作成されます。

手動で事前作成する場合：

1. **S3に移動**
   - サービス → S3 → `tuunapp-gene-data-a7x9k3`

2. **各ユーザーのフォルダを作成**

   以下のフォルダを作成（各メールアドレスごと）：

   ```
   raw-gene/courtokuyama@bewibe.com/
   raw-blood/courtokuyama@bewibe.com/

   raw-gene/rug.arfc@gmail.com/
   raw-blood/rug.arfc@gmail.com/

   raw-gene/ryosasaki@bewibe.com/
   raw-blood/ryosasaki@bewibe.com/
   ```

---

## Part 4: ユーザーへの通知

登録完了後、各ユーザーに以下を通知：

### 通知テンプレート

```
【TUUNアプリ ログイン情報】

アプリのダウンロード後、以下の情報でログインしてください。

メールアドレス: （ユーザーのメールアドレス）
仮パスワード: （生成した仮パスワード）

※初回ログイン時に新しいパスワードの設定が求められます。
※パスワードは8文字以上で、大文字・小文字・数字・記号を含む必要があります。
```

---

## 運営用記録

| メールアドレス | 仮パスワード | Cognito | DynamoDB | S3 | 通知 |
|--------------|------------|---------|----------|-----|------|
| courtokuyama@bewibe.com | | [ ] | [ ] | [ ] | [ ] |
| rug.arfc@gmail.com | | [ ] | [ ] | [ ] | [ ] |
| ryosasaki@bewibe.com | | [ ] | [ ] | [ ] | [ ] |

---

## トラブルシューティング

### ユーザーがログインできない

1. Cognitoでユーザーステータスを確認
   - `FORCE_CHANGE_PASSWORD` → 仮パスワード状態（正常）
   - `CONFIRMED` → 新パスワード設定済み

2. メールが検証済みか確認

### 新パスワード設定画面が表示されない

アプリ側の `NewPasswordView.swift` が正しくビルドされているか確認

---

**作成者**: Claude Code
**最終更新**: 2025-12-09
