//
//  FilterView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-16.
//

import SwiftUI
import SwiftData

struct FilterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    
    @Binding var searchValue: String
    @Binding var difficultyFilterValue: Float
    @Binding var dateFilterViewShowing: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedTags: Set<Tag>
    
    @State var tagSearch: String = ""
    
    @Query var recipes: [Recipe]
    
    func allTags(recipes: [Recipe]) -> [Tag] {
        return recipes
            .map{$0.tags!}
            .reduce([], {cur, next in cur + next.filter{ tag in !cur.map{$0.name}.contains(tag.name)}})
            .filter{!selectedTags.map{$0.id}.contains($0.id)}
            .filter{tagSearch.isEmpty ? true : $0.name.lowercased().contains(tagSearch.lowercased())}
    }
    
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
                    
                    if selectedTags.count > 0 {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedTags.sorted{$0.name < $1.name}, id: \.self) {tag in
                                    ChipView {
                                        HStack {
                                            Text(tag.name)
                                            Button {
                                                selectedTags.remove(tag)
                                            } label: {
                                                Label("Remove", systemImage: "x.circle.fill")
                                                    .labelStyle(.iconOnly)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                        .scrollIndicators(.hidden)
                    }
                    
                    TextField("Search", text: $tagSearch)
                    
                    if allTags(recipes: recipes).count > 0 {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(allTags(recipes: recipes), id: \.self) { tag in
                                        ChipView {
                                            HStack {
                                                Text(tag.name)
                                                Button {
                                                    selectedTags.insert(tag)
                                                    tagSearch = ""
                                                } label: {
                                                    Label("Add", systemImage: "plus")
                                                        .labelStyle(.iconOnly)
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.vertical)
                        .scrollIndicators(.hidden)
                    }

                } header: {Text("Tags")}
                
                Section {
                    
                    Toggle(isOn: $dateFilterViewShowing) {
                        Label("Filter by Date Created", systemImage: "calendar")
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
                selectedTags.removeAll()
                startDate = Date()
                endDate = Date()
                dateFilterViewShowing = false
                
            } label: {
                Label("Reset Filters", systemImage: "arrowshape.turn.up.backward")
            }
            .buttonStyle(.bordered)
            .disabled(difficultyFilterValue == 100 && selectedTags.count == 0 && Calendar.current.isDateInToday(startDate) && Calendar.current.isDateInToday(endDate) && !dateFilterViewShowing)
        }
    }
}

//#Preview {
//    FilterView()
//}
