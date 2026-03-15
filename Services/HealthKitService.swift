//
//  HealthKitService.swift
//  SkateAp
//
//  Created by Lorran on 13/03/26.
//

import Combine
import HealthKit
import Foundation

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var todayActiveCalories: Double = 0
    @Published var todaySteps: Int = 0
    @Published var todayExerciseMinutes: Int = 0
    @Published var weeklyCalories: [Double] = Array(repeating: 0, count: 7)
    
    // Types we want to read
    private let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []
        if let calories = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { types.insert(calories) }
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { types.insert(steps) }
        if let exercise = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) { types.insert(exercise) }
        if let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) { types.insert(distance) }
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) { types.insert(heartRate) }
        return types
    }()
    
    // Types we want to write
    private let writeTypes: Set<HKSampleType> = {
        var types: Set<HKSampleType> = []
        if let workout = HKObjectType.workoutType() as? HKSampleType { types.insert(workout) }
        if let calories = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { types.insert(calories) }
        if let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) { types.insert(distance) }
        return types
    }()
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            await MainActor.run { isAuthorized = true }
            await fetchTodayData()
            return true
        } catch {
            print("HealthKit auth error: \(error)")
            return false
        }
    }
    
    // MARK: - Fetch Today's Data
    func fetchTodayData() async {
        async let calories = fetchTodayCalories()
        async let steps = fetchTodaySteps()
        async let exercise = fetchTodayExerciseMinutes()
        async let weekly = fetchWeeklyCalories()
        
        let (cal, stp, exc, wkl) = await (calories, steps, exercise, weekly)
        
        await MainActor.run {
            todayActiveCalories = cal
            todaySteps = stp
            todayExerciseMinutes = exc
            weeklyCalories = wkl
        }
    }
    
    private func fetchTodayCalories() async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return 0 }
        return await fetchSumToday(for: type, unit: .kilocalorie())
    }
    
    private func fetchTodaySteps() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        return Int(await fetchSumToday(for: type, unit: .count()))
    }
    
    private func fetchTodayExerciseMinutes() async -> Int {
        guard let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return 0 }
        return Int(await fetchSumToday(for: type, unit: .minute()))
    }
    
    private func fetchSumToday(for type: HKQuantityType, unit: HKUnit) async -> Double {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchWeeklyCalories() async -> [Double] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return Array(repeating: 0, count: 7)
        }
        
        let calendar = Calendar.current
        var results: [Double] = []
        
        for dayOffset in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) ?? Date()
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            
            let value = await withCheckedContinuation { (continuation: CheckedContinuation<Double, Never>) in
                let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                    continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
                }
                healthStore.execute(query)
            }
            results.append(value)
        }
        
        return results
    }
    
    // MARK: - Save Workout
    func saveSkateWorkout(session: TrainingSession) async -> Bool {
        guard isAuthorized else { return false }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .skatingSports
        configuration.locationType = .outdoor
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        do {
            try await builder.beginCollection(at: session.date)
            
            // Add calorie samples
            if let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
               session.calories > 0 {
                let calQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: session.calories)
                let calorieSample = HKQuantitySample(
                    type: calorieType,
                    quantity: calQuantity,
                    start: session.date,
                    end: session.date.addingTimeInterval(session.duration)
                )
                try await builder.addSamples([calorieSample])
            }
            
            // Add distance samples
            if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
               session.distanceKm > 0 {
                let distQuantity = HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: session.distanceKm)
                let distanceSample = HKQuantitySample(
                    type: distanceType,
                    quantity: distQuantity,
                    start: session.date,
                    end: session.date.addingTimeInterval(session.duration)
                )
                try await builder.addSamples([distanceSample])
            }
            
            let endDate = session.date.addingTimeInterval(session.duration)
            try await builder.endCollection(at: endDate)
            try await builder.finishWorkout()
            return true
        } catch {
            print("Failed to save workout: \(error)")
            return false
        }
    }
}
