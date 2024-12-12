//
//  UserMessaging.swift
//  Heavier
//
//  Created by Eric Schulte on 12/11/24.
//

import Foundation
import Combine
import SwiftUI

@Observable class UserFeatureMessaging: Publisher {
    
    typealias Output = Feature
    typealias Failure = Never
    
    // Subject to manage the sending of values
    private let featureSubject = PassthroughSubject<Feature, Never>()
    
    var features = [Feature: Int]()
    
    // Conformance to Publisher
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        featureSubject.receive(subscriber: subscriber)
    }
    

    enum Trigger {
        case appDidForeground
    }
    
    enum Feature: String, CaseIterable {
        case siri
        
        var eventsRequired: Int {
            switch self {
            case .siri:
                return 2
            }
        }
        
        var trigger: Trigger {
            switch self {
            case .siri:
                return .appDidForeground
            }
        }
    }
    
    static let shared = UserFeatureMessaging()
    private var appDidForegroundPublisher: AnyCancellable?
    
    init() {
        appDidForegroundPublisher = NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.processFeatures(trigger: .appDidForeground)
            }
        processFeatures(trigger: .appDidForeground)
    }
    
    private static let userDefaultsKey = "features"
    
    typealias FeatureDict = [Feature: Int]
    
    private func processFeatures(trigger: Trigger) {
        let savedDefaults = UserDefaults.standard.dictionary(forKey: UserFeatureMessaging.userDefaultsKey)
        if let savedDefaults = savedDefaults {
            var features: FeatureDict = Dictionary(
                uniqueKeysWithValues: savedDefaults.compactMap { (key, value) in
                    if let enumKey = Feature(rawValue: key) {
                        return (enumKey, value) as? (UserFeatureMessaging.Feature, Int)
                    }
                    return nil
                }
            )
            guard let featuresDefault = Dictionary(uniqueKeysWithValues: Feature.allCases.filter {
                $0.trigger == trigger
            }.map { ($0, 0) }) as? FeatureDict else { return }
            features = features.mapValues {
                $0 + 1
            }
            features.merge(featuresDefault) { first, second in
                return first
            }
            features.forEach { key, value in
                if key.eventsRequired == value {
                    featureSubject.send(key)
                }
            }
            
            save(features: features)
        } else {
            let features = Dictionary(uniqueKeysWithValues: Feature.allCases.map { ($0, 0) }) as? FeatureDict
            save(features: features)
        }
    }
    
    private func save(features: FeatureDict?) {
        guard let features = features else {
            return
        }
        UserDefaults.standard.set(
            Dictionary(
                uniqueKeysWithValues: features.map { (key, value) in
                    (key.rawValue, value)
                }
            ),
            forKey: UserFeatureMessaging.userDefaultsKey
        )
        self.features = features
    }
}
