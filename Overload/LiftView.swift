//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI

struct LiftPicker: View {
    let label: String
    let range: ClosedRange<Int>
    let interval: Int
    let value: Binding<Int>
    
    private let pickerWidth: CGFloat = 90.0
    
    private var rowCount: Int {
        Int(((range.upperBound + 1) - range.lowerBound) / interval)
    }
    
    private func label(row: Int) -> String {
        let value = range.lowerBound + (row * interval)
        return "\(value)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1.0) {
                
                // picker
                TransparentPicker(selection: value, rowCount: rowCount) { (row) in
                    Text(label(row: row))
                        .sfCompactDisplay(.regular, size: 54.0)
                }
                .frame(width: pickerWidth, height: 45)
                .clipped()
                
                // underline
                Path { path in
                    path.move(to: CGPoint.zero)
                    path.addRect(CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 4.0)))
                }
                .fill(Color.underline)
                .alignmentGuide(.leading, computeValue: { dimension in
                    dimension[.leading]
                }).alignmentGuide(.trailing, computeValue: { dimension in
                    dimension[.trailing]
                }).frame(width: pickerWidth, height: 3.0, alignment: .bottomLeading)
                .clipped()
            }.offset(x: 0.0, y: 2.0)
            Text(label)
                .sfCompactDisplay(.regular, size: 54.0)
                .foregroundColor(Color.underline)
        }
    }
}

struct LiftView: View {
    let lift: Lift?
    @State var selected: String = ""
    @State var reps: Int = 10
    @State var sets: Int = 5
    @State var weight: Int = 135
    
    var pickerWidth: CGFloat = 40.0
    
    var volume: Int {
        Int(reps * sets * weight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            LiftPicker(
                label: "reps",
                range: 1...30,
                interval: 1,
                value: $reps
            )
            LiftPicker(
                label: "sets",
                range: 1...10,
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
        Group {
            LiftView(lift: nil)
        }
    }
}
