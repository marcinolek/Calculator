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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    @IBAction func appendDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        if display.text!.rangeOfString(".") != nil && digit == "." && userIsInTheMiddleOfTypingANumber { return }
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        history!.text! += "\(digit) "
        scrollToBottom()
        println("digit = \(digit)")
    }
    
    @IBAction func appendConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        var constantValue = 0.0;
        switch constant {
            case "π":
                constantValue = M_PI
            default:
                return
            
        }
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + "\(constantValue)"
        } else {
            display.text = "\(constantValue)"
            userIsInTheMiddleOfTypingANumber = true
        }
        history!.text! += "\(constant) "
        scrollToBottom()
        println("constant = \(constantValue)")
        
        
        
    }
    
    @IBOutlet weak var history: UITextView!
    
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("operandStack = \(operandStack)")
        
    }
    
    var displayValue: Double {
        get {
            var numberFormatter = NSNumberFormatter()
            numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            return numberFormatter.numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    var operandStack = [Double]()
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        history!.text! += "\(operation)"
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        switch operation {
        case "×":
            performOperation { $0 * $1 }
        case "÷":
            performOperation { $1 / $0 }
        case "+":
            performOperation { $0 + $1 }
        case "−":
            performOperation { $1 - $0 }
        case "√":
            performOperation { sqrt($0) }
        case "sin":
            performOperation { sin($0) }
        case "cos":
            performOperation { cos($0) }
        case "π":
            performOperation(M_PI)
        default:
            break;
            
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double)
    {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            history!.text! += "= \(displayValue)\n"
            scrollToBottom()
            enter()
        }
    }
    
    func performOperation(operation: (Double) -> Double)
    {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            history!.text! += "= \(displayValue)\n"
            scrollToBottom()
            enter()
        }
    }
    
    func performOperation(constant: Double)
    {
        displayValue = constant
        enter()
    }
    
    @IBAction func clear(sender: AnyObject) {
        operandStack = [Double]()
        display.text = "0"
    }
    
    func scrollToBottom() {
        let c = countElements(history!.text!)
        let bottom = NSMakeRange(c - 1 , 1)
        history!.scrollRangeToVisible(bottom)
    }
    
    
}

