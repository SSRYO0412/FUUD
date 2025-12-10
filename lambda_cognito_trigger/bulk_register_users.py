#!/usr/bin/env python3
"""
TUUN ユーザー一括登録スクリプト

CSVファイルからユーザーを一括でCognito/DynamoDB/S3に登録する。
仮パスワードを自動生成し、初回ログイン時に変更を強制する。

使用方法:
    # ドライラン（実際には登録しない）
    python bulk_register_users.py --csv /path/to/csv --profile tuun --dry-run

    # 本番実行
    python bulk_register_users.py --csv /path/to/csv --profile tuun
"""

import argparse
import csv
import json
import secrets
import string
from datetime import datetime
from pathlib import Path

import boto3
from botocore.exceptions import ClientError

# AWS設定
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


def generate_temp_password(length: int = 12) -> str:
    """
    Cognito要件を満たす仮パスワードを生成
    要件: 8文字以上、大文字、小文字、数字、記号を含む
    """
    # 必須文字を1つずつ確保
    password = [
        secrets.choice(string.ascii_uppercase),  # 大文字
        secrets.choice(string.ascii_lowercase),  # 小文字
        secrets.choice(string.digits),  # 数字
        secrets.choice("!@#$%^&*"),  # 記号
    ]

    # 残りをランダムに埋める
    all_chars = string.ascii_letters + string.digits + "!@#$%^&*"
    password.extend(secrets.choice(all_chars) for _ in range(length - 4))

    # シャッフル
    secrets.SystemRandom().shuffle(password)

    return "".join(password)


def create_cognito_user(cognito_client, email: str, temp_password: str, dry_run: bool = False) -> dict:
    """
    Cognitoにユーザーを作成（メール通知なし）
    """
    if dry_run:
        return {"status": "dry_run", "message": "ドライラン - Cognitoユーザー作成スキップ"}

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
        return {"status": "success", "user": response["User"]["Username"]}

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "UsernameExistsException":
            return {"status": "exists", "message": "ユーザーは既に存在します"}
        raise


def create_dynamodb_user(dynamodb_table, user_data: dict, dry_run: bool = False) -> dict:
    """
    DynamoDBにユーザープロファイルを作成
    """
    if dry_run:
        return {"status": "dry_run", "message": "ドライラン - DynamoDB登録スキップ"}

    try:
        dynamodb_table.put_item(Item=user_data)
        return {"status": "success"}

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "ConditionalCheckFailedException":
            return {"status": "exists", "message": "ユーザーは既に存在します"}
        raise


def create_s3_folders(s3_client, email: str, dry_run: bool = False) -> dict:
    """
    S3にユーザー専用フォルダを作成
    """
    if dry_run:
        return {"status": "dry_run", "message": "ドライラン - S3フォルダ作成スキップ"}

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

    return {"status": "success", "folders": results}


