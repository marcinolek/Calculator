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
    
    
    
    internal func valueForDataPoint(#point: Double) -> Double? {
        brain.variableValues["M"] = point
        return brain.evaluate()
    }
    
}
