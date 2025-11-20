//
//  HealthKitService.swift
//  TUUN
//
//  HealthKit連携サービス
//

import Foundation
import HealthKit

/// HealthKitデータ取得サービス
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    // MARK: - Published Properties
    @Published var healthData: HealthKitData?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined

    private let healthStore = HKHealthStore()

    private init() {}

    // MARK: - HealthKit Types to Read

    /// 読み取りを要求するHealthKitデータタイプ
    private var typesToRead: Set<HKObjectType> {
        var types = Set<HKObjectType>()

        // 体組成系 (4種類)
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(bodyMass)
        }
        if let height = HKObjectType.quantityType(forIdentifier: .height) {
            types.insert(height)
        }
        if let bodyFatPercentage = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage) {
            types.insert(bodyFatPercentage)
        }
        if let leanBodyMass = HKObjectType.quantityType(forIdentifier: .leanBodyMass) {
            types.insert(leanBodyMass)
        }

        // 心臓・循環器系 (4種類)
        if let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(restingHeartRate)
        }
        if let vo2Max = HKObjectType.quantityType(forIdentifier: .vo2Max) {
            types.insert(vo2Max)
        }
        if let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(heartRateVariability)
        }
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }

        // 活動量系 (3種類)
        if let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergyBurned)
        }
        if let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(exerciseTime)
        }
        if let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }

        // 移動距離系 (2種類)
        if let walkingRunningDistance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            types.insert(walkingRunningDistance)
        }
        if let cyclingDistance = HKObjectType.quantityType(forIdentifier: .distanceCycling) {
            types.insert(cyclingDistance)
        }

        // 睡眠分析
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }

        // ワークアウト
        types.insert(HKObjectType.workoutType())

        return types
    }

    // MARK: - Authorization

    /// HealthKitの利用可能性をチェック
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// HealthKitの認証をリクエスト
    func requestAuthorization() async throws {
        guard isHealthKitAvailable() else {
            throw HealthKitError.notAvailable
        }

        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

            await MainActor.run {
                self.authorizationStatus = .authorized
                self.isLoading = false
            }

            print("✅ HealthKit authorization granted")

        } catch {
            await MainActor.run {
                self.authorizationStatus = .denied
                self.errorMessage = "HealthKitの認証に失敗しました"
                self.isLoading = false
            }
            throw HealthKitError.authorizationFailed
        }
    }

    // MARK: - Data Fetching

    /// すべてのHealthKitデータを取得
    func fetchAllHealthData() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }

        var newHealthData = HealthKitData()

        // 各カテゴリのデータを並行取得
        async let bodyMetrics = fetchBodyMetrics()
        async let cardiacMetrics = fetchCardiacMetrics()
        async let activityMetrics = fetchActivityMetrics()
        async let distanceMetrics = fetchDistanceMetrics()
        async let sleepData = fetchSleepData()
        async let workouts = fetchWorkouts()

        let (body, cardiac, activity, distance, sleep, workout) = await (
            bodyMetrics, cardiacMetrics, activityMetrics,
            distanceMetrics, sleepData, workouts
        )

        // データをマージ
        newHealthData.bodyMass = body.bodyMass
        newHealthData.height = body.height
        newHealthData.bodyFatPercentage = body.bodyFatPercentage
        newHealthData.leanBodyMass = body.leanBodyMass

        newHealthData.restingHeartRate = cardiac.restingHeartRate
        newHealthData.vo2Max = cardiac.vo2Max
        newHealthData.heartRateVariability = cardiac.heartRateVariability
        newHealthData.heartRate = cardiac.heartRate

        newHealthData.activeEnergyBurned = activity.activeEnergyBurned
        newHealthData.exerciseTime = activity.exerciseTime
        newHealthData.stepCount = activity.stepCount

        newHealthData.walkingRunningDistance = distance.walkingRunningDistance
        newHealthData.cyclingDistance = distance.cyclingDistance

        newHealthData.sleepData = sleep
        newHealthData.workouts = workout

        newHealthData.lastUpdated = Date()

        await MainActor.run {
            self.healthData = newHealthData
            self.isLoading = false
            print("✅ HealthKit data fetched successfully")
            self.printHealthDataSummary()
        }
    }

    /// 体組成系データを取得 (4種類)
    private func fetchBodyMetrics() async -> (bodyMass: Double?, height: Double?, bodyFatPercentage: Double?, leanBodyMass: Double?) {
        async let bodyMass = fetchMostRecentQuantitySample(for: .bodyMass, unit: .gramUnit(with: .kilo))
        async let height = fetchMostRecentQuantitySample(for: .height, unit: .meterUnit(with: .centi))
        async let bodyFat = fetchMostRecentQuantitySample(for: .bodyFatPercentage, unit: .percent())
        async let leanMass = fetchMostRecentQuantitySample(for: .leanBodyMass, unit: .gramUnit(with: .kilo))

        return await (bodyMass, height, bodyFat, leanMass)
    }

    /// 心臓・循環器系データを取得 (4種類)
    private func fetchCardiacMetrics() async -> (restingHeartRate: Double?, vo2Max: Double?, heartRateVariability: Double?, heartRate: Double?) {
        async let restingHR = fetchMostRecentQuantitySample(for: .restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
        async let vo2 = fetchMostRecentQuantitySample(for: .vo2Max, unit: HKUnit.literUnit(with: .milli).unitDivided(by: .gramUnit(with: .kilo).unitMultiplied(by: .minute())))
        async let hrv = fetchMostRecentQuantitySample(for: .heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
        async let hr = fetchMostRecentQuantitySample(for: .heartRate, unit: HKUnit.count().unitDivided(by: .minute()))

        return await (restingHR, vo2, hrv, hr)
    }

    /// 活動量系データを取得 (3種類)
    private func fetchActivityMetrics() async -> (activeEnergyBurned: Double?, exerciseTime: Double?, stepCount: Double?) {
        async let activeEnergy = fetchMostRecentQuantitySample(for: .activeEnergyBurned, unit: .kilocalorie())
        async let exercise = fetchMostRecentQuantitySample(for: .appleExerciseTime, unit: .minute())
        async let steps = fetchMostRecentQuantitySample(for: .stepCount, unit: .count())

        return await (activeEnergy, exercise, steps)
    }

    /// 移動距離系データを取得 (2種類)
    private func fetchDistanceMetrics() async -> (walkingRunningDistance: Double?, cyclingDistance: Double?) {
        async let walkRun = fetchMostRecentQuantitySample(for: .distanceWalkingRunning, unit: .meterUnit(with: .kilo))
        async let cycling = fetchMostRecentQuantitySample(for: .distanceCycling, unit: .meterUnit(with: .kilo))

        return await (walkRun, cycling)
    }

    /// 最新の数値サンプルを取得
    private func fetchMostRecentQuantitySample(for identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: quantityType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            // クエリ結果の処理はコールバック内で行われる
        }

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("❌ Error fetching \(identifier.rawValue): \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    /// 睡眠データを取得
    private func fetchSleepData() async -> [SleepSample]? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        // 過去7日間の睡眠データを取得
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("❌ Error fetching sleep data: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }

                guard let categorySamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }

                let sleepSamples = categorySamples.compactMap { sample -> SleepSample? in
                    guard let category = SleepSample.SleepCategory(rawValue: sample.value) else {
                        return nil
                    }
                    return SleepSample(
                        startDate: sample.startDate,
                        endDate: sample.endDate,
                        value: category
                    )
                }

                continuation.resume(returning: sleepSamples.isEmpty ? nil : sleepSamples)
            }

            healthStore.execute(query)
        }
    }

    /// ワークアウトデータを取得
    private func fetchWorkouts() async -> [WorkoutSample]? {
        let workoutType = HKObjectType.workoutType()

        // 過去30日間のワークアウトを取得
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("❌ Error fetching workouts: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: nil)
                    return
                }

                let workoutSamples = workouts.compactMap { workout -> WorkoutSample? in
                    let workoutType = self.convertToWorkoutType(workout.workoutActivityType)

                    let energyBurned = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie())
                    let distance = workout.totalDistance?.doubleValue(for: .meter())

                    return WorkoutSample(
                        workoutType: workoutType,
                        startDate: workout.startDate,
                        endDate: workout.endDate,
                        totalEnergyBurned: energyBurned,
                        totalDistance: distance,
                        metadata: workout.metadata as? [String: String]
                    )
                }

                continuation.resume(returning: workoutSamples.isEmpty ? nil : workoutSamples)
            }

            healthStore.execute(query)
        }
    }

    /// HKWorkoutActivityTypeをWorkoutTypeに変換
    private func convertToWorkoutType(_ activityType: HKWorkoutActivityType) -> WorkoutSample.WorkoutType {
        switch activityType {
        case .running:
            return .running
        case .cycling:
            return .cycling
        case .walking:
            return .walking
        case .swimming:
            return .swimming
        case .yoga:
            return .yoga
        case .traditionalStrengthTraining, .functionalStrengthTraining:
            return .strengthTraining
        default:
            return .other
        }
    }

    // MARK: - Utility Methods

    /// データをリフレッシュ
    func refreshData() async {
        await MainActor.run {
            self.healthData = nil
            self.errorMessage = ""
        }
        await fetchAllHealthData()
    }

    /// 取得したデータのサマリーを出力
    private func printHealthDataSummary() {
        guard let data = healthData else {
            print("📊 No HealthKit data available")
            return
        }

        print("📊 HealthKit Data Summary:")
        print("  体組成系:")
        print("    - 体重: \(data.bodyMass.map { String(format: "%.1f kg", $0) } ?? "N/A")")
        print("    - 身長: \(data.height.map { String(format: "%.1f cm", $0) } ?? "N/A")")
        print("    - 体脂肪率: \(data.bodyFatPercentage.map { String(format: "%.1f %%", $0 * 100) } ?? "N/A")")
        print("    - 除脂肪体重: \(data.leanBodyMass.map { String(format: "%.1f kg", $0) } ?? "N/A")")

        print("  心臓・循環器系:")
        print("    - 安静時心拍数: \(data.restingHeartRate.map { String(format: "%.0f bpm", $0) } ?? "N/A")")
        print("    - VO2Max: \(data.vo2Max.map { String(format: "%.1f ml/kg/min", $0) } ?? "N/A")")
        print("    - 心拍変動: \(data.heartRateVariability.map { String(format: "%.0f ms", $0) } ?? "N/A")")
        print("    - 心拍数: \(data.heartRate.map { String(format: "%.0f bpm", $0) } ?? "N/A")")

        print("  活動量系:")
        print("    - アクティブカロリー: \(data.activeEnergyBurned.map { String(format: "%.0f kcal", $0) } ?? "N/A")")
        print("    - エクササイズ時間: \(data.exerciseTime.map { String(format: "%.0f 分", $0) } ?? "N/A")")
        print("    - 歩数: \(data.stepCount.map { String(format: "%.0f steps", $0) } ?? "N/A")")

        print("  移動距離系:")
        print("    - 歩行・ランニング距離: \(data.walkingRunningDistance.map { String(format: "%.2f km", $0) } ?? "N/A")")
        print("    - サイクリング距離: \(data.cyclingDistance.map { String(format: "%.2f km", $0) } ?? "N/A")")

        print("  睡眠: \(data.sleepData?.count ?? 0) samples")
        print("  ワークアウト: \(data.workouts?.count ?? 0) workouts")
        print("  最終更新: \(data.lastUpdated)")
    }
}

// MARK: - Error Types

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed
    case dataFetchFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスで利用できません"
        case .authorizationFailed:
            return "HealthKitの認証に失敗しました"
        case .dataFetchFailed:
            return "HealthKitデータの取得に失敗しました"
        }
    }
}
