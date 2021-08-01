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
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    private static let title = "Calendar"
    
    init(managedObjectContext: NSManagedObjectContext) {
        _lifts = .init(wrappedValue: LiftsObservable(exercise: nil, managedObjectContext: managedObjectContext))
    }
    
    var body: some View {
        print("lifts:\(lifts.lifts)")
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
                                             managedObjectContext: managedObjectContext),
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
            RootCalendarView(managedObjectContext: PersistenceController.preview.container.viewContext)
        }
    }
}
