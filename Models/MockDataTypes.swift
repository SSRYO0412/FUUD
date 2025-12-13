//
//  MockDataTypes.swift
//  FUUD
//
//  モックデータ用の共通型定義
//  TODO: Replace with real API data types when backend integration is complete
//

import Foundation

// MARK: - Mock Data Types

/// 遺伝子データ項目（モック用）
struct MockGeneData {
    let name: String
    let variant: String
    let risk: String
    let description: String
}

/// 血液マーカー項目（モック用）
struct MockBloodMarker {
    let name: String
    let value: String
    let unit: String
    let range: String
    let status: String
}

/// HealthKitデータ項目（モック用）
struct MockHealthKitData {
    let name: String
    let value: String
    let status: String
}

/// AIインサイト項目（モック用）
struct MockAIInsight {
    let icon: String
    let title: String
    let message: String
}

/// バイタル指標項目（モック用）
struct MockVitalIndicator {
    let name: String
    let value: String
    let unit: String
    let status: String
    let color: String
}