def process_csv(csv_path: str, profile: str, dry_run: bool = False) -> dict:
    """
    CSVを読み込んでユーザーを一括登録
    """
    # AWSセッション作成
    session = boto3.Session(profile_name=profile, region_name=AWS_REGION)
    cognito_client = session.client("cognito-idp")
    dynamodb = session.resource("dynamodb")
    dynamodb_table = dynamodb.Table(DYNAMODB_TABLE)
    s3_client = session.client("s3")

    # 結果格納
    results = {
        "timestamp": datetime.now().isoformat(),
        "csv_path": csv_path,
        "dry_run": dry_run,
        "total": 0,
        "success": 0,
        "failed": 0,
        "skipped": 0,
        "users": [],
    }

    # 認証情報出力用
    credentials = []

    # CSV読み込み
    with open(csv_path, encoding="utf-8") as f:
        reader = csv.DictReader(f)

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

            # 仮パスワード生成
            temp_password = generate_temp_password()

            user_result = {
                "row": results["total"],
                "email": email,
                "temp_password": temp_password if not dry_run else "****",
            }

            try:
                # 1. Cognito ユーザー作成
                cognito_result = create_cognito_user(cognito_client, email, temp_password, dry_run)
                user_result["cognito"] = cognito_result

                if cognito_result["status"] == "exists":
                    results["skipped"] += 1
                    user_result["status"] = "skipped"
                    user_result["reason"] = "Cognitoに既存ユーザー"
                    results["users"].append(user_result)
                    continue

                # 2. DynamoDB ユーザープロファイル作成
                # 姓名の取得（2パターン対応）
                last_name = row.get(CSV_COLUMNS["last_name"], "")
                first_name = row.get(CSV_COLUMNS["first_name"], "")

                # 姓名が分離されていない場合（姓のみに全名が入っている）
                if last_name and not first_name:
                    # 姓に全名が入っているケース
                    full_name = last_name
                    last_name = full_name
                    first_name = ""

                last_name_kana = row.get(CSV_COLUMNS["last_name_kana"], "")
                first_name_kana = row.get(CSV_COLUMNS["first_name_kana"], "")

                # カナも同様に処理
                if last_name_kana and not first_name_kana:
                    full_name_kana = last_name_kana
                    last_name_kana = full_name_kana
                    first_name_kana = ""

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

                # 空の値を除去
                dynamo_data = {k: v for k, v in dynamo_data.items() if v}

                dynamo_result = create_dynamodb_user(dynamodb_table, dynamo_data, dry_run)
                user_result["dynamodb"] = dynamo_result

                # 3. S3 フォルダ作成
                s3_result = create_s3_folders(s3_client, email, dry_run)
                user_result["s3"] = s3_result

                # 成功
                results["success"] += 1
                user_result["status"] = "success"

                # 認証情報を記録
                display_name = f"{last_name}{first_name}" if first_name else last_name
                credentials.append({
                    "email": email,
                    "name": display_name,
                    "temp_password": temp_password,
                })

            except Exception as e:
                results["failed"] += 1
                user_result["status"] = "failed"
                user_result["error"] = str(e)

            results["users"].append(user_result)

    return results, credentials


def save_results(results: dict, credentials: list, output_dir: str):
    """
    結果をファイルに保存
    """
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # 詳細レポート（JSON）
    report_path = output_path / f"registration_report_{timestamp}.json"
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"詳細レポート: {report_path}")

    # 認証情報CSV（運営用）
    if credentials:
        creds_path = output_path / f"user_credentials_{timestamp}.csv"
        with open(creds_path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["email", "name", "temp_password"])
            writer.writeheader()
            writer.writerows(credentials)
        print(f"認証情報CSV: {creds_path}")


def main():
    parser = argparse.ArgumentParser(description="TUUN ユーザー一括登録スクリプト")
    parser.add_argument("--csv", required=True, help="入力CSVファイルパス")
    parser.add_argument("--profile", required=True, help="AWSプロファイル名")
    parser.add_argument("--dry-run", action="store_true", help="ドライラン（実際には登録しない）")
    parser.add_argument("--output", default="./output", help="出力ディレクトリ（デフォルト: ./output）")

    args = parser.parse_args()

    print("=" * 60)
    print("TUUN ユーザー一括登録")
    print("=" * 60)
    print(f"CSV: {args.csv}")
    print(f"AWSプロファイル: {args.profile}")
    print(f"ドライラン: {args.dry_run}")
    print(f"出力先: {args.output}")
    print("=" * 60)

    if args.dry_run:
        print("\n[ドライランモード] 実際の登録は行いません\n")

    # 実行
    results, credentials = process_csv(args.csv, args.profile, args.dry_run)

    # 結果サマリー表示
    print("\n" + "=" * 60)
    print("実行結果サマリー")
    print("=" * 60)
    print(f"合計: {results['total']}")
    print(f"成功: {results['success']}")
    print(f"スキップ: {results['skipped']}")
    print(f"失敗: {results['failed']}")

    # 結果保存
    save_results(results, credentials, args.output)

    print("\n完了!")


if __name__ == "__main__":
    main()
