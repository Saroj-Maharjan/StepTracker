//
//  HealthKitManager.swift
//  step-tracker
//
//  Created by saroj maharjan on 18/12/2024.
//

import Foundation
import HealthKit
import Observation

@Observable
@MainActor
final class HealthKitData: Sendable {
    
    // Uncomment to use mock data
//    var stepData: [HealthMetric] = MockData.steps
//    var weightData: [HealthMetric] = MockData.weights
    
    var steps: [HealthMetric] = []
    var weights: [HealthMetric] = []
}

@Observable
final class HealthKitManager: Sendable {
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    /// Fetch last 28 days of step count from HealthKit.
    ///
    /// - Returns: Array of ``HealthMetric``
    func fetchStepCount() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, dayBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: .init(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: DateComponents(day: 1)
        )
        
        do {
            let stepsCounts = try await stepsQuery.result(for: store)
            return stepsCounts.statistics().map {
                    .init(
                        date: $0.startDate,
                        value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Fetch the last 28 days of step count from HealthKit.
    /// - Returns: Array of ``HealthMetric``
    func fetchWeights() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, dayBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: .init(.bodyMass), predicate: queryPredicate)
        let weightQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: interval.end,
            intervalComponents: DateComponents(day: 1)
        )
        
        do {
            let weightStats = try await weightQuery.result(for: store)
            return weightStats.statistics().map {
                .init(
                    date: $0.startDate,
                    value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0
                )
                    
            }
            
        } catch HKError.errorNoData {
            throw STError.noData
        }
        catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(
            type: .init(.stepCount),
            quantity: stepQuantity,
            start: date,
            end: date
        )
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        default:
            break
        }
        
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(
            type: .init(.bodyMass),
            quantity: weightQuantity,
            start: date,
            end: date
        )
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    private func createDateInterval(
        from: Date,
        dayBack: Int
    ) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: from)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -dayBack, to: endDate)!
        return DateInterval(start: startDate, end: endDate)
    }
    
    func generateHealthData() async {
            var mockSample: [HKQuantitySample] = []

            for i in 0..<28 {

                let stepQuantity = HKQuantity(
                    unit: .count(), doubleValue: .random(in: 4000...20000))
                let weightQuantity = HKQuantity(
                    unit: .pound(),
                    doubleValue: .random(
                        in: 160 + Double(i / 3)...165 + Double(i / 3)))

                let startDate = Calendar.current.date(
                    byAdding: .day, value: -i, to: .now)!
                let endDate = Calendar.current.date(
                    byAdding: .day, value: 1, to: startDate)!

                let stepSample = HKQuantitySample(
                    type: .init(.stepCount),
                    quantity: stepQuantity,
                    start: startDate,
                    end: endDate)

                let weightSample = HKQuantitySample(
                    type: .init(.bodyMass),
                    quantity: weightQuantity,
                    start: startDate,
                    end: endDate)

                mockSample.append(stepSample)
                mockSample.append(weightSample)
            }

            try! await store.save(mockSample)
            print("✅ Simulator data added")
        }
    
}
