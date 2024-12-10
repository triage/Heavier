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
        
        init(measurementSystem: Locale.MeasurementSystem) {
            switch (measurementSystem) {
            case .metric:
                self = .metric
            default:
                self = .imperial
            }
        }
        
        var description: String {
            switch self {
            case .imperial:
                return String(localized: "Imperial (lb)", comment: "Settings - Units - Imperial")
            case .metric:
                return String(localized: "Metric (kg)", comment: "Settings - Units - Metric")
            }
        }
        
        // swiftlint:disable:next identifier_name
        var id: Int {
            rawValue   
        }
        
        var maxWeight: Float {
            switch self {
            case .imperial:
                return 700
            case .metric:
                return 320
            }
        }
        
        var interval: Float {
            switch self {
            case .imperial:
                return 5
            case .metric:
                return 2.5
            }
        }
        
        var defaultWeight: Float {
            switch self {
            case .imperial:
                return 45
            case .metric:
                return 20
            }
        }
        
        var label: String {
            switch self {
            case .imperial:
                return String(localized: "lb", comment: "Pounds (abbreviation")
            case .metric:
                return String(localized: "kg", comment: "Kilograms (abbreviation")
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
            units = Units(measurementSystem: Locale.current.measurementSystem)
        }
    }
}
