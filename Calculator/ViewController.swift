//
//  ViewController.swift
//  Calculator
//
//  Created by Marcin Olek on 30.01.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        if display.text!.rangeOfString(".") != nil && digit == "." && userIsInTheMiddleOfTypingANumber { return }
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        println("digit = \(digit)")
    }
    

    
    @IBOutlet weak var history: UILabel!
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var displayValue: Double! {
        get {
            var numberFormatter = NSNumberFormatter()
            numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let number = numberFormatter.numberFromString(display.text!)
            if let number = numberFormatter.numberFromString(display.text!) {
                return number.doubleValue
            } else {
                return nil
            }
        }

        set {
            if let nv = newValue {
                display.text = "\(nv)"
                history.text = brain.description
                
            } else {
                display.text = "0"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func operate(sender: UIButton) {

        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        
//            if(userIsInTheMiddleOfTypingANumber) {
//                let fc = first(self.display!.text!)
//                if fc == "-" {
//                    self.display!.text! = dropFirst(self.display!.text!)
//                } else
//                {
//                    self.display!.text! = "-" + self.display!.text!
//                }
//            
//            } else {
//                performOperation { -$0 }
//            }
    }
    
    @IBAction func back(sender: AnyObject)
    {
        let c = countElements(self.display!.text!)
        if c == 1 {
            self.displayValue = nil
            userIsInTheMiddleOfTypingANumber = false
        } else
        if c > 0 {
            self.display!.text = dropLast(self.display!.text!)
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        brain.clear()
        displayValue = nil
    }
    
}

