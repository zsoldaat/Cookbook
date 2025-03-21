//
//  FilterView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-16.
//

import SwiftUI

struct FilterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var searchValue: String
    @Binding var difficultyFilterValue: Float
    @Binding var dateFilterViewShowing: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        
        NavigationStack {
            
            HStack {
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }.padding()
            }
            
            Form {
                Section {
                    GradientSlider(value: $difficultyFilterValue)
                    
                } header: {Text("Difficulty")}
                
                Section {
                    
                    Toggle(isOn: $dateFilterViewShowing) {
                        Label("Filter by Date", systemImage: "calendar")
                    }
                    
                    if (dateFilterViewShowing) {
                        let startDateRange: ClosedRange<Date> = {
                            let calendar = Calendar.current
                            let startComponents = DateComponents(year: 2021, month: 1, day: 1)
                            let endComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate <= Date() ? endDate : Date())
                            return calendar.date(from:startComponents)!
                                ...
                                calendar.date(from:endComponents)!
                        }()
                        
                        DatePicker("Start Date", selection: $startDate, in: startDateRange, displayedComponents: [.date])
                        
                        let endDateRange: ClosedRange<Date> = {
                            let calendar = Calendar.current
                            let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate <= Date() ? startDate : Date())
                            let endComponents = DateComponents(year: 2100, month: 1, day: 1)
                            return calendar.date(from:startComponents)!
                                ...
                                calendar.date(from:endComponents)!
                        }()

                        
                        DatePicker("End Date", selection: $endDate, in: endDateRange, displayedComponents: [.date])
                    }
                    
                } header: { Text("Dates") }
            }
            
            Button {
                difficultyFilterValue = 100
                startDate = Date()
                endDate = Date()
                dateFilterViewShowing = false
            } label: {
                Label("Reset Filters", systemImage: "arrowshape.turn.up.backward")
            }
            .buttonStyle(.bordered)
            .disabled(difficultyFilterValue == 100 && Calendar.current.isDateInToday(startDate) && Calendar.current.isDateInToday(endDate) && !dateFilterViewShowing)
        }
    }
}

//#Preview {
//    FilterView()
//}
