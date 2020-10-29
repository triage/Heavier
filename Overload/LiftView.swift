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
    var body: some View {
        VStack {
            HStack {
                Picker("whatever", selection: $reps) {
                    ForEach(0 ..< 100) {
                        Text("\($0)")
                            .sfCompactDisplay(.regular, size: 30.0)
                    }
                }
                .frame(width: 100, height: 40)
                .clipped()
                Text("Reps").sfCompactDisplay(.regular, size: 30.0)
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
