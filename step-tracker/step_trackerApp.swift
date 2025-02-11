//
//  step_trackerApp.swift
//  step-tracker
//
//  Created by saroj maharjan on 18/12/2024.
//

import SwiftUI

@main
struct step_trackerApp: App {
    let hkManager = HealthKitManager()
    let hkData = HealthKitData()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkData)
                .environment(hkManager)
        }
    }
}
