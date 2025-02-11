//
//  HealthDataListView.swift
//  step-tracker
//
//  Created by saroj maharjan on 20/12/2024.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(HealthKitData.self) private var hkdata
    
    @State private var isShowingAddData: Bool = false
    @State private var selectedDate: Date = .now
    @State private var valueToAdd: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var writeError: STError = .noData
    
    var metric: HealthMetricContext
    
    var listData: [HealthMetric] {
        metric == .steps ? hkdata.steps : hkdata.weights
    }
    
    var body: some View {
        List(listData) { data in
            HStack {
                LabeledContent{
                    Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
                } label: {
                    Text(data.date, format: .dateTime.month().day().year())
                        .accessibilityLabel(data.date.accessibilityDate)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData){
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus"){
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .alert(isPresented: $isShowingAlert, error: writeError, actions: { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharingDenied:
                    Button("Setting"){
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    
                    Button("Cancel", role: .cancel){}
                }
                
            }, message: { writeError in
                Text(writeError.failureReason)
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data"){
                        addButtonTapped()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss"){
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
    
    private func addButtonTapped() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valueToAdd = ""
            return
        }
        
        Task {
            do {
                switch metric {
                case .steps:
                    try await healthKitManager.addStepData(for: selectedDate, value: value)
                    hkdata.steps = try await healthKitManager.fetchStepCount()
                    
                case .weight:
                    try await healthKitManager.addWeightData(for: selectedDate, value: value)
                    hkdata.weights = try await healthKitManager.fetchWeights()
                }
                
                isShowingAddData = false
            }
            catch STError.sharingDenied(let quantityData){
                writeError = .sharingDenied(quantityType: quantityData)
                isShowingAlert = true
            } catch  {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
            .environment(HealthKitData())
    }
}
