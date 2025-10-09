//
//  BloodTestDetailView.swift
//  AWStest
//
//  血液検査項目詳細画面
//

import SwiftUI
import Charts

struct BloodTestDetailView: View {
    let bloodItem: BloodTestService.BloodItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダーカード
                headerCard
                
                // 詳細情報カード
                detailCard
                
                // 推奨事項カード
                recommendationsCard
                
                // 履歴グラフカード（将来の実装用）
                historyCard
            }
            .padding()
        }
        .navigationTitle(bloodItem.nameJp)
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header Card
    
    @ViewBuilder
    private var headerCard: some View {
        VStack(spacing: 16) {
            // ステータスアイコンと値
            HStack {
                Image(systemName: bloodItem.statusIcon)
                    .font(.system(size: 40))
                    .foregroundColor(colorForStatus(bloodItem.statusColor))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(bloodItem.value)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(colorForStatus(bloodItem.statusColor))
                        
                        Text(bloodItem.unit)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(bloodItem.status)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(colorForStatus(bloodItem.statusColor))
                }
            }
            
            // 基準値表示
            HStack {
                Text("基準値")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(bloodItem.reference)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Detail Card
    
    @ViewBuilder
    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("詳細情報")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                detailRow(title: "検査項目", value: bloodItem.nameJp)
                detailRow(title: "項目キー", value: bloodItem.key)
                detailRow(title: "測定値", value: "\(bloodItem.value) \(bloodItem.unit)")
                detailRow(title: "判定", value: bloodItem.status)
                detailRow(title: "基準範囲", value: bloodItem.reference)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    @ViewBuilder
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
    
    // MARK: - Recommendations Card
    
    @ViewBuilder
    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("推奨事項")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(getRecommendations(), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                        
                        Text(recommendation)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - History Card
    
    @ViewBuilder
    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("履歴トレンド")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Text("過去の検査結果を表示する機能は今後実装予定です")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // プレースホルダーチャート
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 30))
                                .foregroundColor(.secondary)
                            
                            Text("履歴グラフ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Helper Methods
    
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
    
    private func getRecommendations() -> [String] {
        // 血液検査項目に基づく簡単な推奨事項生成
        let status = bloodItem.status.lowercased()
        let key = bloodItem.key.lowercased()
        
        var recommendations: [String] = []
        
        if ["正常", "normal"].contains(status) {
            recommendations.append("現在の値は正常範囲内です。現在の生活習慣を維持してください。")
            recommendations.append("定期的な健康診断を受けることをお勧めします。")
        } else {
            recommendations.append("値が基準範囲外です。医師に相談することをお勧めします。")
            
            if key.contains("glucose") || key.contains("血糖") {
                recommendations.append("食事のバランスを見直し、適度な運動を心がけてください。")
                recommendations.append("糖質の摂取量に注意してください。")
            } else if key.contains("cholesterol") || key.contains("コレステロール") {
                recommendations.append("飽和脂肪酸の摂取を控え、オメガ3脂肪酸を摂取してください。")
                recommendations.append("定期的な有酸素運動を行ってください。")
            } else if key.contains("pressure") || key.contains("血圧") {
                recommendations.append("塩分摂取量を控えてください。")
                recommendations.append("ストレス管理と十分な睡眠を心がけてください。")
            } else {
                recommendations.append("バランスの取れた食事と適度な運動を心がけてください。")
                recommendations.append("十分な休息とストレス管理を行ってください。")
            }
        }
        
        return recommendations
    }
}

// MARK: - Preview

struct BloodTestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BloodTestDetailView(
                bloodItem: BloodTestService.BloodItem(
                    key: "glucose",
                    nameJp: "血糖値",
                    value: "95",
                    unit: "mg/dL",
                    status: "正常",
                    reference: "70-110"
                ) // [DUMMY] プレビュー用の血液検査項目
            )
        }
    }
}
