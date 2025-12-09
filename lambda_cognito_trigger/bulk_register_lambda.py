"""
TUUN CSV一括ユーザー登録 Lambda関数

S3にCSVファイルがアップロードされると自動的に実行され、
ユーザーをCognito/DynamoDB/S3に一括登録する。

トリガー設定:
- S3バケット: tuunapp-gene-data-a7x9k3
- プレフィックス: bulk-import/
- サフィックス: .csv
- イベント: s3:ObjectCreated:*
"""

import json
import csv
import io
import secrets
import string
from datetime import datetime
from urllib.parse import unquote_plus

import boto3
from botocore.exceptions import ClientError

# =============================================================================
# 設定
# =============================================================================

AWS_REGION = "ap-northeast-1"
USER_POOL_ID = "ap-northeast-1_cwAKljjzb"
DYNAMODB_TABLE = "Users"
S3_BUCKET = "tuunapp-gene-data-a7x9k3"

# CSVカラムマッピング
CSV_COLUMNS = {
    "submission_id": "Submission ID",
    "respondent_id": "Respondent ID",
    "submitted_at": "Submitted at",
    "last_name": "お名前（姓　漢字）",
    "first_name": "お名前（名　漢字）",
    "last_name_kana": "お名前（姓　カタカナ）",
    "first_name_kana": "お名前（名　カタカナ）",
    "birth_date": "生年月日",
    "gender": "性別",
    "email": "メールアドレス",
}

# AWSクライアント初期化
cognito_client = boto3.client("cognito-idp", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
dynamodb_table = dynamodb.Table(DYNAMODB_TABLE)
s3_client = boto3.client("s3", region_name=AWS_REGION)


# =============================================================================
# ヘルパー関数
# =============================================================================

def generate_temp_password(length: int = 12) -> str:
    """
    Cognito要件を満たす仮パスワードを生成
    要件: 8文字以上、大文字、小文字、数字、記号を含む
    """
    password = [
        secrets.choice(string.ascii_uppercase),  # 大文字
        secrets.choice(string.ascii_lowercase),  # 小文字
        secrets.choice(string.digits),           # 数字
        secrets.choice("!@#$%^&*"),              # 記号
    ]

    all_chars = string.ascii_letters + string.digits + "!@#$%^&*"
    password.extend(secrets.choice(all_chars) for _ in range(length - 4))

    secrets.SystemRandom().shuffle(password)
    return "".join(password)


def create_cognito_user(email: str, temp_password: str) -> dict:
    """
    Cognitoにユーザーを作成（メール通知なし、FORCE_CHANGE_PASSWORD状態）
    """
    try:
        response = cognito_client.admin_create_user(
            UserPoolId=USER_POOL_ID,
            Username=email,
            TemporaryPassword=temp_password,
            UserAttributes=[
                {"Name": "email", "Value": email},
                {"Name": "email_verified", "Value": "true"},
            ],
            MessageAction="SUPPRESS",  # メール通知を抑制
        )
        return {
            "status": "success",
            "username": response["User"]["Username"],
            "user_status": response["User"]["UserStatus"]
        }

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "UsernameExistsException":
            return {"status": "exists", "message": "ユーザーは既に存在します"}
        raise


def create_dynamodb_user(user_data: dict) -> dict:
    """
    DynamoDBにユーザープロファイルを作成
    """
    try:
        # 空の値を除去
        clean_data = {k: v for k, v in user_data.items() if v}
        dynamodb_table.put_item(Item=clean_data)
        return {"status": "success"}

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "ConditionalCheckFailedException":
            return {"status": "exists", "message": "ユーザーは既に存在します"}
        raise


def create_s3_folders(email: str) -> dict:
    """
    S3にユーザー専用フォルダを作成
    """
    folders = [
        f"raw-gene/{email}/",
        f"raw-blood/{email}/",
    ]

    results = []
    for folder in folders:
        try:
            s3_client.put_object(Bucket=S3_BUCKET, Key=folder)
            results.append({"path": folder, "status": "created"})
        except Exception as e:
            results.append({"path": folder, "status": "failed", "error": str(e)})

    # READMEファイル作成
    readme_content = f"""# {email} のデータフォルダ

作成日: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## フォルダ構成
- raw-gene/: 遺伝子データをアップロード
- raw-blood/: 血液検査データをアップロード
"""

    try:
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=f"raw-gene/{email}/README.md",
            Body=readme_content.encode("utf-8"),
            ContentType="text/markdown"
        )
        results.append({"path": f"raw-gene/{email}/README.md", "status": "created"})
    except Exception as e:
        print(f"README creation error: {e}")

    return {"status": "success", "folders": results}


