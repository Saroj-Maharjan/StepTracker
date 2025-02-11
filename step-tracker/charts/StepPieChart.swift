//
//  StepPieChart.swift
//  step-tracker
//
//  Created by saroj maharjan on 9/2/2025.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    @State private var selectedChartValue: Double? = 0
    @State private var lastSelectedValue: Double = 0
    
    var chartData: [DateValueChartData]
    
    var selectedWeekDay: DateValueChartData? {
        var total = 0.0
        return chartData.first {
            total += $0.value
            return lastSelectedValue <= total
        }
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            ChartContainer(type:.stepWeekdayPie){
                Chart {
                    ForEach(chartData) { weekDay in
                        SectorMark(
                            angle: .value("Average Steps", weekDay.value),
                            innerRadius: .ratio(0.618),
                            outerRadius: (selectedWeekDay?.date.weekdayInt == weekDay.date.weekdayInt ? 140 : 110),
                            angularInset: 1
                        )
                        .foregroundStyle(
                            HealthMetricContext.steps.tintColor.gradient
                        )
                        .cornerRadius(5)
                        .opacity(selectedWeekDay?.date.weekdayInt == weekDay.date.weekdayInt ? 1 : 0.5)
                        .accessibilityLabel(weekDay.date.weekdayTitle)
                        .accessibilityValue("\(Int(weekDay.value)) steps")
                    }
                }
                .chartAngleSelection(value: $selectedChartValue)
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geometry in
                        if proxy.plotFrame != nil {
                            let frame = geometry.frame(in: .local)
                            
                            if let selectedWeekDay {
                                VStack {
                                    Text(selectedWeekDay.date.weekdayTitle)
                                        .font(.title3.bold())
                                        .animation(.none)
                                    
                                    Text(
                                        selectedWeekDay.value,
                                        format: .number.precision(
                                            .fractionLength(0))
                                    )
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                                }
                                .position(x: frame.midX, y: frame.midY)
                                .accessibilityHidden(true)
                            }
                        }
                    }
                }
                .overlay {
                    if chartData.isEmpty {
                        ChartEmptyView(
                            systemImageName: "chart.pie", 
                            title: "No Data",
                            description: "There is no step count data found in Health app."
                        )
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedWeekDay?.date.weekdayInt)
        .onChange(of: selectedChartValue ?? -1) { oldValue, newValue in
            withAnimation(.easeOut) {
                if newValue == -1 {
                    lastSelectedValue = oldValue
                } else {
                    lastSelectedValue = newValue
                }
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: MockData.steps.averageWeekDayCountData)
}
