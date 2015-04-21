//
//  GraphViewController.swift
//  Calculator
//
//  Created by Marcin Olek on 19.04.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
   
    var programDescription: String?
    
    var program: AnyObject? {
        didSet {
            if let p: AnyObject = program {
                brain.variableValues["M"] = 0
                brain.program = p
            }
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            if let newDescription = programDescription {
                descriptionLabel.text = newDescription
            }
            
        }
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView?.dataSource = self
        }
    }
    
    
    
    internal func pointForValue(#val: Double) -> CGPoint? {
        
        var convertedVal = (val-Double(graphView.origin.x))/Double(graphView.scale)
        //println("ppv \(convertedVal)")
        brain.variableValues["M"] = convertedVal
        var d = brain.evaluate()
        //println("d = \(d)")
        if let y = d {
            return convertPointToViewsCoordinateSystem(point: CGPoint(x: val, y: y))
        } else {
            return nil
        }
        
    }
    
    private func convertPointToViewsCoordinateSystem(#point: CGPoint) -> CGPoint {
        
        var toRet = CGPoint(x: point.x, y: graphView.origin.y - (point.y*graphView.scale))
        //println("converting \(point) to \(toRet)")
        return toRet
    }
    
}
