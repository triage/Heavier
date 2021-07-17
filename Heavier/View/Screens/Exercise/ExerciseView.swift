//
//  ExerciseView.swift
//  Overload
//
//  Created by Eric Schulte on 9/27/20.
//

import Foundation
import SwiftUI
import CoreData
import Introspect
import UIKit
import Combine

class ScrollState: ObservableObject {
    @Published var calendarButtonIsVisible = false
    @Published var calendarIsFloating = false
    @Published var calendarYOffset: CGFloat = 0.0
}

struct ExerciseView: View {
    let exercise: Exercise
    
    @State private var liftViewPresented = false
//    @State private var calendarButtonIsVisible = false
//    @State private var calendarIsFloating = false
//    @State private var calendarYOffset: CGFloat = 0.0
    @State private var calendaryUnderlayOpacity: Double = 0.0
    @State private var dateSelected: Date?
    
    @StateObject private var lifts: LiftsObservable
    
    @StateObject private var scrollState = ScrollState()
    
    // swiftlint:disable:next weak_delegate
    @StateObject private var scrollViewDelegate = UIScrollViewDelegateObservable()
    
    private static let showCalendarButtonAtScrollOffset: CGFloat = 330.0
    private static let animationDuration: TimeInterval = 0.24
    
    init?(exercise: Exercise?) {
        guard let exercise = exercise else {
            return nil
        }
        self.exercise = exercise
        
        _lifts = .init(
            wrappedValue: LiftsObservable(exercise: exercise, ascending: false)
        )
    }
    
    private func onScroll(value: CGPoint) {
//        return
        if scrollState.calendarIsFloating {
            if scrollViewDelegate.isDragging {
                withAnimation(.easeIn(duration: ExerciseView.animationDuration)) {
                    scrollState.calendarIsFloating.toggle()
                    scrollState.calendarButtonIsVisible.toggle()
                }
            } else {
                guard !scrollViewDelegate.isDragging && !scrollViewDelegate.isDecelerating else {
                    return
                }
                withAnimation(.easeIn(duration: ExerciseView.animationDuration)) {
                    scrollState.calendarIsFloating.toggle()
//                    calendaryUnderlayOpacity = 0.0
                    if scrollState.calendarButtonIsVisible == false {
                        scrollState.calendarButtonIsVisible.toggle()
                    }
                }
            }
        } else if value.y > ExerciseView.showCalendarButtonAtScrollOffset && !scrollState.calendarButtonIsVisible {
            // show the calendar button
            withAnimation(.easeOut(duration: ExerciseView.animationDuration)) {
                scrollState.calendarButtonIsVisible.toggle()
            }
        } else if
            value.y < ExerciseView.showCalendarButtonAtScrollOffset &&
                scrollState.calendarButtonIsVisible {
            // hide the calendar button
            withAnimation(.easeIn(duration: ExerciseView.animationDuration)) {
                scrollState.calendarButtonIsVisible.toggle()
            }
        }
    }
    
    private func onTopCalendarButton() {
        withAnimation(.easeInOut(duration: ExerciseView.animationDuration)) {
            scrollState.calendarIsFloating.toggle()
            calendaryUnderlayOpacity = 1.0
        }
    }
    
    private func onTapUnderlay() {
        withAnimation(.easeInOut(duration: ExerciseView.animationDuration)) {
            scrollState.calendarIsFloating.toggle()
            calendaryUnderlayOpacity = 0.0
            scrollState.calendarButtonIsVisible.toggle()
        }
    }
    
    private func onDateChanged(date: Date?) {
        if scrollState.calendarIsFloating {
            withAnimation(.easeInOut(duration: ExerciseView.animationDuration)) {
                scrollState.calendarIsFloating.toggle()
                calendaryUnderlayOpacity = 0.0
                scrollState.calendarButtonIsVisible.toggle()
            }
        }
    }
    
    private var scrollViewContentOffset: CGFloat {
        scrollViewDelegate.offset.y
    }
    
    private var calendarOffset: CGFloat {
        if scrollState.calendarIsFloating {
            return scrollViewContentOffset + 90
        } else {
            return scrollViewContentOffset > LiftsCalendarView.frameHeight ?
                scrollViewContentOffset - LiftsCalendarView.calendarHeight : 0.0
        }
    }
    
    var shadowOpacity: Double {
        scrollState.calendarIsFloating ? 0.12 : 0.0
    }
    
