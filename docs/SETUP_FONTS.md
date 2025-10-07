# フォントセットアップガイド

## 必要なフォント

### 1. Inter Font Family
- **配布元:** Google Fonts (https://fonts.google.com/specimen/Inter)
- **必要ウェイト:**
  - Inter-Regular.ttf (400)
  - Inter-SemiBold.ttf (600)
  - Inter-Bold.ttf (700)

### 2. JetBrains Mono
- **配布元:** JetBrains (https://www.jetbrains.com/lp/mono/)
- **必要ウェイト:**
  - JetBrainsMono-Regular.ttf (400)

## インストール手順

### Step 1: フォントファイルダウンロード

**Inter:**
```bash
# Google Fontsからダウンロード
curl -L "https://fonts.google.com/download?family=Inter" -o Inter.zip
unzip Inter.zip -d Inter
```

**JetBrains Mono:**
```bash
# JetBrains公式サイトからダウンロード
curl -L "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip" -o JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
```

### Step 2: プロジェクトへの追加

1. Xcodeでプロジェクトを開く
2. プロジェクトナビゲータで右クリック → "Add Files to TUUN..."
3. 以下のファイルを選択:
   - `Inter-Regular.ttf`
   - `Inter-SemiBold.ttf`
   - `Inter-Bold.ttf`
   - `JetBrainsMono-Regular.ttf`
4. "Copy items if needed" にチェック
5. "Add to targets: TUUN" にチェック

### Step 3: Info.plist更新

Xcodeプロジェクト設定で以下を追加:

1. プロジェクトナビゲータで `TUUN` ターゲット選択
2. "Info" タブ選択
3. "Custom iOS Target Properties" セクションで "+" ボタンクリック
4. キー `Fonts provided by application` 追加
5. 以下の値を配列に追加:
   - `Inter-Regular.ttf`
   - `Inter-SemiBold.ttf`
   - `Inter-Bold.ttf`
   - `JetBrainsMono-Regular.ttf`

### Step 4: Build Settingsの確認

1. プロジェクト設定 → "Build Settings"
2. "Deployment" セクション
3. "iOS Deployment Target" を `15.0` に設定

### Step 5: 動作確認

```swift
// プレビュー用コード
struct FontTestView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Inter Regular")
                .font(.custom("Inter", size: 16))

            Text("Inter SemiBold")
                .font(.custom("Inter", size: 16).weight(.semibold))

            Text("Inter Bold")
                .font(.custom("Inter", size: 16).weight(.bold))

            Text("JetBrains Mono")
                .font(.custom("JetBrains Mono", size: 16))
        }
        .padding()
    }
}
```

## トラブルシューティング

### フォントが表示されない場合

1. **Build Phaseの確認:**
   - "Copy Bundle Resources" にフォントファイルが含まれているか確認

2. **フォント名の確認:**
```swift
// 利用可能なフォント一覧を出力
for family in UIFont.familyNames.sorted() {
    print("Family: \(family)")
    for name in UIFont.fontNames(forFamilyName: family) {
        print("  - \(name)")
    }
}
```

3. **Info.plistの確認:**
   - フォントファイル名が正確に記載されているか確認
   - 拡張子 `.ttf` が含まれているか確認

### iOS 15.0への変更後のエラー

**エラー例:**
```
'Layout' is only available in iOS 16.0 or newer
```

**対処法:**
- 該当APIをiOS 15互換の代替実装に置き換え
- `design-analysis.md` の「iOS 15互換性対応」セクション参照

## 検証チェックリスト

- [ ] Inter-Regular.ttf がプロジェクトに追加されている
- [ ] Inter-SemiBold.ttf がプロジェクトに追加されている
- [ ] Inter-Bold.ttf がプロジェクトに追加されている
- [ ] JetBrainsMono-Regular.ttf がプロジェクトに追加されている
- [ ] Info.plistに全フォントが登録されている
- [ ] iOS Deployment Target が 15.0 に設定されている
- [ ] Build Phaseの "Copy Bundle Resources" に全フォントが含まれている
- [ ] 実機/シミュレータでフォント表示確認完了

---

**作成日:** 2025-10-08
**担当:** Phase 0実装チーム
