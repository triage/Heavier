//
//  Lifts.swift
//  Heavier
//
//  Created by Eric Schulte on 12/29/20.
//

import Foundation
import SwiftUI
import Combine

struct Lifts<Content>: View where Content: View {
    @ObservedObject var liftsObservable: LiftsObservable
    var sections = [LiftsSection]()
    var lifts = [Lift]()
    let content: ([LiftsSection], [Lift]) -> Content
    @State var liftsSubscriber: AnyCancellable?
    @State var first = false
    
    init(dateComponents: DateComponents, @ViewBuilder content: @escaping ([LiftsSection], [Lift]) -> Content) {
        liftsObservable = LiftsObservable(dateComponents: dateComponents)
        self.content = content
        sections = liftsObservable.sections
        lifts = liftsObservable.lifts
    }

    init(exercise: Exercise?, ascending: Bool = true, @ViewBuilder content: @escaping ([LiftsSection], [Lift]) -> Content) {
        liftsObservable = LiftsObservable(exercise: exercise, ascending: ascending)
        self.content = content
        sections = liftsObservable.sections
        lifts = liftsObservable.lifts
    }
    
    var body: some View {
        content(sections, lifts)
        .onAppear {
            sections = liftsObservable.sections
            lifts = liftsObservable.lifts
            first = false
        }
    }
}
