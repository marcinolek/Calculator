//
//  GraphViewController.swift
//  Calculator
//
//  Created by Marcin Olek on 19.04.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
   
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView?.dataSource = self
        }
    }
    
}
