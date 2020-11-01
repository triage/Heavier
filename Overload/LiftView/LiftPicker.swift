//
//  LiftPicker.swift
//  Overload
//
//  Created by Eric Schulte on 10/31/20.
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
        
        let percent = Double(value.wrappedValue - range.lowerBound) / Double(range.upperBound - range.lowerBound)
        let index = Int(ceil(percent * Double(rowCount)))
        
        _rowSelected = .init(initialValue: index)
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
                    path.addRect(CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 1.0)))
                }
                .fill(Color.black)
                .alignmentGuide(.leading, computeValue: { dimension in
                    dimension[.leading]
                }).alignmentGuide(.trailing, computeValue: { dimension in
                    dimension[.trailing]
                }).frame(width: pickerWidth, height: 1.0, alignment: .bottomLeading)
                .clipped()
            }.offset(x: 0.0, y: 2.0)
            Text(label)
                .sfCompactDisplay(.regular, size: 54.0)
                .foregroundColor(Color.underline)
            Spacer()
        }
    }
}

struct LiftPicker_Previews: PreviewProvider {
    @State static var value: Int = 135
    static var previews: some View {
        LiftPicker(
            label: "lbs",
            range: 5...300,
            interval: 5,
            value: $value
        )
    }
}
