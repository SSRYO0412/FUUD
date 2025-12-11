# バックエンド実装TODO

後でまとめて実装するバックエンドタスクのメモ

---

## Phase 6: プログラム管理API

### 必要なエンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| POST | `/api/v1/programs/{programId}/enroll` | プログラム登録 |
| GET | `/api/v1/programs/enrolled` | 登録中のプログラム取得 |
| DELETE | `/api/v1/programs/enrolled` | プログラムキャンセル |

### リクエスト/レスポンス仕様

#### POST /api/v1/programs/{programId}/enroll
```json
// Request
{
  "program_id": "low-carb-28",
  "duration": 45,
  "start_date": "2025-12-11T00:00:00Z"
}

// Response
{
  "enrollment": {
    "id": "enrollment-uuid",
    "userId": "user-email",
    "programId": "low-carb-28",
    "duration": 45,
    "startDate": "2025-12-11T00:00:00Z",
    "endDate": "2026-01-25T00:00:00Z",
    "status": "active",
    "enrolledAt": "2025-12-11T12:00:00Z"
  },
  "message": "プログラムを開始しました"
}
```

#### GET /api/v1/programs/enrolled
```json
// Response
{
  "enrollment": {
    "id": "enrollment-uuid",
    "userId": "user-email",
    "programId": "low-carb-28",
    "duration": 45,
    "startDate": "2025-12-11T00:00:00Z",
    "endDate": "2026-01-25T00:00:00Z",
    "status": "active",
    "enrolledAt": "2025-12-11T12:00:00Z"
  }
}
```

### DynamoDB テーブル設計案

テーブル名: `fuud-program-enrollments`

| 属性 | 型 | 説明 |
|------|-----|------|
| userId (PK) | String | ユーザーID（メールアドレス） |
| id (SK) | String | 登録ID |
| programId | String | プログラムID |
| duration | Number | 期間（日数） |
| startDate | String | 開始日（ISO8601） |
| endDate | String | 終了日（ISO8601） |
| status | String | active/paused/completed/cancelled |
| enrolledAt | String | 登録日時（ISO8601） |

### 関連ファイル（クライアント側）
- `Services/DietProgramService.swift` - API呼び出し実装済み
- `Views/Programs/DurationSelectionSheet.swift` - UI実装済み
- `Models/DietProgram.swift` - ProgramEnrollmentモデル定義済み

---

## 一時的な対処オプション（バックエンド実装までの間）

### オプション: ローカルストレージでプログラム登録を管理

UserDefaultsを使ってプログラム登録をローカルに保存し、バックエンドなしでUIをテスト可能にする方法。

**実装箇所:**
- `DietProgramService.swift` の `enrollProgram()` を修正
- UserDefaultsに `ProgramEnrollment` を保存/読み込み
- バックエンド実装後に切り替え

**メリット:**
- バックエンドなしでUI全体をテスト可能
- オフライン対応にもなる

**デメリット:**
- 後でバックエンド連携に切り替える作業が必要

---

## 今後追加予定のバックエンドタスク

（ここに追加していく）

---

*最終更新: 2025-12-11*