    var body: some View {
        print("new exercise view")
        return ScrollView {
            ZStack(alignment: .topLeading) {
                if lifts.lifts.count > 0 {
                    
                    OlderLifts(
                        exercise: exercise,
                        dateSelected: dateSelected
                    )
                    
                    BlackOverlay(visible: scrollState.calendarIsFloating)
                        .opacity(calendaryUnderlayOpacity)
                        .offset(x: 0.0, y: scrollViewContentOffset)
                        .onTapGesture {
                            onTapUnderlay()
                        }
                   
                    // If we add .shadow to ExerciseCalendar, touch events don't register
                    // when we change the offset. This view is only intended to add a shadow
                    Group {
                        Spacer()
                    }
                    .frame(
                        width: ExerciseCalendar.screenWidth,
                        height: LiftsCalendarView.frameHeight
                    )
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.blue)
                    .offset(x: 0, y: scrollViewContentOffset)
                    .clipped()
                    .shadow(
                        color: Color.black.opacity(shadowOpacity),
                        radius: 3.0, x: 0.0, y: 3.0
                    )
                    
                    EquatableView(content:
                        ExerciseCalendar(
                            lifts: $lifts.lifts,
                            dateSelected: $dateSelected
                        )
                    )
                    .offset(x: 0, y: calendarOffset)
                    
                } else {
                    Text("No lifts recorded yet")
                        .offset(x: Theme.Spacing.large, y: Theme.Spacing.medium)
                        .sfCompactDisplay(.regular, size: Theme.Font.Size.large)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0/*@END_MENU_TOKEN@*/,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                }
            }
        }
        .introspectScrollView { scrollView in
            let delegate = scrollView.delegate
            print("delegate:\(delegate)")
            scrollView.delegate = scrollViewDelegate
        }
        .didScroll({ point in
            scrollViewDelegate.offset = point
            print("point:\(point)")
        })
        .onChange(of: dateSelected, perform: onDateChanged)
        .onChange(of: scrollViewDelegate.offset, perform: onScroll)
        .overlay(
            CalendarButton {
                scrollState.calendarButtonIsVisible.toggle()
                onTopCalendarButton()
            }
            .opacity(scrollState.calendarButtonIsVisible ? 1.0 : 0.0)
            .offset(x: -20, y: scrollState.calendarButtonIsVisible ? 30 : -50), alignment: .topTrailing)
        
        .navigationTitle(exercise.name!)
        .toolbar(
            content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        liftViewPresented = true
                    }, label: {
                        Image(systemName: "plus")
                            .font(.system(size: Theme.Font.Size.large))
                    })
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    // This is stupid. If I don't put this here, after
                    // saving a new item to the context, the back button
                    // disappears. Possible Apple bug.
                    Text("")
                }
            }
        ).sheet(isPresented: $liftViewPresented) {
            LiftView(exercise: exercise, lift: lifts.lifts.first, presented: $liftViewPresented)
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    
    static var previews: some View {
        Settings.shared.units = .metric
        
        let exercise = Exercise(context: PersistenceController.shared.container.viewContext)
        exercise.name = "Romanian Deadlift"
        exercise.id = UUID()
        var lifts = [Lift]()
        let secondsPerDay: TimeInterval = 60 * 60 * 24
        for _ in [Date(), Date().addingTimeInterval(secondsPerDay), Date().addingTimeInterval(secondsPerDay * 60)] {
            for index in 0...100 {
                let lift = Lift(context: PersistenceController.shared.container.viewContext)
                lift.reps = 10
                lift.sets = 1
                lift.notes = "Light weight, baby!"
                lift.weight = 20
                lift.id = UUID()
                lift.timestamp = Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * index))
                lifts.append(lift)
            }
        }
        exercise.lifts = NSOrderedSet(array: lifts)
        
        let exerciseNoLifts = Exercise(context: PersistenceController.shared.container.viewContext)
        exerciseNoLifts.name = "Romanian Deadlift"
        exerciseNoLifts.id = UUID()
        
        let exerciseBodyweight = Exercise(context: PersistenceController.shared.container.viewContext)
        exerciseBodyweight.name = "Romanian Deadlift"
        exerciseBodyweight.id = UUID()
        
        lifts.removeAll()
        for index in 0...30 {
            let lift = Lift(context: PersistenceController.shared.container.viewContext)
            lift.reps = 10 + Int16(index)
            lift.sets = 2
            lift.weight = 0
            lift.id = UUID()
            lift.timestamp = Date().addingTimeInterval(60 * 60 * 12)
            lifts.append(lift)
        }
        exerciseBodyweight.lifts = NSOrderedSet(array: lifts)
        
        return Group {
            NavigationView {
                ExerciseView(
                    exercise: exercise
                )
            }
            NavigationView {
                ExerciseView(
                    exercise: exerciseNoLifts
                )
            }
            NavigationView {
                ExerciseView(
                    exercise: exerciseBodyweight
                )
            }
        }
    }
}



struct ScrollViewDidScrollViewModifier: ViewModifier {
  class ViewModel: ObservableObject {
    @Published var contentOffset: CGPoint = .zero
    
    var contentOffsetSubscription: AnyCancellable?
    
    func subscribe(scrollView: UIScrollView) {
      contentOffsetSubscription = scrollView.publisher(for: \.contentOffset).sink { [weak self] contentOffset in
        self?.contentOffset = contentOffset
      }
    }
  }

  @StateObject var viewModel = ViewModel()
  var didScroll: (CGPoint) -> Void
  
  func body(content: Content) -> some View {
    content
      .introspectScrollView { scrollView in
        if viewModel.contentOffsetSubscription == nil {
          viewModel.subscribe(scrollView: scrollView)
        }
      }
      .onReceive(viewModel.$contentOffset) { contentOffset in
        didScroll(contentOffset)
      }
  }
}

extension View {
  func didScroll(_ didScroll: @escaping (CGPoint) -> Void) -> some View {
    self.modifier(ScrollViewDidScrollViewModifier(didScroll: didScroll))
  }
}
