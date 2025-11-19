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
                bloodTestScrollView(bloodData: bloodData)
            } else {
                emptyStateView
            }
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                OrbBackground()
                GridOverlay()
            }
        )
        .task {
            if bloodTestService.bloodData == nil {
                await bloodTestService.fetchBloodTestData()
            }
        }
        .refreshable {
            await bloodTestService.refreshData()
        }
    }

    // MARK: - Blood Test ScrollView

    @ViewBuilder
    private func bloodTestScrollView(bloodData: BloodTestService.BloodTestData) -> some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // ヘッダーカード(基本情報)
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("基本情報")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        HStack {
                            Text("検査日時")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.virgilTextPrimary)
                            Spacer()
                            Text(formatDate(bloodData.timestamp))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.virgilTextSecondary)
                        }

                        HStack {
                            Text("検査項目")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.virgilTextPrimary)
                            Spacer()
                            Text("\(bloodData.bloodItems.count)項目")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.virgilTextSecondary)
                        }

                        HStack {
                            Text("サマリー")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.virgilTextPrimary)
                            Spacer()
                            HStack(spacing: VirgilSpacing.md) {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "00C853"))
                                        .font(.caption)
                                    Text("\(bloodTestService.normalItems.count)")
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.virgilTextPrimary)
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Color(hex: "ED1C24"))
                                        .font(.caption)
                                    Text("\(bloodTestService.abnormalItems.count)")
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.virgilTextPrimary)
                                }
                            }
                        }
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // 検査結果セクションタイトル
                HStack {
                    Text("検査結果 (\(filteredBloodItems(bloodData.bloodItems).count)件)")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                }
                .padding(.horizontal, VirgilSpacing.md)

                // 検査項目カード一覧
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
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: BloodTestDetailView(bloodItem: item)) {
                            BloodItemCard(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.md)
            .padding(.bottom, 100)
        }
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

        return filtered
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

    // 絵文字マッピング
    var emoji: String {
        let key = item.key.lowercased()
        switch key {
        // 血糖・代謝系
        case "hba1c", "hemoglobin_a1c": return "🍬"
        case "glucose", "glu", "blood_sugar": return "🩸"
        case "ga", "glycoalbumin": return "🍰"
        case "1,5-ag", "1_5_ag": return "🍯"

        // 肝機能系
        case "ast", "got": return "🫘"
        case "alt", "gpt": return "🫘"
        case "ggt", "γ-gtp", "gamma_gtp": return "🫁"
        case "alp": return "🦴"
        case "t-bil", "tbil", "total_bilirubin": return "💛"
        case "d-bil", "dbil", "direct_bilirubin": return "💛"

        // 脂質系
        case "tc", "tcho", "total_cholesterol": return "🧈"
        case "tg", "triglyceride": return "🥓"
        case "hdl", "hdl_cholesterol": return "✨"
        case "ldl", "ldl_cholesterol": return "⚠️"
        case "apob", "apo_b": return "🔬"
        case "lp(a)", "lipoprotein_a": return "🧬"

        // タンパク質系
        case "tp", "total_protein": return "🥩"
        case "alb", "albumin": return "🥚"
        case "palb", "prealbumin": return "🥛"

        // 腎機能系
        case "bun", "urea_nitrogen": return "🫘"
        case "cre", "creatinine": return "🫘"
        case "ua", "uric_acid": return "💎"
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
        HStack(spacing: VirgilSpacing.md) {
            // 絵文字 + 項目名
            HStack(spacing: VirgilSpacing.sm) {
                Text(emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.nameJp)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)

                    Text(item.key.uppercased())
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                }
            }

            Spacer()

            // 値 + ステータスバッジ
            VStack(alignment: .trailing, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(item.value)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.virgilTextPrimary)

                    Text(item.unit)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.virgilTextSecondary)
                }

                Text(item.status)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(6)
            }
        }
        .padding(VirgilSpacing.md * 1.1)
        .background(
            LinearGradient(
                colors: gradientColors.map { $0.opacity(0.08) },
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .virgilGlassCard(interactive: true)
    }
}

// MARK: - Preview

struct BloodTestView_Previews: PreviewProvider {
    static var previews: some View {
        BloodTestView()
    }
}
