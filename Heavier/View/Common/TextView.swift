//
//  TextInput.swift
//  Heavier
//
//  Created by Eric Schulte on 12/26/20.
//

import Foundation
import UIKit
import SwiftUI

struct TextView: UIViewRepresentable {
    
    internal class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        var becomeFirstResponder: Bool
        
        init(text: Binding<String>, becomeFirstResponder: Bool) {
            _text = text
            self.becomeFirstResponder = becomeFirstResponder
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            text = textView.text ?? ""
        }
    }
    
    var becomeFirstResponder: Bool
    var backgroundColor: UIColor = .white
    @Binding var text: String
    
    typealias UIViewType = UITextView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, becomeFirstResponder: becomeFirstResponder)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let textView = UITextView(frame: .zero)
        textView.delegate = context.coordinator
        textView.font = UIFont(
            name: Theme.Font.SFCompactDisplay.Variation.medium.rawValue,
            size: Theme.Font.Size.large
        )
        textView.backgroundColor = backgroundColor
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            textView.becomeFirstResponder()
        }
        return textView
    }
}

extension TextView {
    func backgroundColor(_ color: UIColor) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }
}
