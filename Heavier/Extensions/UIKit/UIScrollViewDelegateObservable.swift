//
//  UIScrollViewDelegateObservable.swift
//  Heavier
//
//  Created by Eric Schulte on 1/11/21.
//

import Foundation
import UIKit
import Combine

class UIScrollViewDelegateObservable: NSObject, UIScrollViewDelegate, ObservableObject {
    
    @Published var offset: CGPoint = .zero
    @Published var isDragging: Bool = false
    @Published var isDecelerating: Bool = false
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
        isDecelerating = false
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isDecelerating = true
        isDragging = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        isDecelerating = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isDecelerating = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        offset = scrollView.contentOffset
    }
}
