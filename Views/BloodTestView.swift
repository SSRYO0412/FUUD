//
//  BloodTestView.swift
//  AWStest
//
//  血液検査データ表示画面
//

import SwiftUI

struct BloodTestView: View {
    @StateObject private var bloodTestService = BloodTestService.shared
    @State private var showingAbnormalOnly = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            Group {
                if bloodTestService.isLoading {
                    loadingView
                } else if !bloodTestService.errorMessage.isEmpty {
                    errorView
                } else if let bloodData = bloodTestService.bloodData {
                    bloodTestList(bloodData: bloodData)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("血液検査結果")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("更新", systemImage: "arrow.clockwise") {
                        Task {
                            await bloodTestService.refreshData()
                        }
                    }
                    .disabled(bloodTestService.isLoading)
                }
            }
            .searchable(text: $searchText, prompt: "検査項目を検索")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("フィルター", systemImage: "line.3.horizontal.decrease.circle") {
                        Button {
                            showingAbnormalOnly.toggle()
                        } label: {
                            Label(
                                showingAbnormalOnly ? "すべて表示" : "異常値のみ表示",
                                systemImage: showingAbnormalOnly ? "eye" : "exclamationmark.triangle"
                            )
                        }
                    }
                }
            }
        }
        .task {
            if bloodTestService.bloodData == nil {
                await bloodTestService.fetchBloodTestData()
            }
        }
        .refreshable {
            await bloodTestService.refreshData()
        }
    }
    
    // MARK: - Blood Test List
    
    @ViewBuilder
    private func bloodTestList(bloodData: BloodTestService.BloodTestData) -> some View {
        List {
            // 基本情報セクション
            Section {
                HStack {
                    Text("検査日時")
                    Spacer()
                    Text(formatDate(bloodData.timestamp))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("検査項目")
                    Spacer()
                    Text("\(bloodData.bloodItems.count)項目")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("サマリー")
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                            Text("\(bloodTestService.normalItems.count)")
                                .font(.caption.monospacedDigit())
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                            Text("\(bloodTestService.abnormalItems.count)")
                                .font(.caption.monospacedDigit())
                        }
                    }
                }
            } header: {
                Label("基本情報", systemImage: "info.circle")
            }
            
            // 血液検査項目セクション
            Section {
                let filteredItems = filteredBloodItems(bloodData.bloodItems)
                
                if filteredItems.isEmpty {
                    ContentUnavailableViewCompat(
                        "該当する項目がありません",
                        systemImage: "magnifyingglass",
                        description: showingAbnormalOnly ? "異常値の項目が見つかりません" : "検索条件に一致する項目がありません"
                    )
                } else {
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: BloodTestDetailView(bloodItem: item)) {
                            BloodItemListRow(item: item)
                        }
                    }
                }
            } header: {
                Label("検査結果 (\(filteredBloodItems(bloodData.bloodItems).count)件)", systemImage: "heart.text.square")
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text("血液検査データを取得中...")
                .foregroundStyle(.secondary)
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
    
    // MARK: - Blood Items List
    
    @ViewBuilder
    private func bloodItemsList(bloodData: BloodTestService.BloodTestData) -> some View {
        let filteredItems = filteredBloodItems(bloodData.bloodItems)
        
        if filteredItems.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("条件に一致する項目がありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(filteredItems) { item in
                NavigationLink(destination: BloodTestDetailView(bloodItem: item)) {
                    BloodItemRow(item: item)
                }
            }
            .listStyle(PlainListStyle())
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

// MARK: - Blood Item Row

struct BloodItemRow: View {
    let item: BloodTestService.BloodItem
    
    var body: some View {
        HStack(spacing: 12) {
            // ステータスアイコン
            Image(systemName: item.statusIcon)
                .font(.system(size: 20))
                .foregroundColor(colorForStatus(item.statusColor))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                // 項目名
                Text(item.nameJp)
                    .font(.headline)
                    .fontWeight(.medium)
                
                // 基準値
                Text("基準値: \(item.reference)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // 値と単位
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(item.value)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(colorForStatus(item.statusColor))
                    
                    Text(item.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // ステータス
                Text(item.status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(colorForStatus(item.statusColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(colorForStatus(item.statusColor).opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 8)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "green":
            return .green
        case "orange":
            return .orange
        case "red":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Preview

// MARK: - Blood Item List Row

struct BloodItemListRow: View {
    let item: BloodTestService.BloodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 項目名
                Text(item.nameJp)
                    .font(.body.weight(.medium))
                
                Spacer()
                
                // 値と単位
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(item.value)
                        .font(.body.monospacedDigit().weight(.semibold))
                        .foregroundStyle(colorForStatus(item.statusColor))
                    
                    Text(item.unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                // 基準値
                Text("基準値: \(item.reference)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // ステータス
                HStack(spacing: 4) {
                    Image(systemName: item.statusIcon)
                        .font(.caption)
                        .foregroundStyle(colorForStatus(item.statusColor))
                    
                    Text(item.status)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(colorForStatus(item.statusColor))
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "green":
            return .green
        case "orange":
            return .orange
        case "red":
            return .red
        default:
            return .gray
        }
    }
}

struct BloodTestView_Previews: PreviewProvider {
    static var previews: some View {
        BloodTestView()
    }
}