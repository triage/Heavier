//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI

struct LiftPicker: View {
    
    private let pickerWidth: CGFloat = 90.0
    
    let label: String
    let range: ClosedRange<Int>
    let interval: Int
    
    @Binding var value: Int
    @State private var rowSelected: Int
    
    init(label: String, range: ClosedRange<Int>, interval: Int, value: Binding<Int>) {
        self.label = label
        self.range = range
        self.interval = interval
        self._value = value
        let rowCount = Int(ceil(Double((range.upperBound - range.lowerBound) / interval)))
        
        let first = value.wrappedValue - range.lowerBound
        let second = range.upperBound - range.lowerBound
        let percent = Double(first) / Double(second)
        let index = Int(ceil(percent * Double(rowCount)))
        
        self._rowSelected = State<Int>(initialValue: index)
    }
    
    private var rowCount: Int {
        Int((range.upperBound - range.lowerBound) / interval) + 1
    }
    
    private func label(row: Int) -> String {
        let value = range.lowerBound + (row * interval)
        return "\(value)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1.0) {
                
                // picker
                TransparentPicker(selection: $rowSelected, rowCount: rowCount) { (row) in
                    Text(label(row: row))
                        .sfCompactDisplay(.regular, size: 54.0)
                }
                .onReceive([self.rowSelected].publisher.first()) { (row) in
                    self.value = range.lowerBound + (interval * row)
                }
                .frame(width: pickerWidth, height: 45)
                .clipped()
                // underline
                Path { path in
                    path.move(to: CGPoint.zero)
                    path.addRect(CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 4.0)))
                }
                .fill(Color.black)
                .alignmentGuide(.leading, computeValue: { dimension in
                    dimension[.leading]
                }).alignmentGuide(.trailing, computeValue: { dimension in
                    dimension[.trailing]
                }).frame(width: pickerWidth, height: 2.0, alignment: .bottomLeading)
                .clipped()
            }.offset(x: 0.0, y: 2.0)
            Text(label)
                .sfCompactDisplay(.regular, size: 54.0)
                .foregroundColor(Color.underline)
            Spacer()
        }
    }
}

struct LiftView: View {
    let lift: Lift?
    
    @State var reps: Int
    @State var sets: Int
    @State var weight: Int
    
    init(lift: Lift?) {
        self.lift = lift
        if let lift = lift {
            self._reps = State<Int>(initialValue: Int(lift.reps))
            self._sets = State<Int>(initialValue: Int(lift.sets))
            self._weight = State<Int>(initialValue: Int(lift.weight))
        } else {
            self._reps = State<Int>(initialValue: Int(5))
            self._sets = State<Int>(initialValue: Int(5))
            self._weight = State<Int>(initialValue: Int(45))
        }
    }
    
    var volume: Int {
        Int(reps * sets * weight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            LiftPicker(
                label: "reps",
                range: 1...20,
                interval: 1,
                value: $reps
            )
            LiftPicker(
                label: "sets",
                range: 1...20,
                interval: 1,
                value: $sets
            )
            LiftPicker(
                label: "lbs",
                range: 5...300,
                interval: 5,
                value: $weight
            )
            Text("= \(volume) lbs")
                .sfCompactDisplay(.medium, size: 54.0)
        }.padding(30.0)
    }
}

struct LiftView_ContentPreviews: PreviewProvider {
    static var previews: some View {
        
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        
        let lift = Lift(context: PersistenceController.shared.container.viewContext)
        lift.reps = 10
        lift.sets = 3
        lift.weight = 135
        lift.id = UUID()
        lift.timestamp = Date()
        exercise.lifts = NSOrderedSet(object: lift)
        
        return Group {
            LiftView(lift: lift)
            LiftView(lift: nil)
        }
    }
}
