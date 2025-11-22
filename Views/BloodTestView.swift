//
//  BloodTestView.swift
//  AWStest
//
//  血液検査データ表示画面(Virgilデザイン)
//

import SwiftUI

struct BloodTestView: View {
    @StateObject private var bloodTestService = BloodTestService.shared
    @State private var showingAbnormalOnly = false
    @State private var searchText = ""

    var body: some View {
        Group {
            if bloodTestService.isLoading {
                loadingView
            } else if !bloodTestService.errorMessage.isEmpty {
                errorView
            } else if let bloodData = bloodTestService.bloodData {
                bloodTestContent(bloodData: bloodData)
            } else {
                emptyStateView
            }
        }
        .task {
            if bloodTestService.bloodData == nil {
                await bloodTestService.fetchBloodTestData()
            }
        }
        .overlay(alignment: .top) {
            if bloodTestService.showCopySuccessToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    Text("プロンプトをコピーしました")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color(hex: "00C853"))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: bloodTestService.showCopySuccessToast)
    }

    // MARK: - Blood Test Content

    @ViewBuilder
    private func bloodTestContent(bloodData: BloodTestService.BloodTestData) -> some View {
        VStack(spacing: VirgilSpacing.lg) {
                // TEST DATE テキスト表示 + コピーボタン
                HStack {
                    Text("TEST DATE: \(formatDate(bloodData.timestamp))")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Button(action: {
                        copyBloodTestResults(bloodData: bloodData)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10, weight: .semibold))
                            Text("結果をコピー")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(.virgilTextPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.virgilTextPrimary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, VirgilSpacing.md)

                // 検査項目カード一覧（2列グリッド）
                let filteredItems = filteredBloodItems(bloodData.bloodItems)

                if filteredItems.isEmpty {
                    VStack(spacing: VirgilSpacing.md) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.virgilTextSecondary)

                        Text(showingAbnormalOnly ? "異常値の項目が見つかりません" : "検索条件に一致する項目がありません")
                            .font(.subheadline)
                            .foregroundColor(.virgilTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(VirgilSpacing.xl)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: VirgilSpacing.sm),
                        GridItem(.flexible(), spacing: VirgilSpacing.sm)
                    ], spacing: VirgilSpacing.sm) {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: BloodTestDetailView(bloodItem: item)
                                .environmentObject(bloodTestService)) {
                                BloodItemCard(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
        }
        .padding(.horizontal, VirgilSpacing.md)
        .padding(.top, VirgilSpacing.md)
        .padding(.bottom, 100)
    }

    // MARK: - Loading View

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text("血液検査データを取得中...")
                .foregroundColor(.virgilTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }

    // MARK: - Error View

    @ViewBuilder
    private var errorView: some View {
        ContentUnavailableViewCompat(
            "エラーが発生しました",
            systemImage: "exclamationmark.triangle.fill",
            description: bloodTestService.errorMessage
        ) {
            Button("再試行") {
                Task {
                    await bloodTestService.refreshData()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    // MARK: - Empty State View

    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableViewCompat(
            "血液検査データがありません",
            systemImage: "heart.text.square",
            description: "血液検査結果をアップロードしてください"
        ) {
            Button("データを取得") {
                Task {
                    await bloodTestService.fetchBloodTestData()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - Helper Methods

    private func filteredBloodItems(_ items: [BloodTestService.BloodItem]) -> [BloodTestService.BloodItem] {
        var filtered = items

        // 異常値フィルター
        if showingAbnormalOnly {
            filtered = bloodTestService.abnormalItems
        }

        // 検索フィルター
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.nameJp.localizedCaseInsensitiveContains(searchText) ||
                item.key.localizedCaseInsensitiveContains(searchText)
            }
        }

        // カスタム順序でソート
        return sortByCustomOrder(filtered)
    }

    private func sortByCustomOrder(_ items: [BloodTestService.BloodItem]) -> [BloodTestService.BloodItem] {
        // 指定された順序
        let customOrder = [
            "ast", "alt", "ggt", "γ-gtp", "gamma_gtp", "alp",
            "hba1c", "hemoglobin_a1c",
            "tg", "triglyceride",
            "hdl", "hdl_cholesterol",
            "ldl", "ldl_cholesterol",
            "fe", "iron",
            "uibc",
            "ferritin",
            "bun", "urea_nitrogen",
            "cre", "creatinine",
            "ua", "uric_acid",
            "tp", "total_protein",
            "alb", "albumin",
            "palb", "prealbumin",
            "tcho", "tc", "total_cholesterol",
            "crp", "c_reactive_protein",
            "ck", "cpk", "creatine_kinase",
            "mg", "magnesium",
            "t-bil", "tbil", "total_bilirubin",
            "d-bil", "dbil", "direct_bilirubin"
        ]

        return items.sorted { item1, item2 in
            let key1 = item1.key.lowercased()
            let key2 = item2.key.lowercased()

            let index1 = customOrder.firstIndex(of: key1) ?? Int.max
            let index2 = customOrder.firstIndex(of: key2) ?? Int.max

            return index1 < index2
        }
    }

    private func formatDate(_ timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }

        return timestamp
    }

    private func copyBloodTestResults(bloodData: BloodTestService.BloodTestData) {
        var text = "以下は私の\(formatDate(bloodData.timestamp))に検査した血液検査結果です。\n結果を考慮してこの後の質問に答えてください。\n\n"
        text += "検査日時：\(formatDate(bloodData.timestamp))\n\n"

        // カスタム順序でソート
        let sortedItems = sortByCustomOrder(bloodData.bloodItems)

        for item in sortedItems {
            text += "検査項目名：\(item.nameJp)（\(item.key.uppercased())）\n"
            text += "今回の数値：\(item.value) \(item.unit)\n"
            text += "前回数値：前回の数値がありません\n"
            text += "正常範囲：\(item.reference)\n"
            text += "\n"
        }

        UIPasteboard.general.string = text

        // コピー完了のフィードバック（ハプティック）
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // トースト表示（BloodTestServiceの共有状態を使用）
        bloodTestService.showCopySuccessToast = true

        // 2秒後に非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            bloodTestService.showCopySuccessToast = false
        }
    }
}

// MARK: - Blood Item Card

struct BloodItemCard: View {
    let item: BloodTestService.BloodItem

    // 肝臓系項目かどうかを判定
    var isLiverRelated: Bool {
        let key = item.key.lowercased()
        switch key {
        case "ast", "got", "alt", "gpt", "ggt", "γ-gtp", "gamma_gtp", "alp":
            return true
        default:
            return false
        }
    }

    // 腎臓系項目かどうかを判定
    var isKidneyRelated: Bool {
        let key = item.key.lowercased()
        switch key {
        case "bun", "urea_nitrogen", "cre", "creatinine", "ua", "uric_acid":
            return true
        default:
            return false
        }
    }

    // HbA1c項目かどうかを判定
    var isHbA1c: Bool {
        let key = item.key.lowercased()
        return key == "hba1c" || key == "hemoglobin_a1c"
    }

    // 絵文字マッピング（BloodTestDetailViewと同じ）
    var emoji: String {
        let key = item.key.lowercased()
        switch key {
        // 血糖・代謝系
        case "hba1c", "hemoglobin_a1c": return ""
        case "glucose", "glu", "blood_sugar": return "🩸"
        case "ga", "glycoalbumin": return "🍰"
        case "1,5-ag", "1_5_ag": return "🍯"

        // 肝機能系（カスタム画像を使用）
        case "ast", "got": return ""
        case "alt", "gpt": return ""
        case "ggt", "γ-gtp", "gamma_gtp": return ""
        case "alp": return ""
        case "t-bil", "tbil", "total_bilirubin": return "💛"
        case "d-bil", "dbil", "direct_bilirubin": return "💛"

        // 脂質系
        case "tc", "tcho", "total_cholesterol": return "🧈"
        case "tg", "triglyceride": return "🥓"
        case "hdl", "hdl_cholesterol": return "👼"
        case "ldl", "ldl_cholesterol": return "👿"
        case "apob", "apo_b": return "🔬"
        case "lp(a)", "lipoprotein_a": return "🧬"

        // タンパク質系
        case "tp", "total_protein": return "🥩"
        case "alb", "albumin": return "🥚"
        case "palb", "prealbumin": return "🥛"

        // 腎機能系（カスタム画像を使用）
        case "bun", "urea_nitrogen": return ""
        case "cre", "creatinine": return ""
        case "ua", "uric_acid": return ""
        case "egfr": return "🚰"

        // 炎症・免疫系
        case "crp", "c_reactive_protein": return "🔥"
        case "wbc", "white_blood_cell": return "🛡️"
        case "neutrophil": return "⚔️"

        // 血液成分系
        case "rbc", "red_blood_cell": return "🔴"
        case "hb", "hemoglobin": return "🩸"
        case "ht", "hematocrit": return "📊"
        case "mcv": return "📏"
        case "mch": return "📐"
        case "mchc": return "🎨"
        case "plt", "platelet": return "🩹"

        // ミネラル・ビタミン系
        case "fe", "iron": return "⚙️"
        case "ferritin": return "🧲"
        case "zn", "zinc": return "⚡"
        case "mg", "magnesium": return "💚"
        case "ca", "calcium": return "🦴"
        case "vitamin_d", "vit_d": return "☀️"
        case "vitamin_b12", "vit_b12": return "🌟"

        // 筋肉・運動系
        case "ck", "cpk", "creatine_kinase": return "💪"
        case "mb", "myoglobin": return "🏃"
        case "lac", "lactate": return "🔋"

        // 甲状腺系
        case "tsh": return "🦋"
        case "ft3", "ft4": return "🦋"

        // ホルモン系
        case "cortisol": return "😰"
        case "testosterone": return "💪"
        case "estrogen": return "🌸"

        default: return "🔬"
        }
    }

    // ステータス色
    var statusColor: Color {
        switch item.statusColor {
        case "green":
            return Color(hex: "00C853")
        case "orange":
            return Color(hex: "FFCB05")
        case "red":
            return Color(hex: "ED1C24")
        default:
            return .gray
        }
    }

    // 基準範囲をパース（例: "10-40" → (10.0, 40.0)）
    private func parseReferenceRange(_ reference: String) -> (min: Double, max: Double)? {
        let components = reference.split(separator: "-")
        guard components.count == 2,
              let min = Double(components[0].trimmingCharacters(in: .whitespaces)),
              let max = Double(components[1].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        return (min, max)
    }

    // 進捗率を計算（0.0〜1.0）
    private var progress: Double {
        guard let (min, max) = parseReferenceRange(item.reference),
              let value = Double(item.value.trimmingCharacters(in: .whitespaces)) else {
            // パース失敗時はステータスに応じたデフォルト値
            switch item.statusColor {
            case "green": return 0.75
            case "orange": return 0.5
            case "red": return 0.25
            default: return 0.5
            }
        }

        // 進捗率を計算（範囲外の場合はクリップ）
        let normalizedProgress = (value - min) / (max - min)
        return Swift.max(0.0, Swift.min(1.0, normalizedProgress))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 上部：アイコン（左上）
            HStack {
                if isLiverRelated {
                    Image("liver_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40.32, height: 40.32)
                } else if isKidneyRelated {
                    Image("kidney_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40.32, height: 40.32)
                } else if isHbA1c {
                    Image("sugar_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40.32, height: 40.32)
                } else {
                    Text(emoji)
                        .font(.system(size: 34.56))
                }
                Spacer()
            }
            .padding(.top, VirgilSpacing.sm)
            .padding(.horizontal, VirgilSpacing.sm)

            Spacer()

            // 中央：半円ゲージ + 数値 + 項目名
            VStack(spacing: 0) {
                // 半円ゲージ（アーチ状）
                SemiCircleGaugeView(
                    progress: progress,
                    gaugeColor: statusColor
                )
                .frame(width: 100, height: 50)

                // 数値 + 単位（縦並び）
                VStack(spacing: 0) {
                    Text(item.value)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.virgilTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(item.unit)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                }
                .offset(y: -30)

                // 項目名（2行：日本語名 + 英語名）
                VStack(spacing: 2) {
                    Text(item.nameJp)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                        .lineLimit(1)

                    Text("(\(item.key.uppercased()))")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                        .lineLimit(1)
                }
                .offset(y: -30)
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // 下部：ステータスバッジ（中央）
            HStack {
                Spacer()
                Text(item.status)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(12)
                Spacer()
            }
            .padding(.bottom, VirgilSpacing.sm)
            .offset(y: -30)
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity)
        .aspectRatio(0.85, contentMode: .fit)
        .virgilGlassCard(interactive: true)
    }
}

// MARK: - View Extension for Conditional Modifiers

extension View {
    @ViewBuilder
    func apply<T: View>(@ViewBuilder _ transform: (Self) -> T) -> some View {
        transform(self)
    }
}

// MARK: - Preview

struct BloodTestView_Previews: PreviewProvider {
    static var previews: some View {
        BloodTestView()
    }
}
