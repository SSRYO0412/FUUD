//
//  HealthKitBridge.swift
//  TUUN
//
//  Created by Claude Code on 2025-11-20.
//  スコアリングエンジン: HealthKitデータ変換
//

import Foundation

/// HealthKitデータをスコアリング用の値に変換
struct HealthKitBridge {

    // MARK: - Main Conversion Function

    /// HealthKitDataを[metricId: value]マップに変換
    ///
    /// - Parameter healthKitData: HealthKitService から取得したデータ
    /// - Returns: メトリックIDと値のマップ
    static func convertToMetricValues(from healthKitData: HealthKitData?) -> [String: Double] {
        guard let data = healthKitData else {
            print("⚠️ HealthKitData is nil")
            return [:]
        }

        var values: [String: Double] = [:]

        // 体組成 → BMI計算
        if let bmi = calculateBMI(height: data.height, bodyMass: data.bodyMass) {
            values["bmi"] = bmi
        }

        // 心臓・循環器
        if let hrv = data.heartRateVariability {
            values["hrv"] = hrv
        }
        if let rhr = data.restingHeartRate {
            values["rhr"] = rhr
        }
        if let vo2max = data.vo2Max {
            values["vo2max"] = vo2max
        }

        // 活動量
        if let dailySteps = calculateDailyAverage(data.stepCount) {
            values["dailySteps"] = dailySteps
        }
        if let activeCalories = calculateDailyAverage(data.activeEnergyBurned) {
            values["activeCalories"] = activeCalories
        }

        // 睡眠
        if let sleepHours = calculateAverageSleepHours(from: data.sleepData) {
            values["sleepHours"] = sleepHours
        }

        return values
    }

    // MARK: - BMI Calculation

    /// BMIを計算
    ///
    /// - Parameters:
    ///   - height: 身長 (cm)
    ///   - bodyMass: 体重 (kg)
    /// - Returns: BMI (kg/m²)
    static func calculateBMI(height: Double?, bodyMass: Double?) -> Double? {
        guard let height = height, let bodyMass = bodyMass else {
            return nil
        }

        // 身長をメートルに変換
        let heightInMeters = height / 100.0

        guard heightInMeters > 0 else {
            return nil
        }

        // BMI = 体重(kg) / 身長(m)²
        let bmi = bodyMass / (heightInMeters * heightInMeters)
        return bmi
    }

    // MARK: - Daily Averages

    /// 日次平均を計算 (シンプル版: 値をそのまま返す)
    ///
    /// HealthKitServiceが既に最新の値を返している想定
    /// 将来的に複数日の平均を取る場合はここを拡張
    ///
    /// - Parameter value: HealthKitから取得した値
    /// - Returns: 日次平均値
    static func calculateDailyAverage(_ value: Double?) -> Double? {
        return value
    }

    // MARK: - Sleep Hours Calculation

    /// 平均睡眠時間を計算
    ///
    /// - Parameter sleepData: 睡眠サンプルの配列
    /// - Returns: 平均睡眠時間 (時間単位)
    static func calculateAverageSleepHours(from sleepData: [SleepSample]?) -> Double? {
        guard let sleepData = sleepData, !sleepData.isEmpty else {
            return nil
        }

        // 各睡眠サンプルの時間を合計
        var totalSeconds: TimeInterval = 0.0
        var validSampleCount = 0

        for sample in sleepData {
            // "睡眠中"のサンプルのみカウント (inBedやawakeは除外)
            // カテゴリー: inBed, asleep, awake, core, deep, REM
            switch sample.value {
            case .asleep, .core, .deep, .rem:
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                totalSeconds += duration
                validSampleCount += 1
            case .inBed, .awake:
                // カウントしない
                break
            }
        }

        guard validSampleCount > 0 else {
            return nil
        }

        // 秒を時間に変換
        let averageSleepHours = totalSeconds / 3600.0

        return averageSleepHours
    }

    // MARK: - Debug Helper

    /// HealthKit変換結果をデバッグ出力
    static func printConversionSummary(_ values: [String: Double]) {
        print("📊 HealthKit Conversion Summary:")
        print("================================")

        if values.isEmpty {
            print("⚠️ No HealthKit values converted")
            return
        }

        // ソートして見やすく表示
        let sortedKeys = values.keys.sorted()
        for key in sortedKeys {
            if let value = values[key] {
                print("  \(key): \(String(format: "%.2f", value))")
            }
        }

        print("================================")
    }
}
