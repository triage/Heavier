//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI
import CoreData
import Combine

struct LiftViewCloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Theme.Font.Size.large, weight: .bold, design: .default))
                .accentColor(.highlight)
        }
    }
}

struct DateButton: View {
    @Binding var date: Date
    
    private let datePickerPaddingLeading: CGFloat = 10.0
    
    struct ViewModel {
        static var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            return dateFormatter
        }
        
        let date: Date
        var dateText: String {
            if Calendar.current.isDateInToday(date) {
                return "Today"
            }
            return ViewModel.dateFormatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "calendar")
                Text(ViewModel(date: date).dateText)
                    .sfCompactDisplay(.medium, size: Theme.Font.Size.mediumPlus)
                    .foregroundColor(.liftDateForeground)
            }
            .padding(Theme.Spacing.medium)
        }
        .background(Color(Color.Overload.liftDateBackground.rawValue))
        .cornerRadius(Theme.Spacing.large)
        .padding([.bottom], Theme.Spacing.medium)
        .padding([.leading], -datePickerPaddingLeading)
        .accentColor(Color.accent)
                .labelsHidden()
        .padding(Theme.Spacing.medium)
                .foregroundColor(Color.liftDateForeground)
        .background(Color.clear)
    }
}

class ObservableValue<Type: Any>: ObservableObject {
    @Published var value: Type
    init(value: Type) {
        self.value = value
    }
}

struct LiftView: View {
    let exercise: Exercise
    let lift: Lift?
    
    @State var reps: Float
    @State var sets: Float
    @State var weight: Float
    @State var dateControlPresented = false
    @State var showDatePicker = false
    @Binding var presented: Bool
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var dateObserved = ObservableValue(value: Date())
    
    init(exercise: Exercise, lift: Lift?, presented: Binding<Bool>) {
        self.exercise = exercise
        self.lift = lift
        self._presented = presented
        _sets = .init(initialValue: Float(lift?.sets ?? 3))
        _reps = .init(initialValue: Float(lift?.reps ?? 10))
        _weight = .init(initialValue: Float(lift?.weightLocalized.weight ?? Settings.shared.units.defaultWeight))
    }
    
    var volume: Float {
        Float(Float(reps) * Float(sets) * weight)
    }
    
    var volumeText: String {
        "= \(Lift.weightsFormatter.string(from: NSNumber(value: volume))!) \(Settings.shared.units.label)"
    }
    
    func save() {
        let lift = Lift(context: managedObjectContext)
        lift.reps = Int16(reps)
        lift.sets = Int16(sets)
        lift.weight = Float(Lift.normalize(weight: weight))
        lift.id = UUID()
        lift.timestamp = dateObserved.value
        lift.exercise = exercise
        do {
            try? managedObjectContext.save()
        }
        presented.toggle()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 18.0) {
                MostRecentLift(lift: lift)
                
                Button(action: {
                    showDatePicker.toggle()
                }, label: {
                    DateButton(date: $dateObserved.value)
                }).zIndex(1)
                
                LiftPicker(
                    label: "sets",
                    range: 1...20,
                    interval: 1,
                    value: $sets,
                    initialValue: Float(lift?.sets ?? 1)
                ).zIndex(0)
                
                LiftPicker(
                    label: "reps",
                    range: 1...30,
                    interval: 1,
                    value: $reps,
                    initialValue: Float(lift?.reps ?? 1)
                ).zIndex(0)
                
                LiftPicker(
                    label: Settings.shared.units.label,
                    range: 0...Settings.shared.units.maxWeight,
                    interval: Settings.shared.units.interval,
                    value: $weight,
                    initialValue: Float(lift?.weightLocalized.weight ?? 1)
                ).zIndex(0)
                
                HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.medium) {
                    Text(volumeText)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.giga)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                }

                Button(action: {
                    save()
                }, label: {
                    Text("Save")
                        .padding(Theme.Spacing.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                }).background(Color.blue)
                .cornerRadius(Theme.Spacing.medium * 2.0)
                .padding([.top], Theme.Spacing.large)

                Spacer()
                
            }.padding([.top, .leading, .trailing], Theme.Spacing.large)
            .navigationTitle(exercise.name!)
        }
        .onReceive(dateObserved.$value, perform: { _ in
            if showDatePicker {
                showDatePicker.toggle()
            }
        })
        .sheet(isPresented: $showDatePicker) {
            DatePicker("", selection: $dateObserved.value, displayedComponents: [.date])
                .labelsHidden()
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(Theme.Spacing.medium)
        }
    }
}

struct LiftView_ContentPreviews: PreviewProvider {
    @State static var presented = true
    
    static var previews: some View {
        
        let exercise = Exercise(context: PersistenceController.preview.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        
        let lift = Lift(context: PersistenceController.preview.container.viewContext)
        lift.reps = 10
        lift.sets = 3
        lift.weight = 135
        lift.id = UUID()
        lift.timestamp = Date()
        exercise.lifts = NSOrderedSet(object: lift)
        
        return Group {
            LiftView(exercise: exercise, lift: lift, presented: $presented)
            LiftView(exercise: exercise, lift: lift, presented: $presented)
            LiftView(exercise: exercise, lift: lift, presented: $presented)
                .environment(\.colorScheme, ColorScheme.dark)
        }
    }
}
