//
//  GraphView.swift
//  Calculator
//
//  Created by Marcin Olek on 19.04.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    
}

class GraphView: UIView {

    var axesDrawer = AxesDrawer(color: UIColor.blueColor())
    
    var origin: CGPoint {
        return CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    var dataSource: GraphViewDataSource?
    
    var scale: CGFloat = 1 {
        didSet {
            axesDrawer.contentScaleFactor = scale
        }
    }
    
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: 30)
    }
    
}
