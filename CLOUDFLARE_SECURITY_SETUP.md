# Cloudflare + mTLS セキュリティ設定メモ

## 概要

Chat APIをCloudflare経由 + mTLS認証で保護する設定を実装。

## 現在の構成

```
iOS App
   ↓ HTTPS
Cloudflare (api.tuun-api.com)
   ↓ mTLS (Authenticated Origin Pulls)
AWS API Gateway (カスタムドメイン)
   ↓ Cognito認証
Lambda (PII Sanitizer)
   ↓
OpenAI API
```

## 実装済みAPI

| API | エンドポイント | Cloudflare | mTLS | Cognito |
|-----|---------------|------------|------|---------|
| Chat | `https://api.tuun-api.com/chat` | ✅ | ✅ | ✅ |
| createUser | 直接API Gateway | ❌ | ❌ | ❌ |
| healthProfile | 直接API Gateway | ❌ | ❌ | ✅ |
| bloodData | 直接API Gateway | ❌ | ❌ | ✅ |
| geneData | 直接API Gateway | ❌ | ❌ | ✅ |

---

## 今回行った設定

### 1. Cloudflare DNS設定
- **ドメイン**: `api.tuun-api.com`
- **レコードタイプ**: CNAME
- **ターゲット**: `d-t9l9cmxlsj.execute-api.ap-northeast-1.amazonaws.com`
- **Proxy**: 有効（オレンジ雲）

### 2. AWS API Gateway カスタムドメイン設定
- **ドメイン名**: `api.tuun-api.com`
- **証明書**: ACM証明書（*.tuun-api.com）
- **mTLS**: 有効
- **Truststore**: `s3://tuun-certificates/cloudflare_aop_ca.pem`

### 3. Base Path Mapping
- **Path**: (空)
- **API**: `kbodeqy5wa` (chat-api)
- **Stage**: `prod`

### 4. iOS設定 (ConfigurationManager.swift)
```swift
chat: "https://api.tuun-api.com/chat"
```

---

## 発生したエラーと解決策

### エラー1: 403 Forbidden（CNAME間違い）

**原因**: CloudflareのCNAMEターゲットが間違っていた
```
誤: kbodeqy5wa.execute-api.ap-northeast-1.amazonaws.com (API Gateway ID)
正: d-t9l9cmxlsj.execute-api.ap-northeast-1.amazonaws.com (カスタムドメインのregionalDomainName)
```

**解決**: API Gatewayカスタムドメインの`regionalDomainName`を確認
```bash
aws apigateway get-domain-name --domain-name api.tuun-api.com
# → "regionalDomainName": "d-t9l9cmxlsj.execute-api.ap-northeast-1.amazonaws.com"
```

### エラー2: 403 Forbidden（mTLS証明書なし）

**原因**: CloudflareのAuthenticated Origin Pullsがオンだが、API Gateway側でmTLSが有効なのにCloudflareの証明書を検証できていなかった

**解決**:
1. Cloudflare公式のAOP CA証明書をダウンロード
   ```
   https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem
   ```
2. S3にアップロード (`s3://tuun-certificates/cloudflare_aop_ca.pem`)
3. API GatewayのmTLS truststoreに設定

### エラー3: 403 Missing Authentication Token

**原因**: Base path mappingが`chat`に設定されていたため、URLパスがずれていた
```
リクエスト: /chat
Base path mapping: chat → kbodeqy5wa/prod/
実際のルーティング: kbodeqy5wa/prod/ (ルート) → メソッドなし → 403
```

**解決**: Base pathを空に変更
```
リクエスト: /chat
Base path mapping: (空) → kbodeqy5wa/prod/
実際のルーティング: kbodeqy5wa/prod/chat → POST → 成功
```

---

## 他のAPIをCloudflare経由にする際の注意点

### 1. CNAMEターゲットの確認
- API Gateway IDではなく、**カスタムドメインのregionalDomainName**を使用
- 確認コマンド:
  ```bash
  aws apigateway get-domain-name --domain-name <ドメイン名>
  ```

### 2. Base Path Mappingの設計
- **推奨**: Base pathを空にして、URLパスをそのままルーティング
- 複数APIを1つのドメインで管理する場合は慎重に設計

### 3. mTLS設定
- Cloudflare AOP CA証明書は全API共通で使用可能
- 既存のtruststoreを再利用: `s3://tuun-certificates/cloudflare_aop_ca.pem`

### 4. Cloudflare Authenticated Origin Pulls
- ゾーン単位で有効化すれば、サブドメイン全体に適用される
- 現在`tuun-api.com`ゾーンで有効化済み

### 5. API Gateway直接アクセスの無効化
- `disableExecuteApiEndpoint: true`を設定してデフォルトエンドポイントを無効化
- これによりCloudflare経由のみアクセス可能になる

### 6. DNS伝播時間
- CNAME変更後、最大数分かかる場合がある
- テスト時は`dig`コマンドで確認:
  ```bash
  dig api.tuun-api.com CNAME
  ```

---

## Cloudflare API認証情報

ファイル: `~/.cloudflare/credentials`
```ini
[tuun]
api_token = <API_TOKEN>
zone_id = 0509c05d322e6762032ee5c09d0e4a5d
```

**APIトークン権限**:
- Zone: DNS Edit
- Zone: DNS Read

---

## 今後のTODO

- [ ] bloodData APIをCloudflare経由に移行
- [ ] geneData APIをCloudflare経由に移行
- [ ] healthProfile APIをCloudflare経由に移行
- [ ] createUser APIをCloudflare経由に移行
- [ ] Cloudflare WAFルール追加（レート制限、SQLi/XSS防御）

---

## 参考リンク

- [Cloudflare Authenticated Origin Pulls](https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/)
- [AWS API Gateway mTLS](https://docs.aws.amazon.com/apigateway/latest/developerguide/rest-api-mutual-tls.html)
- [Cloudflare AOP CA証明書](https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem)

---

*最終更新: 2025-12-07*
