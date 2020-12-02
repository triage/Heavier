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
    @Published var units: Int = 0 {
        didSet {
            UserDefaults.standard.set(units as NSNumber, forKey: SettingsManager.Keys.units)
        }
    }
    
    init() {
        if let number = UserDefaults.standard.object(forKey: SettingsManager.Keys.units) as? NSNumber {
            units = number.intValue
        } else {
            units = (Locale.current.usesMetricSystem as NSNumber).intValue
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager()
    
    static let options = ["Imperial (lb)", "Metric (kg)"]
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $settings.units, label: Text("Units")) {
                    ForEach(0 ..< SettingsView.options.count, id: \.self) {
                        Text(SettingsView.options[$0]).tag($0)
                    }
                }
            }.navigationTitle("Settings")
        }.accentColor(.accent)
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
        }
    }
}
