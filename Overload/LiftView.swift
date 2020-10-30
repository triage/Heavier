//
//  LiftView.swift
//  Overload
//
//  Created by Eric Schulte on 10/28/20.
//

import Foundation
import SwiftUI

struct LiftView: View {
    let lift: Lift?
    @State var selected: String = ""
    @State var reps: Int = 10
    @State var sets: Int = 5
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    TransparentPicker(selection: $reps, rowCount: 10) { (row) in
                        Text("\(row)")
                            .sfCompactDisplay(.regular, size: 45.0)
                            .padding(EdgeInsets(top: 15.0, leading: 0.0, bottom: 15.0, trailing: 0.0))
                    }
                                        .frame(width: 30, height: 33)
                                        .clipped()
                    Path { path in
                        path.move(to: CGPoint.zero)
                        path.addLine(to: CGPoint(x: 60.0, y: 0.0))
                    }.stroke(Color.blue, lineWidth: 3.0)
                }

                
                Text("Reps").sfCompactDisplay(.regular, size: 45.0)
                Spacer()
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
