#!/usr/bin/env python3
"""
文科省「日本食品標準成分表」データをDynamoDBに投入するスクリプト

データソース:
  GitHub: katoharu432/standards-tables-of-food-composition-in-japan
  URL: https://raw.githubusercontent.com/katoharu432/standards-tables-of-food-composition-in-japan/master/data.json

実行方法:
  cd /Users/sasakiryo/Documents/FUUD
  pip install boto3 requests
  AWS_PROFILE=tuun-terraform python scripts/import_mext_foods.py

注意:
  - claude-code プロファイルでは fuud-* テーブルへの書き込み権限がない
  - 必ず tuun-terraform プロファイルで実行すること
"""
import json
import boto3
import requests
from decimal import Decimal
from datetime import datetime


# =============================================================================
# Configuration
# =============================================================================

TABLE_NAME = "fuud-foods-dev"
DATA_URL = "https://raw.githubusercontent.com/katoharu432/standards-tables-of-food-composition-in-japan/master/data.json"
AWS_REGION = "ap-northeast-1"


# =============================================================================
# Helper Functions (ループより前に定義！)
# =============================================================================

def clean_value(val):
    """
    null, 'Tr', '-' などを適切に変換
    DynamoDBはNoneを保存できないので、Noneはそのまま返す（後でフィルタ）

    変換ルール:
      - None → None
      - 'Tr' (微量) → 0
      - '-' (未測定) → None
      - '(12)' (推定値) → 12
      - 数値 → Decimal
    """
    if val is None:
        return None

    if isinstance(val, str):
        val = val.strip()
        if val in ['Tr', '-', '', '(Tr)', '―']:
            return Decimal('0') if val == 'Tr' or val == '(Tr)' else None

        # 括弧付き推定値 "(12)" → 12
        if val.startswith('(') and val.endswith(')'):
            try:
                return Decimal(val[1:-1])
            except (ValueError, decimal.InvalidOperation):
                return None

    try:
        return Decimal(str(val))
    except Exception:
        return None


def build_nutrients(food: dict) -> dict:
    """
    栄養素データを構築（Noneの項目はキーごと除外）
    DynamoDBはNoneを保存できないため

    フィールドマッピング:
      元データキー → DynamoDBキー
      enercKcal → enerc_kcal
      prot → protein
      choavldf → carbs (利用可能炭水化物)
      fib → fiber
      thia → vitb1
      ribf → vitb2
    """
    fields = {
        'enerc_kcal': food.get('enercKcal'),
        'water': food.get('water'),
        'protein': food.get('prot'),
        'fat': food.get('fat'),
        'carbs': food.get('choavldf'),  # 利用可能炭水化物
        'fiber': food.get('fib'),
        'na': food.get('na'),
        'k': food.get('k'),
        'ca': food.get('ca'),
        'mg': food.get('mg'),
        'p': food.get('p'),
        'fe': food.get('fe'),
        'zn': food.get('zn'),
        'cu': food.get('cu'),
        'mn': food.get('mn'),
        'vitb1': food.get('thia'),
        'vitb2': food.get('ribf'),
        'vitc': food.get('vitc'),
        'chole': food.get('chole'),  # コレステロール
    }

    nutrients = {}
    for key, raw in fields.items():
        v = clean_value(raw)
        if v is not None:  # Noneの項目はキーごと除外
            nutrients[key] = v

    return nutrients


def format_food_id(group_id: int, food_id: int) -> str:
    """
    食品IDをフォーマット
    groupId=1, foodId=88 → "01088"
    """
    return f"{group_id:02d}{food_id:03d}"


# =============================================================================
# Main Processing
# =============================================================================

def download_food_data() -> list:
    """GitHubからJSONデータをダウンロード"""
    print(f"Downloading food data from GitHub...")
    print(f"URL: {DATA_URL}")

    response = requests.get(DATA_URL, timeout=30)
    response.raise_for_status()

    foods = response.json()
    print(f"Downloaded {len(foods)} food items")
    return foods


def import_to_dynamodb(foods: list, table_name: str) -> tuple[int, int]:
    """DynamoDBにデータを投入"""
    print(f"\nImporting to DynamoDB table: {table_name}")

    dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
    table = dynamodb.Table(table_name)

    success_count = 0
    error_count = 0
    timestamp = datetime.utcnow().isoformat() + "Z"

    for i, food in enumerate(foods):
        try:
            # 必須フィールドの検証
            if 'groupId' not in food or 'foodId' not in food:
                raise ValueError("Missing groupId or foodId")

            item = {
                'food_id': format_food_id(food['groupId'], food['foodId']),
                'group_id': food['groupId'],
                'index_id': food.get('indexId', food['foodId']),
                'food_name': food.get('foodName', ''),
                'refuse': Decimal(str(food.get('refuse', 0) or 0)),
                'nutrients': build_nutrients(food),
                'source': 'mext_8th',
                'created_at': timestamp
            }

            table.put_item(Item=item)
            success_count += 1

            # 進捗表示 (100件ごと)
            if (i + 1) % 100 == 0:
                print(f"Progress: {i + 1}/{len(foods)} ({(i + 1) * 100 // len(foods)}%)")

        except Exception as e:
            error_count += 1
            food_name = food.get('foodName', 'unknown')
            print(f"Error on food '{food_name}': {e}")

    return success_count, error_count


def verify_import(table_name: str) -> dict:
    """インポート結果を検証"""
    print(f"\nVerifying import...")

    dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
    table = dynamodb.Table(table_name)

    # テーブルの件数を取得
    response = table.scan(Select='COUNT')
    count = response['Count']

    # サンプルデータを取得
    sample = table.get_item(Key={'food_id': '01088'})

    return {
        'total_count': count,
        'sample_item': sample.get('Item')
    }


def main():
    """メイン処理"""
    print("=" * 60)
    print("MEXT Food Data Import Script")
    print("=" * 60)

    try:
        # 1. データダウンロード
        foods = download_food_data()

        # 2. DynamoDBにインポート
        success, errors = import_to_dynamodb(foods, TABLE_NAME)

        # 3. 結果表示
        print("\n" + "=" * 60)
        print("Import Complete!")
        print("=" * 60)
        print(f"Success: {success}")
        print(f"Errors:  {errors}")

        # 4. 検証
        verification = verify_import(TABLE_NAME)
        print(f"\nTable count: {verification['total_count']}")

        if verification['sample_item']:
            print(f"\nSample item (01088):")
            print(f"  food_name: {verification['sample_item'].get('food_name')}")
            nutrients = verification['sample_item'].get('nutrients', {})
            print(f"  kcal: {nutrients.get('enerc_kcal')}")
            print(f"  protein: {nutrients.get('protein')}")
            print(f"  fat: {nutrients.get('fat')}")
            print(f"  carbs: {nutrients.get('carbs')}")

    except requests.RequestException as e:
        print(f"Error downloading data: {e}")
        return 1
    except boto3.exceptions.Boto3Error as e:
        print(f"AWS Error: {e}")
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}")
        return 1

    return 0


if __name__ == '__main__':
    exit(main())
