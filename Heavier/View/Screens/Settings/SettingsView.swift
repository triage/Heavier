//
//  Settings.swift
//  Overload
//
//  Created by Eric Schulte on 12/1/20.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $settings.units, label: Text("Units", comment: "Units")) {
                    ForEach(Settings.Units.allCases, id: \.self) { unit in
                        Text(unit.description).tag(unit.rawValue)
                    }
                }
            }.navigationTitle(String(localized: "Settings", comment: "Settings"))
        }.accentColor(Color(.accent))
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
        }
    }
}
