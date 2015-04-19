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

@IBDesignable
class GraphView: UIView {

    var axesDrawer = AxesDrawer(color: UIColor.blueColor())
    
    var definedOrigin: CGPoint?
    
    var origin: CGPoint {
        get {
            if definedOrigin != nil {
                return definedOrigin!
            } else {
                return CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            }
        }
        set {
            definedOrigin = newValue
            setNeedsDisplay()
        }
    }
    
    var dataSource: GraphViewDataSource?
    @IBInspectable
    var scale: CGFloat = 1 {
        didSet {
            axesDrawer.contentScaleFactor = scale
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        println("origin \(origin)")
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
    }
    
    @IBAction func handlePinch(var recognizer: UIGestureRecognizer?) {
        if let pinchGestureRecognizer = recognizer as? UIPinchGestureRecognizer {
            if(pinchGestureRecognizer.state == .Changed) {
                scale = scale * pinchGestureRecognizer.scale
                pinchGestureRecognizer.scale = 1
            }
        }
    }
    
    @IBAction func handlePan(var recognizer: UIPanGestureRecognizer?) {
        if let panGestureRecognizer = recognizer {
            if(panGestureRecognizer.state == .Changed) {
                var translation = panGestureRecognizer.translationInView(self)
                origin += (translation)
                panGestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)
            }
        }
    }
    
    @IBAction func handleDoubleTap(recognizer: UITapGestureRecognizer?) {
        if let tapGestureRecognizer = recognizer {
            if tapGestureRecognizer.state == .Ended {
                origin = tapGestureRecognizer.locationInView(self)
            }
        }
    }
}


infix operator + { associativity left precedence 140 }
func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

infix operator += { associativity left precedence 140 }
func +=(inout left: CGPoint, right: CGPoint) {
    left = left + right
}

infix operator / { associativity left precedence 140 }
func /(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

infix operator /= { associativity left precedence 140 }
func /(inout left: CGPoint, right: CGFloat) {
    left = left / right
}

