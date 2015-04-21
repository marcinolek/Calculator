//
//  GraphView.swift
//  Calculator
//
//  Created by Marcin Olek on 19.04.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func pointForValue(#val: Double) -> CGPoint?
}

@IBDesignable
class GraphView: UIView {

    var axesDrawer = AxesDrawer(color: UIColor.blueColor())
    
    var definedOrigin: CGPoint?
    
    var color = UIColor.redColor()
    
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
        //println("origin \(origin)")
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
        
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        color.set()
        let path = UIBezierPath()
        
        var lastValue: CGPoint?
        for var x = 0.0; x <= Double(rect.width); x++ {
            //println("   x:\(x)")
            if let value = dataSource?.pointForValue(val:x) {
                //println("   y:\(value)")
                if let ldp = lastValue {
                    if ldp.y.isNormal || ldp.y.isZero {
                        if let newPoint = alignedPoint(x: CGFloat(value.x), y: CGFloat(value.y), insideBounds: rect) {
                            path.addLineToPoint(newPoint)
                            //println("drawing line to \(newPoint)")
                        } else {
                            if((value.x.isZero || value.x.isNormal)&&(value.y.isZero || value.y.isNormal))
                            {
                                path.moveToPoint(value)
                            }
                        }
                    } else {
                        if let newPoint = alignedPoint(x: CGFloat(value.x), y: CGFloat(value.y), insideBounds: rect) {
                            path.moveToPoint(newPoint)
                            //println("moving line to \(newPoint)")
                        } else {
                            if((value.x.isZero || value.x.isNormal)&&(value.y.isZero || value.y.isNormal))
                                {
                                    path.moveToPoint(value)
                            }
                        }
                    }
                } else {
                    if let newPoint = alignedPoint(x: CGFloat(value.x), y: CGFloat(value.y), insideBounds: rect) {
                        path.moveToPoint(newPoint)
                        //println("moving line to \(newPoint)")
                    } else {
                        if((value.x.isZero || value.x.isNormal)&&(value.y.isZero || value.y.isNormal))
                        {
                            path.moveToPoint(value)
                        }
                    }
                }
                
                lastValue = value
                
                //lastDataPoint = alignedPoint(x: CGFloat(x), y: CGFloat(value), insideBounds: rect)
                
            }

        }
        path.stroke()
        CGContextRestoreGState(UIGraphicsGetCurrentContext())
        
    }
    
    private func alignedPoint(#x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
     let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, point)) {
                return nil
            }
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * scale) / scale
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

