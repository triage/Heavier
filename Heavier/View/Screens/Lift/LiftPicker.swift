//
//  LiftPicker.swift
//  Overload
//
//  Created by Eric Schulte on 10/31/20.
//

import Foundation
import SwiftUI

struct LiftPicker: View {
    
    private let dimensions = CGSize(width: 135.0, height: 45.0)
    private let lineHeight: CGFloat = 1.0
    
    let label: String
    let range: ClosedRange<Float>
    let interval: Float
    let initialValue: Float?
    
    @Binding var value: Float
    @State private var rowSelected: Int
    
    init(label: String, range: ClosedRange<Float>, interval: Float, value: Binding<Float>, initialValue: Float?) {
        self.label = label
        self.range = range
        self.interval = interval
        self.initialValue = initialValue
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
        let value: Float = range.lowerBound + (Float(row) * interval)
        if floor(Double(interval)) == Double(interval) {
            return "\(Int(value))"
        }
        return "\(value)"
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: 1.0) {
                // picker
                TransparentPicker(selection: $rowSelected, rowCount: rowCount) { (row) in
                    Text(label(row: row))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.giga)
                }
                .onReceive([self.rowSelected].publisher.first()) { (row) in
                    self.value = range.lowerBound + (interval * Float(row))
                }
                .frame(width: dimensions.width, height: 60.0)
                .clipped()
                
                // underline
                Path { path in
                    path.move(to: .zero)
                    path.addRect(
                        CGRect(
                            origin: .zero,
                            size: CGSize(width: dimensions.width, height: lineHeight)
                        )
                    )
                }
                .fill(Color.underline)
                .alignmentGuide(.leading, computeValue: { dimension in
                    dimension[.leading]
                }).alignmentGuide(.trailing, computeValue: { dimension in
                    dimension[.trailing]
                }).frame(width: dimensions.width, height: lineHeight, alignment: .bottomLeading)
                .clipped()
            }
            .offset(x: 0.0, y: 2.0)
            .ignoresSafeArea()
            
            Text(label)
                .sfCompactDisplay(.regular, size: Theme.Font.Size.giga)
                .foregroundColor(Color.label)
                .frame(width: .none, height: dimensions.height)
                .offset(x: 0.0, y: -3.0)
            Spacer()
        }.padding([.bottom], Theme.Spacing.medium)
    }
}

struct LiftPicker_Previews: PreviewProvider {
    @State static var value: Float = 135
    static var previews: some View {
        Group {
            LiftPicker(
                label: "lbs",
                range: 5...300,
                interval: 5,
                value: $value,
                initialValue: 135
            )
            LiftPicker(
                label: "lbs",
                range: 5...300,
                interval: 5,
                value: $value,
                initialValue: 130
            )
            LiftPicker(
                label: "lbs",
                range: 5...300,
                interval: 5,
                value: $value,
                initialValue: 140
            )
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
