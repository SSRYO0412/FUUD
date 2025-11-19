//
//  GeneDataView.swift
//  AWStest
//
//  遺伝子データ表示画面
//  MVP: 遺伝子機能を非表示化
//

import SwiftUI

// MVP: 遺伝子データ表示画面を全体コメントアウト
/*
struct GeneDataView: View {
    @StateObject private var geneDataService = GeneDataService.shared
    
    var body: some View {
        NavigationView {
            Group {
                if geneDataService.isLoading {
                    loadingView
                } else if !geneDataService.errorMessage.isEmpty {
                    errorView
                } else if let geneData = geneDataService.geneData {
                    geneDataList(geneData: geneData)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("遺伝子解析結果")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("更新", systemImage: "arrow.clockwise") {
                        Task {
                            await geneDataService.refreshData()
                        }
                    }
                    .disabled(geneDataService.isLoading)
                }
            }
        }
        .task {
            if geneDataService.geneData == nil {
                await geneDataService.fetchGeneData()
            }
        }
        .refreshable {
            await geneDataService.refreshData()
        }
    }
    
    // MARK: - Gene Data List
    
    @ViewBuilder
    private func geneDataList(geneData: GeneDataService.GeneData) -> some View {
        List {
            // 基本情報セクション
            Section {
                HStack {
                    Text("解析日時")
                    Spacer()
                    Text(formatDate(geneData.timestamp ?? "データなし"))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("解析版数")
                    Spacer()
                    Text("v\(geneData.analysisVersion ?? "1.0")")
                        .foregroundStyle(.secondary)
                }
                if let userId = geneData.userId {
                    HStack {
                        Text("ユーザーID")
                        Spacer()
                        Text(userId)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("基本情報", systemImage: "info.circle")
            }
            
            // 遺伝子解析結果セクション
            Section {
                HStack {
                    Image(systemName: "drop.circle.fill")
                        .foregroundStyle(.blue)
                        .imageScale(.medium)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("糖尿病リスク")
                            .font(.body)
                        Text(geneData.displayDiabetesRisk)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 2)
                
                HStack {
                    Image(systemName: "heart.circle.fill")
                        .foregroundStyle(.red)
                        .imageScale(.medium)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("高血圧リスク")
                            .font(.body)
                        Text(geneData.displayHypertensionRisk)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 2)
                
                HStack {
                    Image(systemName: "wineglass.fill")
                        .foregroundStyle(.purple)
                        .imageScale(.medium)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("アルコール代謝")
                            .font(.body)
                        Text(geneData.displayAlcoholMetabolism)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 2)
            } header: {
                Label("解析結果", systemImage: "dna")
            }
            
            // 推奨事項セクション
            recommendationsListSection(recommendations: geneData.displayRecommendations)
            
            // 詳細データセクション
            debugDataSection(geneData: geneData)
        }
        .listStyle(.insetGrouped)
    }
    
    
    // MARK: - Recommendations List Section
    
    @ViewBuilder
    private func recommendationsListSection(recommendations: [String]) -> some View {
        Section {
            if recommendations.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text("推奨事項データが取得されていません")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(
                                Circle()
                                    .fill(.blue)
                            )
                        
                        Text(recommendation)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                }
            }
        } header: {
            Label("推奨事項 (\(recommendations.count)件)", systemImage: "lightbulb")
        }
    }
    
    // MARK: - Debug Data Section
    
    @ViewBuilder
    private func debugDataSection(geneData: GeneDataService.GeneData) -> some View {
        Section {
            DisclosureGroup {
                ScrollView {
                    Text(formatGeneDataAsJSON(geneData))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)
            } label: {
                Label("パースされたデータ", systemImage: "curlybraces")
            }
            
            DisclosureGroup {
                ScrollView {
                    Text(geneDataService.rawResponseData.isEmpty ? "データなし" : geneDataService.rawResponseData)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)
            } label: {
                Label("生レスポンス", systemImage: "doc.text")
            }
        } header: {
            Label("開発者情報", systemImage: "hammer")
        }
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text("遺伝子データを解析中...")
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
            description: geneDataService.errorMessage
        ) {
            Button("再試行") {
                Task {
                    await geneDataService.refreshData()
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
            "遺伝子データがありません",
            systemImage: "dna",
            description: "遺伝子データをアップロードして解析を開始してください"
        ) {
            Button("データを取得") {
                Task {
                    await geneDataService.fetchGeneData()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func formatDate(_ timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }
        
        return timestamp
    }
    
    private func formatGeneDataAsJSON(_ geneData: GeneDataService.GeneData) -> String {
        let jsonData: [String: Any?] = [
            "userId": geneData.userId,
            "timestamp": geneData.timestamp,
            "diabetesRiskCategory": geneData.diabetesRiskCategory,
            "hypertensionRiskCategory": geneData.hypertensionRiskCategory,
            "alcoholMetabolismCategory": geneData.alcoholMetabolismCategory,
            "recommendations": geneData.recommendations,
            "analysisVersion": geneData.analysisVersion
        ]
        
        var result = "{\n"
        for (key, value) in jsonData {
            let formattedValue: String
            if let value = value {
                if let stringArray = value as? [String] {
                    let arrayItems = stringArray.map { "\"\($0)\"" }.joined(separator: ", ")
                    formattedValue = "[\(arrayItems)]"
                } else if let stringValue = value as? String {
                    formattedValue = "\"\(stringValue)\""
                } else {
                    formattedValue = "\(value)"
                }
            } else {
                formattedValue = "null"
            }
            result += "  \"\(key)\": \(formattedValue),\n"
        }
        
        if result.hasSuffix(",\n") {
            result = String(result.dropLast(2)) + "\n"
        }
        result += "}"
        
        return result
    }
}

// MARK: - Preview

struct GeneDataView_Previews: PreviewProvider {
    static var previews: some View {
        GeneDataView()
    }
}
*/