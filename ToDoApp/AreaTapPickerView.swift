//
//  AreaTapPickerView.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 1/16/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import UIKit

class AreaTapPickerView: UIPickerView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 8
        let area = bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
}
