//
//  ListView.swift
//  Overload
//
//  Created by Eric Schulte on 10/27/20.
//

import Foundation
import SwiftUI

struct ListView: View {

    @State var exerciseSelected: Exercise?
    @State var isPresenting = false
    
    @StateObject var observer = ListViewObservable()
    
    @ObservedObject var settings = Settings.shared
    @Environment(\.managedObjectContext) var context
    
    static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    private struct LiftShortDescription: View {
        let group: [Lift]
        let settings: Settings
        var body: some View {
            VStack(alignment: .leading) {
                if let shortDescription = group.shortDescription(units: settings.units) {
                    Text(shortDescription)
                }
                if let timestamp = group.first?.timestamp {
                    Text(ListView.timestampFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        .padding([.top], 2.0)
                }
            }
        }
    }
    
    private func cell(placeholder exercise: Exercise) -> some View {
        NavigationLink(
            destination:
                NavigationLazyView(
                    ExerciseView(
                        exercise: exercise,
                        managedObjectContext: exercise.managedObjectContext!
                    )
                )
        ) {
            HStack {
                Text(exercise.name!)
                    .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.system(size: Theme.Font.Size.large))
            }
            .padding(.vertical, Theme.Spacing.medium)
        }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(observer.rows, id: \.hashValue) { exercise in
                    if exercise.placeholder {
                        cell(placeholder: exercise)
                            .id(exercise.listViewIdentifier)
                    } else {
                        ExerciseCell(
                            exerciseSelected: $exerciseSelected,
                            isPresenting: $isPresenting,
                            exercise: exercise
                        ).id(exercise.listViewIdentifier)
                    }
                }
            }.listStyle(PlainListStyle())
            .navigationDestination(for: $exerciseSelected) { exercise in
                ExerciseView(exercise: exercise, managedObjectContext: PersistenceController.shared.container.viewContext)
            }
        }.searchable(
            text: $observer.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: nil
        )
    }
}

private extension Exercise {
    var listViewIdentifier: String {
        if let name = name, let timestamp = timestamp {
            return "\(name) - \(timestamp.timeIntervalSince1970)"
        }
        return ""
    }
}

struct ExerciseCell: View {
    @Binding var exerciseSelected: Exercise?
    @Binding var isPresenting: Bool
    
    @ObservedObject var exercise: Exercise
    @ObservedObject var settings = Settings.shared
    
    @Environment(\.managedObjectContext) var context
    
    private struct LiftShortDescription: View {
        let lifts: [Lift]
        let settings: Settings
        var body: some View {
            VStack(alignment: .leading) {
                if let shortDescription = lifts.shortDescription(units: settings.units) {
                    Text(shortDescription)
                }
                if let timestamp = lifts.first?.timestamp {
                    Text(ListView.timestampFormatter.string(from: timestamp))
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.medium)
                        .padding([.top], 2.0)
                }
            }
        }
    }
    
    var body: some View {
        Button(action: {
            exerciseSelected = exercise
            isPresenting = true
        }, label: {
            HStack(alignment: .top, spacing: nil, content: {
                VStack(alignment: .leading) {
                    Text(exercise.name!)
                        .sfCompactDisplay(.medium, size: Theme.Font.Size.large)
                    if let lastGroup = exercise.lastGroup(context: context) {
                        LiftShortDescription(lifts: lastGroup, settings: settings)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.Font.Size.large))
                    .opacity(0.25)
                    .scaleEffect(0.5)
            })
            .padding(.vertical, Theme.Spacing.medium)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        Group {
            ListView()
        }.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
