//
//  ChartBarChart.swift
//  step-tracker
//
//  Created by saroj maharjan on 20/12/2024.
//

import Charts
import SwiftUI

struct StepBarChart: View {
    @State private var selectedDate: Date?
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        chartData.selectedData(in: selectedDate)
    }
    
    var body: some View {
        ChartContainer(type:.stepBar(average: chartData.avgStepCounts)){
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .steps)
                }
                
                if !chartData.isEmpty {
                    RuleMark(y:.value("Average", chartData.avgStepCounts))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                }
                
                ForEach(chartData) { steps in
                    Plot {
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(HealthMetricContext.steps.tintColor)
                        .opacity(selectedData == nil || steps.date == selectedData?.date ? 1.0 : 0.3)
                    }
                    .accessibilityLabel(steps.date.accessibilityDate)
                    .accessibilityValue("\(Int(steps.value)) steps")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $selectedDate.animation())
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(
                        format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    AxisValueLabel(
                        (value.as(Double.self) ?? 0).formatted(
                            .number.notation(.compactName)
                        )
                    )
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.bar",
                        title: "No data",
                        description: "There is no step count data found un Health app."
                    )
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedData?.date.weekdayInt)
    }
}

#Preview {
    StepBarChart(chartData: MockData.steps.chartData)
}
