//
//  ProgressTab.swift
//  FUUD
//
//  DataView内のProgressタブコンテンツ
//  MacroFactor風のセクションを含む
//

import SwiftUI

struct ProgressTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            Text("PROGRESS & ANALYTICS")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            // InsightsAnalyticsSection - 消費エネルギー、体重推移、目標進捗
            InsightsAnalyticsSection()

            // DataHabitsSection - 体重、栄養摂取週間チャート、体組成
            DataHabitsSection()

            // NutrientExplorerSection - 2×2グリッドで栄養素表示
            NutrientExplorerSection()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ProgressTab_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            ScrollView {
                ProgressTab()
                    .padding()
            }
        }
    }
}
#endif
