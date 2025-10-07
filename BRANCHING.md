# TUUN UIリニューアル ブランチ戦略

## 1. ブランチ構成

```
main (本番ブランチ)
  │
  ├─ future_uidesign (既存の将来UI検討ブランチ)
  │
  └─ feature/ui-renewal (今回のリニューアルメインブランチ) ← **作業中**
       │
       ├─ feature/ui-renewal/phase-0 (Phase 0専用)
       ├─ feature/ui-renewal/phase-1 (Phase 1専用)
       ├─ feature/ui-renewal/phase-2 (Phase 2専用)
       ├─ feature/ui-renewal/phase-3 (Phase 3専用)
       ├─ feature/ui-renewal/phase-4 (Phase 4専用)
       ├─ feature/ui-renewal/phase-5 (Phase 5専用)
       ├─ feature/ui-renewal/phase-6 (Phase 6専用)
       └─ feature/ui-renewal/phase-7 (Phase 7専用)
```

---

## 2. ブランチ命名規則

### 2.1 メインブランチ

| ブランチ名 | 用途 | 保護設定 |
|-----------|------|---------|
| `main` | 本番リリースブランチ | ✅ Protected |
| `feature/ui-renewal` | リニューアル統合ブランチ | ✅ Protected |

### 2.2 フェーズブランチ

**命名規則:** `feature/ui-renewal/phase-{N}`

例:
- `feature/ui-renewal/phase-0` - 事前準備・環境構築
- `feature/ui-renewal/phase-1` - デザインシステム構築
- `feature/ui-renewal/phase-2` - Home画面実装
- ...

### 2.3 タスクブランチ（必要に応じて）

**命名規則:** `feature/ui-renewal/phase-{N}/{task-name}`

例:
- `feature/ui-renewal/phase-1/design-tokens`
- `feature/ui-renewal/phase-1/animated-orbs`
- `feature/ui-renewal/phase-1/bottom-nav`

---

## 3. ワークフロー

### 3.1 Phase開始時

```bash
# 最新のfeature/ui-renewalから分岐
git checkout feature/ui-renewal
git pull origin feature/ui-renewal
git checkout -b feature/ui-renewal/phase-N

# リモートにpush
git push -u origin feature/ui-renewal/phase-N
```

### 3.2 作業中

```bash
# 定期的にコミット
git add .
git commit -m "feat(phase-N): 実装内容

詳細説明
- 変更点1
- 変更点2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# リモートにpush
git push origin feature/ui-renewal/phase-N
```

### 3.3 Phase完了時

```bash
# Pull Request作成
# Base: feature/ui-renewal
# Compare: feature/ui-renewal/phase-N

# PRタイトル例:
# [Phase N] {Phase名} 完了

# PR本文テンプレート:
## Phase N: {Phase名}

### 完了タスク
- [x] T{N}.1: {タスク名}
- [x] T{N}.2: {タスク名}
...

### 成功基準
- [x] 基準1
- [x] 基準2
...

### レビュー観点
- デザインシステム準拠
- iOS 15.0互換性
- パフォーマンス要件達成
- アクセシビリティ対応

### スクリーンショット
{必要に応じて添付}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## 4. コミットメッセージ規約

### 4.1 Conventional Commits準拠

**フォーマット:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 4.2 Type一覧

| Type | 用途 | 例 |
|------|------|---|
| `feat` | 新機能 | `feat(phase-1): VirgilDesignTokens追加` |
| `fix` | バグ修正 | `fix(phase-2): HomeView VoiceOverラベル修正` |
| `refactor` | リファクタリング | `refactor(phase-4): DataViewModel Combine購読最適化` |
| `perf` | パフォーマンス改善 | `perf(phase-1): AnimatedOrbs blur最適化` |
| `style` | コードスタイル修正 | `style(phase-2): SwiftLint警告解消` |
| `test` | テスト追加 | `test(phase-3): LifestyleServiceユニットテスト` |
| `docs` | ドキュメント | `docs(phase-0): design-analysis.md更新` |
| `chore` | ビルド・設定変更 | `chore(phase-0): iOS Deployment Target 15.0変更` |

### 4.3 Scope一覧

| Scope | 対象 |
|-------|------|
| `phase-0` | Phase 0関連 |
| `phase-1` | Phase 1関連 |
| `design-system` | デザインシステム |
| `services` | Service層 |
| `viewmodels` | ViewModel層 |
| `views` | View層 |
| `tests` | テストコード |

### 4.4 コミット例

```bash
# 良い例
git commit -m "feat(phase-1): VirgilCard コンポーネント実装

