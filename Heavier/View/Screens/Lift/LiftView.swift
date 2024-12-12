//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI
import CoreData
#if canImport(FirebaseFunctions)
import FirebaseFunctions
#endif

struct LiftViewCloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Theme.Font.Size.large, weight: .bold, design: .default))
                .accentColor(Color(.highlight))
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
                return String(localized: "Today")
            }
            return ViewModel.dateFormatter.string(from: date)
        }
    }
    
    var body: some View {
        LiftButton(
            text: ViewModel(date: date).dateText,
            imageName: "calendar",
            selected: !Calendar.current.isDateInToday(date),
            imageNameTrailing: nil
        )
    }
}

struct LiftView: View {
    let exercise: Exercise
    let lift: Lift?
    private let mode: Mode
    
    enum SheetType: Identifiable {
        case calendar
        case notes
        
        // swiftlint:disable:next identifier_name
        var id: Int {
            hashValue
        }
    }
    
    @State var reps: Float
    @State var sets: Float
    @State var weight: Float
    @State var notes: String = ""
    @State var sheetType: SheetType?
    
    @Binding var presented: Bool
    
    @Environment(\.managedObjectContext) var context
    @ObservedObject var dateObserved = ObservableValue(value: Date())
    
    enum Mode {
        case creating
        case editing
    }
    
    init(exercise: Exercise, lift: Lift?, presented: Binding<Bool>, mode: Mode = .creating) {
        self.exercise = exercise
        self.lift = lift
        self.mode = mode
        self._presented = presented

        _notes = .init(initialValue: lift?.notes ?? "")
        _sets = .init(initialValue: Float(lift?.sets ?? 3))
        _reps = .init(initialValue: Float(lift?.reps ?? 10))
        _weight = .init(initialValue: Float(lift?.weightLocalized.weight ?? Settings.shared.units.defaultWeight))
        if mode == .editing, let timestamp = lift?.timestamp {
            dateObserved.value = timestamp
        }
    }
    
    var volume: Float {
        Float(Float(reps) * Float(sets) * weight)
    }
    
    var volumeText: String {
        "= \(Lift.weightsFormatter.string(from: NSNumber(value: volume))!) \(Settings.shared.units.label)"
    }
    
    func save() {
        func updateFromState(lift: Lift) {
            lift.reps = Int16(reps)
            lift.sets = Int16(sets)
            lift.weight = Float(Lift.normalize(weight: weight))
            lift.notes = notes
            lift.timestamp = dateObserved.value
            lift.exercise?.timestamp = Date()
        }
        
        if mode == .creating {
            let lift = Lift(context: exercise.managedObjectContext!)
            lift.id = UUID()
            lift.exercise = exercise
            updateFromState(lift: lift)
        } else if let lift = lift {
            updateFromState(lift: lift)
        }
        
        do {
            try? exercise.managedObjectContext!.save()
#if canImport(FirebaseFunctions)
            Task {
                do {
                    try await HeavierApp.functions.httpsCallable("exercise_add_name").call(["query": exercise.name!])
                } catch {
                    /* noop */
                }
            }
            #endif
            
            exercise.clearLastGroupShortDescriptionCache()
            
            let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
            hapticFeedback.impactOccurred()
            
            presented.toggle()
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                MostRecentLift(lift: lift)
                
                HStack {
                    Button(action: {
                        sheetType = .calendar
                    }, label: {
                        DateButton(date: $dateObserved.value)
                    })
                    
                    Button(action: {
                        sheetType = .notes
                    }, label: {
                        LiftButton(
                            text: String(localized: "Notes", comment: "Notes"),
                            imageName: "note.text",
                            selected: notes.count > 0,
                            imageNameTrailing: notes.count > 0 ? "checkmark.circle.fill" : nil
                        )
                    })
                }.zIndex(1)
                
                LiftPicker(
                    label: "sets",
                    range: 1...20,
                    interval: 1,
                    value: $sets,
                    initialValue: Float(lift?.sets ?? 1)
                ).zIndex(0)
                
                LiftPicker(
                    label: "reps",
                    range: 1...50,
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
                    Text("Save", comment: "Save")
                        .padding(Theme.Spacing.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                }).background(Color.blue)
                .cornerRadius(Theme.Spacing.medium * 2.0)
                .padding([.top], Theme.Spacing.large)

                Spacer()
            }
            .padding([.top, .leading, .trailing], Theme.Spacing.large)
            .navigationTitle(exercise.name!)
            .sheet(item: $sheetType) { sheetType in
                switch sheetType {
                case .calendar:
                    NavigationView {
                        VStack {
                            DatePicker("", selection: $dateObserved.value, displayedComponents: [.date])
                                .labelsHidden()
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding(Theme.Spacing.medium)
                            Spacer()
                        }.navigationTitle(String(localized: "Select Date", comment: "Select Date"))
                    }
                case .notes:
                    NotesView(notes: $notes) {
                        self.sheetType = nil
                    }
                }
            }
        }
        .onReceive(dateObserved.$value, perform: { _ in
            if sheetType == .calendar {
                sheetType = nil
            }
        })
        
    }
}

struct LiftView_ContentPreviews: PreviewProvider {
    @State static var presented = true
    
    static var previews: some View {
        
        func makeExercise() -> Exercise {
            let exercise = Exercise(context: PersistenceController.preview.container.viewContext)
            exercise.name = "Romanian Deadlift"
            exercise.id = UUID()
            return exercise
        }
        
        let (exercise1, exercise2) = (makeExercise(), makeExercise())
        
        func makeLift() -> Lift {
            let lift = Lift(context: PersistenceController.preview.container.viewContext)
            lift.reps = 10
            lift.sets = 3
            lift.weight = 135
            lift.id = UUID()
            lift.timestamp = Date()
            return lift
        }
        
        let lift = makeLift()
        exercise1.lifts = NSOrderedSet(object: makeLift())
        
        let lift2 = makeLift()
        lift2.notes = "Hello World"
        exercise1.lifts = NSOrderedSet(object: lift2)
        
        return Group {
            LiftView(exercise: exercise1, lift: lift, presented: $presented)
                .previewDisplayName("Light")
            LiftView(exercise: exercise1, lift: lift, presented: $presented).colorScheme(.dark)
                .previewDisplayName("Dark")
            LiftView(exercise: exercise1, lift: lift2, presented: $presented)
            LiftView(exercise: exercise2, lift: lift2, presented: $presented, mode: .editing)
                    .environment(\.colorScheme, ColorScheme.dark)
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
