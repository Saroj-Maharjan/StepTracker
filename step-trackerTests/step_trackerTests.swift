//
//  step_trackerTests.swift
//  step-trackerTests
//
//  Created by saroj maharjan on 18/12/2024.
//

import Testing
import Foundation
@testable import step_tracker

struct step_trackerTests {
    
    @Test func dateValueAverage() {
        let data: [DateValueChartData] = [
            .init(date: .now, value: 5.1),
            .init(date: .now, value: 10.54),
            .init(date: .now, value: 15.11)
        ]
        
        #expect(data.average == 10.25)
    }
}

@Suite("HealthMetric Extensions Tests") struct HealthMetricExtensionsTests {
    
    let metrics: [HealthMetric] = [
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 14)) ?? .now, value: 100), // Mon
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 15)) ?? .now, value: 200), // Tue
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 16)) ?? .now, value: 300), // Wed
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 21)) ?? .now, value: 500), // Mon
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 22)) ?? .now, value: 600), // Tue
    ]
    
    @Test func averageWeekdayCount() {
        let averageWeekdayCount = metrics.averageWeekDayCountData
        
        #expect(averageWeekdayCount.count == 3) // How many different days?
        #expect(averageWeekdayCount[0].value == 300) // Monday avg
        #expect(averageWeekdayCount[1].value == 400) // Tuesday avg
        #expect(averageWeekdayCount[2].date.weekdayTitle == "Wednesday") // Wed title
    }
}