- .ultraThinMaterial 背景
- カスタムパディング対応
- アクセシビリティラベル追加

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 悪い例（避ける）
git commit -m "update"
git commit -m "fix bug"
git commit -m "wip"
```

---

## 5. Pull Request (PR) プロセス

### 5.1 PRチェックリスト

**作成者:**
- [ ] 全タスク完了確認
- [ ] ユニットテスト全パス
- [ ] SwiftLint警告解消
- [ ] アクセシビリティ確認
- [ ] スクリーンショット添付（UI変更時）
- [ ] CHANGELOG.md更新

**レビュアー:**
- [ ] コードレビュー完了
- [ ] デザインレビュー完了（デザイナー）
- [ ] 動作確認（実機/シミュレータ）
- [ ] パフォーマンス確認（60fps維持）

### 5.2 レビュープロセス

1. **PR作成** - 作成者がPhase完了後にPR作成
2. **自動チェック** - CI/CD（将来導入時）
3. **コードレビュー** - 開発者レビュー
4. **デザインレビュー** - デザイナーレビュー（UI変更時）
5. **承認** - 2名以上の承認必須
6. **マージ** - Squash and Merge推奨

### 5.3 マージ方法

**推奨: Squash and Merge**

理由:
- Phase内の細かいコミット履歴を集約
- メインブランチの履歴がクリーン
- リバート時の容易性

```bash
# マージ後の履歴イメージ
* feat(phase-1): デザインシステム構築完了 (#PR番号)
* feat(phase-0): 事前準備・環境構築完了 (#PR番号)
```

---

## 6. リリースフロー

### 6.1 全Phase完了後

```bash
# feature/ui-renewal → main へのPR作成
# Base: main
# Compare: feature/ui-renewal

# タイトル:
# Release: TUUN UIリニューアル v2.0

# 本文:
## 変更サマリー
- Virgilデザインに基づいた全面UI刷新
- iOS 15.0以降対応
- パフォーマンス最適化（60fps達成）
- アクセシビリティ強化

## 実装フェーズ
- Phase 0: 事前準備・環境構築
- Phase 1: デザインシステム構築
- Phase 2: Home画面実装
- Phase 3: Lifestyle詳細画面実装
- Phase 4: Data画面・HealthService実装
- Phase 5: Chat画面実装
- Phase 6: WeeklyPlan画面・統合
- Phase 7: 最終調整・リリース準備

## Breaking Changes
なし（Feature Flagで段階的切り替え）

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 6.2 タグ付け

```bash
# メインブランチでタグ作成
git checkout main
git pull origin main
git tag -a v2.0.0 -m "Release: TUUN UIリニューアル v2.0

- Virgilデザイン全面採用
- iOS 15.0+対応
- パフォーマンス最適化
"
git push origin v2.0.0
```

---

## 7. ブランチ保護設定（GitHub）

### 7.1 main ブランチ

**Settings > Branches > Branch protection rules:**

- [x] Require pull request reviews before merging
  - Required approvals: 2
- [x] Require status checks to pass before merging
- [x] Require conversation resolution before merging
- [x] Do not allow bypassing the above settings

### 7.2 feature/ui-renewal ブランチ

**Settings > Branches > Branch protection rules:**

- [x] Require pull request reviews before merging
  - Required approvals: 1
- [x] Require status checks to pass before merging
- [x] Require conversation resolution before merging

---

## 8. トラブルシューティング

### 8.1 コンフリクト発生時

```bash
# feature/ui-renewalの最新を取り込む
git checkout feature/ui-renewal/phase-N
git fetch origin
git rebase origin/feature/ui-renewal

# コンフリクト解消
# ... エディタで修正 ...

git add .
git rebase --continue
git push origin feature/ui-renewal/phase-N --force-with-lease
```

### 8.2 誤ったブランチにコミットした場合

```bash
# コミット取り消し（まだpushしていない場合）
git reset --soft HEAD~1

# 正しいブランチに移動
git checkout feature/ui-renewal/phase-N
git cherry-pick <commit-hash>
```

### 8.3 PRマージ後のクリーンアップ

```bash
# リモートブランチ削除（PRマージ後自動削除推奨）
git push origin --delete feature/ui-renewal/phase-N

# ローカルブランチ削除
git branch -d feature/ui-renewal/phase-N
```

---

## 9. CI/CD統合（将来対応）

### 9.1 GitHub Actions設定例

```yaml
# .github/workflows/ios-build.yml
name: iOS Build and Test

on:
  pull_request:
    branches:
      - feature/ui-renewal
      - main

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild -project TUUN.xcodeproj -scheme TUUN -destination 'platform=iOS Simulator,name=iPhone 14 Pro' build
      - name: Test
        run: xcodebuild -project TUUN.xcodeproj -scheme TUUN -destination 'platform=iOS Simulator,name=iPhone 14 Pro' test
```

---

## 10. チェックリスト

### Phase完了時

- [ ] 全タスク完了
- [ ] ユニットテスト全パス
- [ ] アクセシビリティ確認
- [ ] パフォーマンス60fps達成
- [ ] PRテンプレート記入
- [ ] スクリーンショット添付
- [ ] CHANGELOG.md更新
- [ ] レビュアー指定
- [ ] PR作成

### リリース時

- [ ] 全Phase完了
- [ ] QAテスト全パス
- [ ] App Store準備完了
- [ ] ドキュメント整備
- [ ] タグ付け完了
- [ ] リリースノート作成

---

**作成日:** 2025-10-08
**最終更新:** 2025-10-08
**管理者:** TUUN開発チーム
