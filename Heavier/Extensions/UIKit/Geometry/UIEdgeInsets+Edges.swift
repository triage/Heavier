//
//  UIEdgeInsets+Edges.swift
//  Heavier
//
//  Created by Eric Schulte on 1/3/21.
//

import Foundation
import UIKit

extension UIEdgeInsets {
    var horizontal: CGFloat {
        left + right
    }
    
    var vertical: CGFloat {
        top + bottom
    }
}
