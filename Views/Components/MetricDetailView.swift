//
//  MetricDetailView.swift
//  AWStest
//
//  パフォーマンスメトリクス詳細表示
//

import SwiftUI

struct MetricDetailView: View {
    let metric: String
    let data: [String: String] // [DUMMY] 詳細データはPerformanceDetailData.sampleから取得
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("\(metricDisplayName.uppercased()) DETAILS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)
                    

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                        .frame(width: 20, height: 20)
                        .background(Color.white.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 4)

            Divider()
                .background(Color.white.opacity(0.2))

            // データ行
            VStack(spacing: 8) {
                ForEach(sortedData, id: \.key) { item in
                    DetailRow(label: item.key, value: item.value)
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.02))
        .cornerRadius(12)
    }

    private var metricDisplayName: String {
        switch metric {
        case "recovery":
            return "Recovery"
        case "metabolic":
            return "Metabolic"
        case "inflammation":
            return "Inflammation"
        case "longevity":
            return "Longevity"
        case "performance":
            return "Performance"
        default:
            return metric.capitalized
        }
    }

    private var sortedData: [(key: String, value: String)] {
        data.sorted { $0.key < $1.key }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.virgilTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.virgilTextPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.3))
        .cornerRadius(6)
    }
}

#if DEBUG
struct MetricDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MetricDetailView(
            metric: "recovery",
            data: [
                "HRV (RMSSD)": "68ms ↑",
                "安静時心拍": "52bpm ↓",
                "深睡眠": "22% ↑",
                "前日負荷": "中強度"
            ],
            onClose: {}
        )
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
}
#endif