def save_results_to_s3(results: dict, credentials: list, csv_key: str):
    """
    結果をS3に保存
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # 結果レポート（JSON）
    report_key = f"bulk-import/results/report_{timestamp}.json"
    s3_client.put_object(
        Bucket=S3_BUCKET,
        Key=report_key,
        Body=json.dumps(results, ensure_ascii=False, indent=2).encode("utf-8"),
        ContentType="application/json"
    )
    print(f"📄 Report saved: s3://{S3_BUCKET}/{report_key}")

    # 認証情報CSV（運営用）
    if credentials:
        creds_key = f"bulk-import/results/credentials_{timestamp}.csv"

        output = io.StringIO()
        writer = csv.DictWriter(output, fieldnames=["email", "name", "temp_password"])
        writer.writeheader()
        writer.writerows(credentials)

        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=creds_key,
            Body=output.getvalue().encode("utf-8"),
            ContentType="text/csv"
        )
        print(f"🔑 Credentials saved: s3://{S3_BUCKET}/{creds_key}")


# =============================================================================
# メインハンドラー
# =============================================================================

def lambda_handler(event, context):
    """
    S3イベントを受けてCSVを処理
    """
    print(f"📥 Event received: {json.dumps(event)}")

    # S3イベントからファイル情報を取得
    try:
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = unquote_plus(record["s3"]["object"]["key"])
    except (KeyError, IndexError) as e:
        print(f"❌ Invalid event format: {e}")
        return {"statusCode": 400, "body": "Invalid event format"}

    print(f"📁 Processing: s3://{bucket}/{key}")

    # CSVファイルを読み込み
    try:
        response = s3_client.get_object(Bucket=bucket, Key=key)
        csv_content = response["Body"].read().decode("utf-8-sig")  # BOM対応
    except Exception as e:
        print(f"❌ Failed to read CSV: {e}")
        return {"statusCode": 500, "body": f"Failed to read CSV: {e}"}

    # 結果格納
    results = {
        "timestamp": datetime.now().isoformat(),
        "csv_file": key,
        "total": 0,
        "success": 0,
        "failed": 0,
        "skipped": 0,
        "users": [],
    }
    credentials = []

    # CSV処理
    reader = csv.DictReader(io.StringIO(csv_content))

    for row in reader:
        results["total"] += 1

        email = row.get(CSV_COLUMNS["email"], "").lower().strip()
        if not email:
            results["skipped"] += 1
            results["users"].append({
                "row": results["total"],
                "status": "skipped",
                "reason": "メールアドレスが空",
            })
            continue

        print(f"👤 Processing user {results['total']}: {email}")

        # 仮パスワード生成
        temp_password = generate_temp_password()

        user_result = {
            "row": results["total"],
            "email": email,
        }

        try:
            # 1. Cognitoユーザー作成
            cognito_result = create_cognito_user(email, temp_password)
            user_result["cognito"] = cognito_result

            if cognito_result["status"] == "exists":
                results["skipped"] += 1
                user_result["status"] = "skipped"
                user_result["reason"] = "Cognitoに既存ユーザー"
                results["users"].append(user_result)
                continue

            # 2. DynamoDBユーザープロファイル作成
            last_name = row.get(CSV_COLUMNS["last_name"], "")
            first_name = row.get(CSV_COLUMNS["first_name"], "")
            last_name_kana = row.get(CSV_COLUMNS["last_name_kana"], "")
            first_name_kana = row.get(CSV_COLUMNS["first_name_kana"], "")

            dynamo_data = {
                "id": email,
                "submission_id": row.get(CSV_COLUMNS["submission_id"], ""),
                "respondent_id": row.get(CSV_COLUMNS["respondent_id"], ""),
                "submitted_at": row.get(CSV_COLUMNS["submitted_at"], ""),
                "last_name": last_name,
                "first_name": first_name,
                "last_name_kana": last_name_kana,
                "first_name_kana": first_name_kana,
                "birth_date": row.get(CSV_COLUMNS["birth_date"], ""),
                "gender": row.get(CSV_COLUMNS["gender"], ""),
                "temp_password": temp_password,
                "created_at": datetime.now().isoformat(),
                "registration_source": "bulk_import",
            }

            dynamo_result = create_dynamodb_user(dynamo_data)
            user_result["dynamodb"] = dynamo_result

            # 3. S3フォルダ作成
            s3_result = create_s3_folders(email)
            user_result["s3"] = s3_result

            # 成功
            results["success"] += 1
            user_result["status"] = "success"
            user_result["temp_password"] = temp_password

            # 認証情報を記録
            display_name = f"{last_name}{first_name}" if first_name else last_name
            credentials.append({
                "email": email,
                "name": display_name,
                "temp_password": temp_password,
            })

            print(f"✅ User registered: {email}")

        except Exception as e:
            results["failed"] += 1
            user_result["status"] = "failed"
            user_result["error"] = str(e)
            print(f"❌ Failed to register {email}: {e}")

        results["users"].append(user_result)

    # 結果をS3に保存
    save_results_to_s3(results, credentials, key)

    # サマリー出力
    print("=" * 60)
    print("📊 Registration Summary")
    print("=" * 60)
    print(f"Total: {results['total']}")
    print(f"Success: {results['success']}")
    print(f"Skipped: {results['skipped']}")
    print(f"Failed: {results['failed']}")
    print("=" * 60)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Bulk registration completed",
            "total": results["total"],
            "success": results["success"],
            "skipped": results["skipped"],
            "failed": results["failed"],
        })
    }
