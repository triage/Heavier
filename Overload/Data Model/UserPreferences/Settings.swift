//
//  Settings.swift
//  Overload
//
//  Created by Eric Schulte on 12/1/20.
//

import Foundation
import Combine

final class Settings: ObservableObject {
    
    static let shared = Settings()
    
    private enum Keys {
        static let units = "units"
    }
    
    enum Units: Int, CustomStringConvertible, CaseIterable, Identifiable {
        case imperial
        case metric
        
        var description: String {
            switch self {
            case .imperial:
                return "Imperial (lb)"
            case .metric:
                return "Metric (kg)"
            }
        }
        
        // swiftlint:disable:next identifier_name
        var id: Int {
            rawValue   
        }
        
        var label: String {
            switch self {
            case .imperial:
                return "lb"
            case .metric:
                return "kg"
            }
        }
    }
    
    @Published var units: Units = Units.imperial {
        didSet {
            UserDefaults.standard.set(units.rawValue as NSNumber, forKey: Settings.Keys.units)
        }
    }
    
    init() {
        if let number = UserDefaults.standard.object(forKey: Settings.Keys.units) as? NSNumber {
            units = Units(rawValue: number.intValue)!
        } else {
            units = Units(rawValue: (Locale.current.usesMetricSystem as NSNumber).intValue)!
        }
    }
}
