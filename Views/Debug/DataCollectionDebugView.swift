//
//  DataCollectionDebugView.swift
//  TUUN
//
//  Created by Claude on 2025/12/01.
//  TUUNING Intelligence用データ収集デバッグビュー
//  AIに送信するデータを確認するためのUI
//

import SwiftUI

struct DataCollectionDebugView: View {
    @StateObject private var intelligenceService = TuuningIntelligenceService.shared
    @State private var isLoading = false
    @State private var jsonOutput = ""
    @State private var showCopiedToast = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection

                    // Time Slot Info
                    timeSlotSection

                    // Blood Data Section
                    bloodDataSection

                    // HealthKit Data Section
                    vitalDataSection

                    // Gene Data Section
                    geneDataSection

                    // JSON Preview Section
                    jsonPreviewSection
                }
                .padding()
            }
            .navigationTitle("Data Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("更新") {
                        refreshData()
                    }
                }
            }
        }
        .onAppear {
            refreshData()
        }
        .overlay(
            copiedToast
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TUUNING Intelligence データ確認")
                .font(.headline)

            Text("AIに送信する25項目のデータを確認できます")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Time Slot Section

    private var timeSlotSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在の時間帯")
                .font(.subheadline)
                .fontWeight(.semibold)

            let timeSlot = TimeSlot.current()
            HStack {
                Text(timeSlot.title)
                    .font(.body)
                Spacer()
                Text(timeSlot.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }

    // MARK: - Blood Data Section

    private var bloodDataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("血液データ (10項目)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                statusBadge(hasData: intelligenceService.debugData?.bloodData != nil)
            }

            if let blood = intelligenceService.debugData?.bloodData {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    dataRow("HbA1c", blood.hbA1c, "%")
                    dataRow("FPG", blood.fpg, "mg/dL")
                    dataRow("TG", blood.tg, "mg/dL")
                    dataRow("HDL", blood.hdl, "mg/dL")
                    dataRow("LDL", blood.ldl, "mg/dL")
                    dataRow("CRP", blood.crp, "mg/dL")
                    dataRow("Ferritin", blood.ferritin, "ng/mL")
                    dataRow("AST", blood.ast, "U/L")
                    dataRow("UA", blood.ua, "mg/dL")
                    dataRow("INS", blood.ins, "μU/mL")
                }
            } else {
                noDataView()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    // MARK: - Vital Data Section

    private var vitalDataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("HealthKitデータ (10項目)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                statusBadge(hasData: intelligenceService.debugData?.vitalData != nil)
            }

            if let vital = intelligenceService.debugData?.vitalData {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    dataRow("HRV", vital.hrv, "ms")
                    dataRow("RHR", vital.restingHeartRate, "bpm")
                    dataRow("VO2Max", vital.vo2Max, "ml/kg/min")
                    dataRow("睡眠", vital.sleepTotal, "h")
                    dataRow("深い睡眠", vital.sleepDeep, "h")
                    dataRow("REM", vital.sleepRem, "h")
                    dataRow("歩数", vital.stepCount, "歩")
                    dataRow("Cal", vital.activeEnergyBurned, "kcal")
                    dataRowString("運動", vital.recentWorkout)
                    dataRow("体重", vital.bodyMass, "kg")
                }
            } else {
                noDataView()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    // MARK: - Gene Data Section

    private var geneDataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("遺伝子データ (5項目)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                statusBadge(hasData: intelligenceService.debugData?.geneData != nil)
            }

            if let gene = intelligenceService.debugData?.geneData {
                VStack(spacing: 8) {
                    geneRow("カフェイン代謝", gene.caffeine)
                    geneRow("概日リズム", gene.circadianRhythm)
                    geneRow("高脂肪ダイエット", gene.highFatDiet)
                    geneRow("高たんぱくダイエット", gene.highProteinDiet)
                    geneRow("眠りの深さ", gene.sleepDepth)
                }
            } else {
                noDataView()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    // MARK: - JSON Preview Section

    private var jsonPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("JSON プレビュー")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: copyJSON) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("コピー")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            ScrollView(.horizontal, showsIndicators: true) {
                Text(jsonOutput)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(8)
            }
            .frame(maxHeight: 300)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    // MARK: - Helper Views

    private func dataRow(_ label: String, _ value: Double?, _ unit: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if let v = value {
                Text("\(String(format: "%.1f", v)) \(unit)")
                    .font(.caption)
                    .fontWeight(.medium)
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(4)
    }

    private func dataRowString(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value ?? "-")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(4)
    }

    private func geneRow(_ label: String, _ result: GeneMarkerResult?) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if let r = result {
                HStack(spacing: 8) {
                    Text(r.scoreLevel)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("(\(r.score > 0 ? "+" : "")\(r.score))")
                        .font(.caption2)
                        .foregroundColor(r.score >= 0 ? .green : .red)
                }
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(4)
    }

    private func statusBadge(hasData: Bool) -> some View {
        Text(hasData ? "OK" : "なし")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(hasData ? .green : .orange)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background((hasData ? Color.green : Color.orange).opacity(0.1))
            .cornerRadius(4)
    }

    private func noDataView() -> some View {
        Text("データがありません")
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(4)
    }

    private var copiedToast: some View {
        Group {
            if showCopiedToast {
                VStack {
                    Spacer()
                    Text("JSONをコピーしました")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 50)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Actions

    private func refreshData() {
        isLoading = true
        Task {
            _ = await intelligenceService.collectUserData()

            // debugDataを手動で設定（collectUserDataの結果を反映）
            let data = await intelligenceService.collectUserData()
            await MainActor.run {
                intelligenceService.debugData = IntelligenceDebugData(
                    bloodData: data.blood,
                    vitalData: data.vital,
                    geneData: data.gene,
                    timeSlot: TimeSlot.current().rawValue,
                    timestamp: Date()
                )
                jsonOutput = intelligenceService.debugData?.toJSON() ?? "{}"
                isLoading = false
            }
        }
    }

    private func copyJSON() {
        UIPasteboard.general.string = jsonOutput
        withAnimation {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataCollectionDebugView_Previews: PreviewProvider {
    static var previews: some View {
        DataCollectionDebugView()
    }
}
#endif
