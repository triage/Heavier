//
//  RootCalendarView.swift
//  Heavier
//
//  Created by Eric Schulte on 8/1/21.
//

import Foundation
import SwiftUI
import Combine
import CoreData

struct RootCalendarView: View {
    
    private class DateComponentsObservable: ObservableObject {
        @Published var dateComponents: DateComponents?
    }
    
    @StateObject var lifts: LiftsObservable
    @StateObject private var daySelected = DateComponentsObservable()
    @State var isPresented = false
    
    private let managedObjectContext: NSManagedObjectContext
    
    private static let title = "Calendar"
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        _lifts = .init(wrappedValue: LiftsObservable(exercise: nil, context: context))
    }
    
    var body: some View {
        return VStack {
            LiftsCalendarView(
                lifts: $lifts.lifts,
                timestampBounds: Lift.timestampBoundsMonth(managedObjectContext: managedObjectContext)
            ) { day in
                daySelected.dateComponents = day.components
                isPresented.toggle()
            }
            .frame(maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading)
            .navigationTitle(RootCalendarView.title)
            NavigationLink(
                destination: LiftsOnDateView(daySelected: daySelected.dateComponents,
                                             context: managedObjectContext),
                isActive: $isPresented,
                label: {
                    EmptyView()
                }
            )
        }
    }
}

struct RootCalendarView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            RootCalendarView(context: PersistenceController.preview.container.viewContext)
        }
    }
}
