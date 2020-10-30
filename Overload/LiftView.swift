//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI

struct LiftPicker {
    let configuration: (range: Range<Int>, interval: Int)
}

struct LiftView: View {
    let lift: Lift?
    @State var selected: String = ""
    @State var reps: Int = 10
    @State var sets: Int = 5
    
    var pickerWidth: CGFloat = 40.0
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 3.0) {
                    TransparentPicker(selection: $reps, rowCount: 10) { (row) in
                        Text("\(row)")
                            .sfCompactDisplay(.regular, size: 45.0)
                            .padding(EdgeInsets(top: 15.0, leading: 0.0, bottom: 15.0, trailing: 0.0))
                    }
                    .frame(width: pickerWidth, height: 33)
                    .clipped()
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
                }.offset(x: 0.0, y: 4.0)
                Text("Reps").sfCompactDisplay(.regular, size: 45.0)
            }
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
