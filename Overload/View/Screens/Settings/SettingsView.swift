//
//  Settings.swift
//  Overload
//
//  Created by Eric Schulte on 12/1/20.
//

import Foundation
import SwiftUI
import Combine

final class SettingsManager: ObservableObject {
    private enum Keys {
        static let units = "units"
    }
    @Published var units: Int = UserDefaults.standard.integer(
        forKey: SettingsManager.Keys.units
    ) {
        didSet {
            UserDefaults.standard.set(units, forKey: SettingsManager.Keys.units)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager()
    
    static let options = ["Imperial", "Metric"]
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $settings.units, label: Text("Units")) {
                    ForEach(0 ..< SettingsView.options.count, id: \.self) {
                        Text(SettingsView.options[$0]).tag($0)
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
        }
    }
}
