//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Marcin Olek on 30.01.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
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
        //println("digit = \(digit)")
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
        history.text = brain.description
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
        let c = count(self.display!.text!)
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
        history.text = " "
    }
    
    @IBAction func mPressed(sender: AnyObject) {
        displayValue = brain.pushOperand("M")
    }
    
    @IBAction func setMPressed(sender: AnyObject) {
        brain.variableValues["M"] = displayValue
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.evaluate()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if(identifier == "Show Chart") {
                
                if let gvc = segue.destinationViewController as? GraphViewController {
                    gvc.program = brain.program
                    gvc.programDescription = brain.description.componentsSeparatedByString(", ").last
                }
                
                
                
            }
        }
    }
}

