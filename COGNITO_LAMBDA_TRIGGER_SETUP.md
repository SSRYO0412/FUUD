# Cognito User Pool Lambda トリガー設定 - 実装手順書

**作成日**: 2025-11-23
**対象環境**: 本番環境（ap-northeast-1_cwAKljjzb）
**実装者**: -
**レビュー者**: -

---

## 📋 目次

1. [実装概要](#実装概要)
2. [事前準備](#事前準備)
3. [Lambda関数コード修正](#lambda関数コード修正)
4. [デプロイ手順](#デプロイ手順)
5. [Cognitoトリガー設定](#cognitoトリガー設定)
6. [テスト計画](#テスト計画)
7. [トラブルシューティング](#トラブルシューティング)
8. [ロールバック手順](#ロールバック手順)
9. [モニタリング設定](#モニタリング設定)

---

## 実装概要

### 目的

新規ユーザー登録時に、Cognito User Pool の PostConfirmation トリガーを使って自動的に以下を実行する：
- DynamoDB（Usersテーブル）にユーザープロファイル作成
- S3（tuunapp-gene-data-a7x9k3）にユーザー専用フォルダ作成

### 現状の問題

- Cognito User Pool に Lambda トリガーが設定されていない
- ユーザー登録時に手動でAPI Gateway経由でLambda関数を呼び出している
- 一部のユーザーがCognitoには存在するが、DynamoDB/S3に登録されていない

### 実装後の効果

- ✅ ユーザー登録フローの自動化
- ✅ データ整合性の向上
- ✅ アプリ側のコード簡素化（将来的に手動呼び出しを削除可能）
- ✅ 既存ユーザーへの影響なし

### リスク評価

| 項目 | リスクレベル | 説明 |
|------|------------|------|
| 既存ユーザーへの影響 | **低** | PostConfirmationは新規確認時のみ発動 |
| Lambda実行失敗 | **中** | エラーハンドリングで対応済み |
| データ重複 | **低** | DynamoDBのConditionExpressionで防止 |
| ロールバック難易度 | **低** | トリガー削除のみで即座に戻せる |

**総合リスク評価**: 🟢 低リスク（安全に実装可能）

### 所要時間

- Lambda関数修正: 15分
- デプロイ・設定: 15分
- テスト実行: 20分
- **合計**: 約50分

---

## 事前準備

### ✅ 実装前チェックリスト

- [ ] AWSプロファイル `tuun` が設定されている
- [ ] AWS CLI がインストールされている
- [ ] Lambda関数のソースコード（CreateUserFunction_updated.zip）が存在する
- [ ] バックアップ用にタイムスタンプ付きzipファイルを作成

### バックアップ推奨事項

#### 1. Lambda関数の現在のコードをバックアップ

```bash
export AWS_PROFILE=tuun
cd /Users/sasakiryo/Documents/TestFlight

# 現在のLambda関数コードをダウンロード
aws lambda get-function --function-name CreateUserFunctionPython \
  --query 'Code.Location' --output text | xargs curl -o CreateUserFunction_backup_$(date +%Y%m%d_%H%M%S).zip
```

#### 2. DynamoDBのバックアップ確認

```bash
# Point-in-Time Recoveryが有効か確認
aws dynamodb describe-continuous-backups --table-name Users
```

有効でない場合は、実装前に有効化することを推奨：

```bash
aws dynamodb update-continuous-backups \
  --table-name Users \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
```

---

## Lambda関数コード修正

### 修正内容の概要

現在の Lambda 関数は **API Gateway イベント**のみに対応しているため、**Cognito トリガーイベント**にも対応できるように修正します。

### イベント構造の違い

#### API Gateway イベント（現在）
```json
{
  "body": "{\"email\": \"user@example.com\"}"
}
```

#### Cognito PostConfirmation イベント（追加対応）
```json
{
  "version": "1",
  "triggerSource": "PostConfirmation_ConfirmSignUp",
  "request": {
    "userAttributes": {
      "email": "user@example.com",
      "email_verified": "true",
      "sub": "uuid-here"
    }
  },
  "response": {}
}
```

### 修正手順

#### Step 1: 既存コードの展開

```bash
cd /Users/sasakiryo/Documents/TestFlight
unzip -o CreateUserFunction_updated.zip
```

#### Step 2: lambda_function.py の修正

`lambda_function.py` の `lambda_handler` 関数を以下のように修正してください：

```python
def lambda_handler(event, context):
    """
    Cognitoトリガー用のハンドラー
    PostConfirmation_ConfirmSignUp イベントおよびAPI Gatewayイベントに対応
    """
    print(f"Event: {json.dumps(event)}")

    try:
        # ========================================
        # イベントソースの判定
        # ========================================
        if 'triggerSource' in event:
            # ============ Cognitoトリガーからの呼び出し ============
            trigger_source = event.get('triggerSource', '')

            # PostConfirmation_ConfirmSignUp以外は処理しない
            if trigger_source != 'PostConfirmation_ConfirmSignUp':
                print(f"⏭️ Skipping trigger source: {trigger_source}")
                return event

            # Cognitoイベントからメールアドレスを取得
            email = event['request']['userAttributes']['email'].lower().strip()
            print(f"📧 Cognito trigger for user: {email}")

        elif 'body' in event:
            # ============ API Gatewayからの呼び出し（後方互換性） ============
            body = json.loads(event['body'])
            email = body['email'].lower().strip()
            print(f"📧 API Gateway request for user: {email}")

        else:
            raise ValueError("Unknown event source - neither Cognito nor API Gateway")

        # ========================================
        # 入力検証
        # ========================================
        if not validate_email(email):
            if 'triggerSource' in event:
                # Cognitoトリガーの場合は警告ログのみ（エラーにしない）
                print(f"⚠️ Invalid email format: {email}")
                return event
            else:
                return create_response(400, {'error': '無効なメールアドレス形式です'})

        # ========================================
        # 1. S3フォルダ作成
        # ========================================
        print(f"Creating S3 folders for: {email}")
        s3_results = create_user_folders(email)

        # ========================================
        # 2. DynamoDBにユーザープロファイル作成
        # ========================================
        print(f"Creating user profile in DynamoDB for: {email}")
        profile = create_user_profile(email)

        print(f"✅ User profile created successfully for: {email}")

        # ========================================
        # レスポンス返却
        # ========================================
        if 'triggerSource' in event:
            # Cognitoトリガーの場合は必ずeventをそのまま返す（重要！）
            return event
        else:
            # API Gatewayの場合は成功レスポンスを返す
            return create_response(200, {
                'message': 'ユーザープロファイルが正常に作成されました',
                'userId': email,
                's3Folders': s3_results,
                'profile': profile
            })

    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        print(f"❌ AWS Error: {error_code} - {error_message}")

        # ========================================
        # エラーハンドリング（重複チェック）
        # ========================================
        if error_code == 'ConditionalCheckFailedException':
            # ユーザーが既に存在する場合
            if 'triggerSource' in event:
                # Cognitoトリガーの場合は成功として扱う（重要！）
                print(f"⚠️ User profile already exists for: {email} - treating as success")
                return event
            else:
                # API Gatewayの場合は409エラーを返す
                return create_response(409, {'error': 'このユーザーは既に登録されています'})

        # ========================================
        # その他のエラー
        # ========================================
        if 'triggerSource' in event:
            # Cognitoトリガーでは致命的エラーのみ例外を投げる
            # （ユーザー登録を失敗させる）
            print(f"❌ Critical error - will fail user registration: {error_message}")
            raise
        else:
            return create_response(500, {'error': f'エラー: {error_message}'})

    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        import traceback
        print(traceback.format_exc())

        # Cognitoトリガーの場合は例外を再スロー（ユーザー登録を失敗させる）
        if 'triggerSource' in event:
            raise
        else:
            return create_response(500, {'error': '予期しないエラーが発生しました'})
```

#### Step 3: validate_email 関数の追加（既存にない場合）

`lambda_function.py` の先頭付近に以下を追加：

```python
import re

def validate_email(email):
    """メールアドレスの形式を検証"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None
```

#### Step 4: 新しいzipファイルの作成

```bash
zip CreateUserFunction_cognito.zip lambda_function.py
```

---

## デプロイ手順

### Step 1: Lambda関数コードのデプロイ

```bash
export AWS_PROFILE=tuun
cd /Users/sasakiryo/Documents/TestFlight

aws lambda update-function-code \
  --function-name CreateUserFunctionPython \
  --zip-file fileb://CreateUserFunction_cognito.zip
```

**期待される出力:**
```json
{
  "FunctionName": "CreateUserFunctionPython",
  "LastModified": "2025-11-23T...",
  "CodeSha256": "..."
}
```

### Step 2: Lambda関数のタイムアウト設定変更

```bash
aws lambda update-function-configuration \
  --function-name CreateUserFunctionPython \
  --timeout 15
```

**理由**: デフォルトの3秒では、S3とDynamoDB両方の処理に不足する可能性があるため、15秒に延長します。

### Step 3: デプロイ確認

```bash
aws lambda get-function-configuration \
  --function-name CreateUserFunctionPython \
  --query '{Timeout:Timeout,LastModified:LastModified,CodeSize:CodeSize}'
```

**期待される出力:**
```json
{
  "Timeout": 15,
  "LastModified": "2025-11-23T...",
  "CodeSize": 2xxx
}
```

---

## Cognitoトリガー設定

### Step 1: PostConfirmationトリガーの設定

```bash
export AWS_PROFILE=tuun

aws cognito-idp update-user-pool \
  --user-pool-id ap-northeast-1_cwAKljjzb \
  --lambda-config PostConfirmation=arn:aws:lambda:ap-northeast-1:295250016740:function:CreateUserFunctionPython
```

**期待される出力:**
```json
{
  "UserPool": {
    "Id": "ap-northeast-1_cwAKljjzb",
    "LambdaConfig": {
      "PostConfirmation": "arn:aws:lambda:ap-northeast-1:295250016740:function:CreateUserFunctionPython"
    }
  }
}
```

### Step 2: Lambda実行権限の追加

Cognitoから Lambda を呼び出すための権限（リソースベースポリシー）を追加：

```bash
aws lambda add-permission \
  --function-name CreateUserFunctionPython \
  --statement-id CognitoPostConfirmationTrigger \
  --action lambda:InvokeFunction \
  --principal cognito-idp.amazonaws.com \
  --source-arn arn:aws:cognito-idp:ap-northeast-1:295250016740:userpool/ap-northeast-1_cwAKljjzb
```

**期待される出力:**
```json
{
  "Statement": "{\"Sid\":\"CognitoPostConfirmationTrigger\",\"Effect\":\"Allow\",...}"
}
```

**注意**: 既に権限が存在する場合は `ResourceConflictException` エラーが出ますが、問題ありません。

### Step 3: 設定確認

```bash
# Cognitoトリガー設定の確認
aws cognito-idp describe-user-pool \
  --user-pool-id ap-northeast-1_cwAKljjzb \
  --query 'UserPool.LambdaConfig'

# Lambda権限の確認
aws lambda get-policy \
  --function-name CreateUserFunctionPython \
  --query 'Policy' --output text | python3 -m json.tool
```

---

## テスト計画

### テスト1: Lambda関数の単体テスト（Cognitoイベント）

#### テストイベントファイルの作成

`test_cognito_event.json` を作成：

```json
{
  "version": "1",
  "triggerSource": "PostConfirmation_ConfirmSignUp",
  "region": "ap-northeast-1",
  "userPoolId": "ap-northeast-1_cwAKljjzb",
  "userName": "test-trigger-001",
  "request": {
    "userAttributes": {
      "email": "trigger-test-001@example.com",
      "email_verified": "true",
      "sub": "test-sub-12345"
    }
  },
  "response": {}
}
```

#### Lambda関数の実行

```bash
aws lambda invoke \
  --function-name CreateUserFunctionPython \
  --payload file://test_cognito_event.json \
  --profile tuun \
  response.json

cat response.json
```

**期待される結果:**
- `response.json` に元のイベントが返ってくる
- エラーがない

#### データ作成確認

```bash
# DynamoDBにユーザーが作成されたか
aws dynamodb get-item \
  --table-name Users \
  --key '{"id": {"S": "trigger-test-001@example.com"}}' \
  --profile tuun

# S3フォルダが作成されたか
aws s3 ls s3://tuunapp-gene-data-a7x9k3/raw-gene/trigger-test-001@example.com/
aws s3 ls s3://tuunapp-gene-data-a7x9k3/raw-blood/trigger-test-001@example.com/
```

**期待される結果:**
- DynamoDB: `{"id": "trigger-test-001@example.com", "name": "trigger-test-001"}`
- S3: README.mdファイルが存在

#### CloudWatch Logsの確認

```bash
aws logs tail /aws/lambda/CreateUserFunctionPython --since 5m --profile tuun
```

**期待されるログ:**
```
📧 Cognito trigger for user: trigger-test-001@example.com
Creating S3 folders for: trigger-test-001@example.com
Creating user profile in DynamoDB for: trigger-test-001@example.com
✅ User profile created successfully for: trigger-test-001@example.com
```

### テスト2: API Gateway経由の動作確認（後方互換性）

```bash
curl -X POST https://02fc5gnwoi.execute-api.ap-northeast-1.amazonaws.com/dev/users \
  -H "Content-Type: application/json" \
  -d '{"email": "api-test-002@example.com"}'
```

**期待される結果:**
```json
{
  "message": "ユーザープロファイルが正常に作成されました",
  "userId": "api-test-002@example.com",
  "s3Folders": [...],
  "profile": {...}
}
```

### テスト3: 実運用テスト（iOSアプリから）

#### 手順

1. iOSアプリから新規ユーザー登録
   - メールアドレス: `real-test-003@example.com`
   - パスワード: 任意（大文字、小文字、数字を含む8文字以上）

2. メールで確認コードを受信

3. アプリで確認コードを入力

4. ログイン成功を確認

#### 確認項目チェックリスト

- [ ] 確認コード入力後、エラーなく登録完了
- [ ] DynamoDBに `real-test-003@example.com` のプロファイルが作成されている
- [ ] S3に `raw-gene/real-test-003@example.com/` フォルダが作成されている
- [ ] S3に `raw-blood/real-test-003@example.com/` フォルダが作成されている
- [ ] CloudWatch Logsに実行ログが出力されている
- [ ] アプリで正常にログインできる

#### CloudWatch Logs確認

```bash
# 直近5分のログを確認
aws logs tail /aws/lambda/CreateUserFunctionPython --since 5m --follow --profile tuun
```

### テスト4: 重複登録のテスト

既存ユーザー（例: `7070net7070@gmail.com`）で再度Lambda関数を実行し、エラーにならないことを確認：

```json
{
  "version": "1",
  "triggerSource": "PostConfirmation_ConfirmSignUp",
  "request": {
    "userAttributes": {
      "email": "7070net7070@gmail.com",
      "email_verified": "true"
    }
  },
  "response": {}
}
```

**期待される結果:**
- エラーにならず、`event` が返ってくる
- ログに `⚠️ User profile already exists for: 7070net7070@gmail.com - treating as success` が出力される

---

## トラブルシューティング

### 問題1: Lambda関数が実行されない

#### 症状
- 新規ユーザー登録後、DynamoDB/S3にデータが作成されない
- CloudWatch Logsに実行ログがない

#### 原因と対処

**原因A**: トリガーが正しく設定されていない

```bash
# トリガー設定を確認
aws cognito-idp describe-user-pool \
  --user-pool-id ap-northeast-1_cwAKljjzb \
  --query 'UserPool.LambdaConfig' \
  --profile tuun
```

出力が空の場合、トリガーが設定されていません。「Cognitoトリガー設定」の手順を再実行してください。

**原因B**: Lambda実行権限がない

```bash
# Lambda権限を確認
aws lambda get-policy --function-name CreateUserFunctionPython --profile tuun
```

`CognitoPostConfirmationTrigger` がない場合、権限を追加してください（Step 2を再実行）。

### 問題2: Lambda関数がエラーで失敗する

#### 症状
- ユーザー登録が「エラーが発生しました」で失敗
- CloudWatch Logsにエラーログがある

#### 原因と対処

**原因A**: DynamoDBやS3の権限不足

CloudWatch Logsで以下のようなエラーが出ている場合：
```
AccessDeniedException: User: arn:aws:sts::... is not authorized to perform: dynamodb:PutItem
```

IAMロールの権限を確認してください：
```bash
aws lambda get-function-configuration \
  --function-name CreateUserFunctionPython \
  --query 'Role' \
  --profile tuun
```

**原因B**: S3バケットが存在しない

エラーメッセージに `NoSuchBucket` がある場合、S3バケット名を確認してください。

**原因C**: コードの構文エラー

Lambda関数コードに構文エラーがある場合、以下で確認：
```bash
aws logs tail /aws/lambda/CreateUserFunctionPython --since 10m --profile tuun | grep -i error
```

### 問題3: 既存ユーザーのログインができない

#### 症状
- トリガー設定後、既存ユーザーがログインできない

#### 原因と対処

**原因**: PostConfirmationトリガーは既存ユーザーには影響しません。

ログイン問題がある場合は、Cognitoトリガーとは別の原因です。以下を確認：
- ユーザーのステータス（CONFIRMED か）
- パスワードが正しいか
- アプリのCognito設定が正しいか

### 問題4: CloudWatch Logsが見つからない

#### 症状
- `aws logs tail` コマンドでエラーが出る

#### 対処

```bash
# ロググループが存在するか確認
aws logs describe-log-groups \
  --log-group-name-prefix /aws/lambda/CreateUserFunctionPython \
  --profile tuun
```

存在しない場合、Lambda関数が一度も実行されていません。テスト実行をしてください。

---

## ロールバック手順

### 即座のロールバック（問題発生時）

#### Step 1: Cognitoトリガーの削除

```bash
export AWS_PROFILE=tuun

aws cognito-idp update-user-pool \
  --user-pool-id ap-northeast-1_cwAKljjzb \
  --lambda-config {}
```

**確認:**
```bash
aws cognito-idp describe-user-pool \
  --user-pool-id ap-northeast-1_cwAKljjzb \
  --query 'UserPool.LambdaConfig'
```

出力が `{}` または空であればトリガーが削除されています。

#### Step 2: Lambda関数コードのロールバック（必要な場合）

```bash
# バックアップしたzipファイルを使用
aws lambda update-function-code \
  --function-name CreateUserFunctionPython \
  --zip-file fileb://CreateUserFunction_backup_YYYYMMDD_HHMMSS.zip \
  --profile tuun
```

#### Step 3: 動作確認

- 既存ユーザーでログインできるか確認
- API Gateway経由の手動呼び出しが動作するか確認

### ロールバック後の状態

- ユーザー登録時に Lambda 関数が自動実行されない
- アプリからの手動API呼び出しは引き続き動作（SimpleCognitoService.swiftの`createUserProfile`が実行される）
- 既存ユーザーへの影響なし

---

## モニタリング設定

### CloudWatch Alarmの設定（推奨）

Lambda関数のエラーを監視するアラームを設定：

```bash
export AWS_PROFILE=tuun

aws cloudwatch put-metric-alarm \
  --alarm-name CreateUserFunction-Errors \
  --alarm-description "Alert when CreateUserFunction has errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=FunctionName,Value=CreateUserFunctionPython
```

### CloudWatch Logsの保持期間設定

```bash
aws logs put-retention-policy \
  --log-group-name /aws/lambda/CreateUserFunctionPython \
  --retention-in-days 7 \
  --profile tuun
```

### ダッシュボードの作成（オプション）

CloudWatch Dashboardで以下のメトリクスを監視：
- Lambda実行回数（Invocations）
- Lambda実行エラー数（Errors）
- Lambda実行時間（Duration）
- DynamoDB書き込みスループット

---

## 補足資料

### 関連ファイル

- **Lambda関数コード**: `/Users/sasakiryo/Documents/TestFlight/CreateUserFunction_updated.zip`
- **iOSアプリ認証サービス**: `/Users/sasakiryo/Documents/TestFlight/Services/SimpleCognitoService.swift`
- **DynamoDBテーブル**: `Users`
- **S3バケット**: `tuunapp-gene-data-a7x9k3`

### AWS リソース情報

| リソース | ID/ARN |
|---------|--------|
| Cognito User Pool | ap-northeast-1_cwAKljjzb |
| Lambda関数 | CreateUserFunctionPython |
| Lambda ARN | arn:aws:lambda:ap-northeast-1:295250016740:function:CreateUserFunctionPython |
| IAMロール | CreateUserFunctionPython-role-qjfwg5bz |
| API Gatewayエンドポイント | https://02fc5gnwoi.execute-api.ap-northeast-1.amazonaws.com/dev/users |
| CloudWatch Logsグループ | /aws/lambda/CreateUserFunctionPython |

### 参考リンク

- [Post confirmation Lambda trigger - Amazon Cognito](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-lambda-post-confirmation.html)
- [Lambda function error handling](https://docs.aws.amazon.com/lambda/latest/dg/python-exceptions.html)

---

## 実装履歴

| 日付 | 実施者 | 内容 | ステータス |
|------|--------|------|----------|
| 2025-11-23 | - | 実装手順書作成 | ✅ 完了 |
| - | - | Lambda関数修正・デプロイ | ⏳ 未実施 |
| - | - | Cognitoトリガー設定 | ⏳ 未実施 |
| - | - | 実運用テスト | ⏳ 未実施 |

---

## 次のステップ

1. ✅ この手順書を確認
2. ⏳ 事前準備（バックアップ等）を実施
3. ⏳ Lambda関数コード修正
4. ⏳ デプロイと設定
5. ⏳ テスト実行
6. ⏳ 本番リリース

---

**作成者**: Claude Code
**最終更新**: 2025-11-23
