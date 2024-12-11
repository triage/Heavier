//
//  SiriGuideView.swift
//  Heavier
//
//  Created by Eric Schulte on 12/10/24.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func `if`<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T : View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct RoundedRectText: View {
    let text: String
    let fullWidth: Bool
    init(text: String, fullWidth: Bool = false) {
        self.text = text
        self.fullWidth = fullWidth
    }
    var body: some View {
        Text(text)
            .if(fullWidth, transform: { view in
                view.frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            })
            .allowsTightening(true)
            .foregroundStyle(.primary)
            .padding(Theme.Spacing.edgesDefault)
            .background(.ultraThickMaterial)
            .cornerRadius(Theme.Spacing.giga)
    }
}

struct FadeInView<Content: View>: View {
    let delay: Double
    let content: Content
    @State private var isVisible: Bool = false

    init(delay: Double, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }

    var body: some View {
        content
            .offset(y: isVisible ? 0 : 20) // Animate Y offset
            .opacity(isVisible ? 1 : 0) // Start fully transparent
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.8)) {
                        isVisible = true
                    }
                }
            }
    }
}

public struct SiriGuideView: View {
    
    private let reasons = [
        String(localized: "Barbell deadlift, 3 sets of 10, 225 pounds"),
        String(localized: "6 reps of leg press at 400 pounds"),
        String(localized: "Back squat, 3 sets of 6 reps, 185 pounds"),
    ]
    
    @Binding var didAcknowledgeSiriAnnouncement: Bool
    
    public var body: some View {
        VStack {
            Spacer()
            FadeInView(delay: 0.2) {
                RoundedRectText(text: String(localized: "Heavier works hands-free with Siri"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sfCompactDisplay(.medium, size: 18)
                    .padding(.horizontal, Theme.Spacing.edgesDefault)
                    .padding(.bottom, Theme.Spacing.small)
            }
            FadeInView(delay: 0.8) {
                RoundedRectText(text: String(localized: "\"Record a lift in Heavier\""), fullWidth: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .sfCompactDisplay(.bold, size: 32)
                    .padding(.horizontal, Theme.Spacing.edgesDefault)
                    .padding(.bottom, 40.0)
            }
            
            VStack {
                FadeInView(delay: 1.4) {
                    RoundedRectText(text: String(localized: "Just say ..."))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .sfCompactDisplay(.medium, size: 14)
                        .padding(.horizontal, Theme.Spacing.edgesDefault)
                        .padding(.bottom, Theme.Spacing.small)
                }
                ForEach(Array(reasons.enumerated()), id: \.offset) { index, reason in
                    FadeInView(delay: 0.3 * Double(index) + 1.8) {
                        RoundedRectText(text: "\"\(reason)\"")
                            .foregroundStyle(.secondary)
                            .sfCompactDisplay(.regular, size: 20.0)
                            .padding(.bottom, Theme.Spacing.medium)
                            .frame(maxWidth: .infinity, alignment: index % 2 == 0 ? .leading : .trailing)
                    }

                }
            }.padding(.horizontal, Theme.Spacing.edgesDefault)
            FadeInView(delay: 3.0) {
                Button(action: {
                    didAcknowledgeSiriAnnouncement = true
                }, label: {
                    LiftButton(
                        text: String(localized: "Sounds good!"),
                        imageName: "hand.thumbsup.fill",
                        imageNameTrailing: "xmark",
                        backgroundColor: Color(.highlight)
                    )
                })
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}
