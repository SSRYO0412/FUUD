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
    Cognitoトリガー（PostConfirmation）およびAPI Gatewayに対応
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

        # 入力検証
        if not validate_email(email):
            if 'triggerSource' in event:
                # Cognitoトリガーの場合は警告ログのみ（エラーにしない）
                print(f"⚠️ Invalid email format: {email}")
                return event
            else:
                return create_response(400, {'error': '無効なメールアドレス形式です'})

        # 1. S3フォルダ作成
        print(f"Creating S3 folders for: {email}")
        s3_results = create_user_folders(email)

        # 2. DynamoDBにユーザープロファイル作成
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

        # エラーハンドリング（重複チェック）
        if error_code == 'ConditionalCheckFailedException':
            # ユーザーが既に存在する場合
            if 'triggerSource' in event:
                # Cognitoトリガーの場合は成功として扱う（重要！）
                print(f"⚠️ User profile already exists for: {email} - treating as success")
                return event
            else:
                # API Gatewayの場合は409エラーを返す
                return create_response(409, {'error': 'このユーザーは既に登録されています'})

        # その他のエラー
        if 'triggerSource' in event:
            # Cognitoトリガーでは致命的エラーのみ例外を投げる
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
