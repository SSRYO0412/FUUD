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
    }

    // MARK: - Blood Test Content

    @ViewBuilder
    private func bloodTestContent(bloodData: BloodTestService.BloodTestData) -> some View {
        VStack(spacing: VirgilSpacing.lg) {
                // TEST DATE テキスト表示
                HStack {
                    Text("TEST DATE: \(formatDate(bloodData.timestamp))")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
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
                            NavigationLink(destination: BloodTestDetailView(bloodItem: item)) {
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

    // グラデーション色
    var gradientColors: [Color] {
        switch item.statusColor {
        case "green":
            return [Color(hex: "66BB6A"), Color(hex: "C8E6C9")]
        case "orange":
            return [Color(hex: "FBC02D"), Color(hex: "FFF9C4")]
        case "red":
            return [Color(hex: "E57373"), Color(hex: "FFCCBC")]
        default:
            return [Color.gray, Color.gray.opacity(0.5)]
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

    var body: some View {
        VStack(spacing: VirgilSpacing.xs) {
            // アイコン（肝臓系・腎臓系・HbA1cはカスタム画像、それ以外は絵文字）
            if isLiverRelated {
                Image("liver_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(.top, VirgilSpacing.xs)
            } else if isKidneyRelated {
                Image("kidney_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(.top, VirgilSpacing.xs)
            } else if isHbA1c {
                Image("sugar_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(.top, VirgilSpacing.xs)
            } else {
                Text(emoji)
                    .font(.system(size: 28))
                    .padding(.top, VirgilSpacing.xs)
            }

            Spacer()

            // 項目名
            VStack(spacing: 2) {
                Text(item.nameJp)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(item.key.uppercased())
                    .font(.system(size: 7, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // 値 + 単位（大きく）
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(item.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(item.unit)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }

            // ステータスバッジ（大きく）
            Text(item.status)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.15))
                .cornerRadius(10)
                .padding(.bottom, VirgilSpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
        .padding(VirgilSpacing.sm)
        .background(
            LinearGradient(
                colors: gradientColors.map { $0.opacity(0.08) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
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
