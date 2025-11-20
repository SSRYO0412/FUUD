//
//  DemoModeManager.swift
//  AWStest
//
//  デモモード管理（シングルトン）
//

import Foundation
import Combine

class DemoModeManager: ObservableObject {
    static let shared = DemoModeManager()

    @Published var isDemoMode: Bool {
        didSet {
            UserDefaults.standard.set(isDemoMode, forKey: "isDemoMode")
        }
    }

    private init() {
        self.isDemoMode = UserDefaults.standard.bool(forKey: "isDemoMode")
    }

    // MARK: - Demo Chart Data Generation

    /// デモ用のチャートデータを生成（代謝力用）
    /// 70-80の範囲で緩やかに上昇する7日分のデータ
    static func createDemoMetabolicChartData() -> [Double] {
        return [70, 72, 74, 75, 76, 78, 80]
    }

    /// デモ用のチャートデータを生成（炎症レベル用）
    /// 55-65の範囲で緩やかに変動する7日分のデータ
    static func createDemoInflammationChartData() -> [Double] {
        return [65, 63, 60, 58, 57, 56, 55]
    }

    /// デモ用のチャートデータを生成（回復スピード用）
    /// 60-75の範囲で上下する7日分のデータ
    static func createDemoRecoveryChartData() -> [Double] {
        return [60, 65, 68, 70, 72, 73, 75]
    }

    /// デモ用のチャートデータを生成（老化速度用）
    /// 65-75の範囲で緩やかに改善する7日分のデータ
    static func createDemoAgingChartData() -> [Double] {
        return [65, 67, 68, 70, 71, 73, 75]
    }
}
