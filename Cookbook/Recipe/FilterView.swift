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
    @Binding var didChangeDates: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedTags: Set<Tag>
    @Binding var sortBy: SortBy
    @Binding var sortDirectionDescending: Bool
    
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
                    Picker("Sort by", selection: $sortBy) {
                        Text("Alphabetical").tag(SortBy.name)
                        Text("Date Added").tag(SortBy.date)
                        Text("Last Made").tag(SortBy.lastMade)
                        Text("Difficulty").tag(SortBy.difficulty)
                    }.pickerStyle(.automatic)
                        .onChange(of: sortBy) { oldValue, newValue in
                            sortDirectionDescending = !(sortBy == .date || sortBy == .lastMade)
                        }
                    
                    if sortBy == .name {
                        Picker("Order", selection: $sortDirectionDescending) {
                            Text("Ascending").tag(false)
                            Text("Descending").tag(true)
                        }.pickerStyle(.automatic)
                    }
                    
                    if sortBy == .difficulty {
                        Picker("Difficulty", selection: $sortDirectionDescending) {
                            Text("Easiest").tag(true)
                            Text("Hardest").tag(false)
                        }.pickerStyle(.automatic)
                    }
                    
                    if sortBy == .date || sortBy == .lastMade {
                        Picker("Date", selection: $sortDirectionDescending) {
                            Text("Newest").tag(false)
                            Text("Oldest").tag(true)
                        }.pickerStyle(.automatic)
                    }
                    
                } header: {Text("Sort")}
                
                Section {
                    
                    VStack(alignment: .leading) {
                        Text("Difficulty")
                        GradientSlider(value: $difficultyFilterValue)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Tags")
                            TextField("Search", text: $tagSearch)
                        }
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
                        
                        
                    }
                    
                    VStack(alignment: .leading) {                        
                        let dateRange: ClosedRange<Date> = {
                            let now = Date()
                            return Date.distantPast ... now
                        }()
                        
                        DatePicker("Start Date", selection: $startDate, in: dateRange, displayedComponents: [.date]).onChange(of: startDate) { oldValue, newValue in
                            let calendar = Calendar.current
                            if (calendar.isDateInToday(newValue) && calendar.isDateInToday(endDate)) {
                                return
                            }
                            didChangeDates = true
                        }

                        DatePicker("End Date", selection: $endDate, in: dateRange, displayedComponents: [.date]).onChange(of: endDate) { oldValue, newValue in
                            let calendar = Calendar.current
                            if (calendar.isDateInToday(newValue) && calendar.isDateInToday(startDate)) {
                                return
                            }
                            didChangeDates = true
                        }
                    }
                    
                } header: {Text("Filter")}
                
                Section {
                    if (difficultyFilterValue != 100 || selectedTags.count != 0 || didChangeDates ) {
                        ListButton(text: "Reset Filters", imageSystemName: "arrowshape.turn.up.backward", disabled: false) {
                            difficultyFilterValue = 100
                            selectedTags.removeAll()
                            startDate = Date()
                            endDate = Date()
                            didChangeDates = false
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    FilterView()
//}

