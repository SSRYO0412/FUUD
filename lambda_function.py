import json
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

# AWSクライアントの初期化
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# 設定
S3_BUCKET = 'tuunapp-gene-data-a7x9k3'
USER_TABLE = dynamodb.Table('Users')  # 修正: user-profiles → Users

def lambda_handler(event, context):
    """
    ユーザープロファイル作成のメイン処理
    注意: Cognitoユーザーは既にアプリ側で作成済みのため、ここでは作成しない
    """
    print(f"Event: {json.dumps(event)}")

    try:
        # リクエストボディを解析
        body = json.loads(event['body'])
        email = body['email'].lower().strip()  # メールアドレスを正規化

        # 入力検証
        if not validate_email(email):
            return create_response(400, {'error': '無効なメールアドレス形式です'})

        # 1. S3フォルダ作成
        print(f"Creating S3 folders for: {email}")
        s3_results = create_user_folders(email)

        # 2. DynamoDBにユーザープロファイル作成
        print(f"Creating user profile in DynamoDB for: {email}")
        profile = create_user_profile(email)

        # 成功レスポンス
        return create_response(200, {
            'message': 'ユーザープロファイルが正常に作成されました',
            'userId': email,
            's3Folders': s3_results,
            'profile': profile
        })

    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        print(f"AWS Error: {error_code} - {error_message}")

        # エラーメッセージを日本語化
        if error_code == 'ConditionalCheckFailedException':
            return create_response(409, {'error': 'このユーザーは既に登録されています'})
        else:
            return create_response(500, {'error': f'エラー: {error_message}'})

    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        import traceback
        print(traceback.format_exc())
        return create_response(500, {'error': '予期しないエラーが発生しました'})

def validate_email(email):
    """
    メールアドレスの基本的な検証
    """
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def create_user_folders(email):
    """
    S3にユーザー専用フォルダを作成
    """
    results = []

    # フォルダ定義
    folders = [
        {
            'path': f'raw-gene/{email}/',
            'description': '遺伝子データ用'
        },
        {
            'path': f'raw-blood/{email}/',
            'description': '血液検査データ用'
        }
    ]

    for folder in folders:
        try:
            # 空のオブジェクトでフォルダを作成
            s3.put_object(
                Bucket=S3_BUCKET,
                Key=folder['path']
            )

            results.append({
                'path': folder['path'],
                'status': 'created',
                'description': folder['description']
            })

        except Exception as e:
            results.append({
                'path': folder['path'],
                'status': 'failed',
                'error': str(e)
            })

    # READMEファイルを作成
    readme_content = f"""# {email} のデータフォルダ

作成日: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## フォルダ構成
- raw-gene/: 遺伝子データをアップロード
- raw-blood/: 血液検査データをアップロード

## 使用方法
各フォルダに.txtファイルをアップロードしてください。
アップロードされたファイルは自動的に処理されます。

## 注意事項
- 遺伝子データは23andMe形式のテキストファイルをアップロード
- 血液検査データは指定フォーマットのテキストファイルをアップロード
"""

    try:
        s3.put_object(
            Bucket=S3_BUCKET,
            Key=f'raw-gene/{email}/README.md',
            Body=readme_content.encode('utf-8'),
            ContentType='text/markdown'
        )
        results.append({
            'path': f'raw-gene/{email}/README.md',
            'status': 'created',
            'description': 'READMEファイル'
        })
    except Exception as e:
        print(f"README creation error: {e}")

    return results

def create_user_profile(email):
    """
    DynamoDBにユーザープロファイルを作成
    修正: Usersテーブルのスキーマに合わせてシンプルな構造に変更
    """
    try:
        # Usersテーブルのスキーマに合わせる
        # primary key: id (String)
        # その他: name (String)
        profile = {
            'id': email,  # 修正: userId → id
            'name': email.split('@')[0]  # メールの@前を名前として使用
        }

        USER_TABLE.put_item(Item=profile)
        print(f"✅ User profile created in DynamoDB: {email}")
        return profile

    except Exception as e:
        print(f"❌ Profile creation failed: {e}")
        raise

def create_response(status_code, body):
    """
    API Gatewayレスポンスを作成
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST,OPTIONS'
        },
        'body': json.dumps(body, ensure_ascii=False)
    }
