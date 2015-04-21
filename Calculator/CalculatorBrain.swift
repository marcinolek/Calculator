//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Marcin Olek on 24.02.2015.
//  Copyright (c) 2015 Marcin Olek. All rights reserved.
//

import Foundation

class CalculatorBrain : Printable
{
    private enum Op : Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        case Variable(String)
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(let symbol, _):
                    switch symbol {
                    case "×":
                        return 10
                    case "÷":
                        return 10
                    case "+":
                        return 9
                    case "-":
                        return 9
                    default:
                        return Int.max
                    }
                default:
                    return 0
                }
            }
        }
    }

    var description: String {
        get {
            var (result, ops) = ("", opStack)
            while ops.count > 0 {
                var desc: String
                var resultString = ""
                if let evaluationResult = evaluate(ops).result {
                    resultString = " = \(evaluationResult)"
                }
                (ops, desc, _) = describe(ops, desc: "", precedence: 0)
                
                result = result == "" ? desc + resultString : "\(desc), \(result)"
            }
            return result
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String : Double]()
    
    var M : Double = 0
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.Constant("π", M_PI))
    }
    typealias PropertyList = AnyObject
    var program : PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                var numberFormatter = NSNumberFormatter()
                numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let variable = variableValues[opSymbol] {
                        newOpStack.append(.Variable(opSymbol))
                    } else if let operant = numberFormatter.numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operant))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    private func describe(ops: [Op], desc: String, precedence: Int) -> (remainingOps: [Op], desc: String, prec: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
           
            //println("remaining ops: \(remainingOps.count)")
            var currentDescription = desc
            switch op {
            case .Operand(let operand):
                return (remainingOps, "\(operand)", op.precedence)
            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = describe(remainingOps, desc: currentDescription, precedence: op.precedence)
                return (operandEvaluation.remainingOps," \(symbol)(\(operandEvaluation.desc))",op.precedence)//))=\(operation(operand))")
            case .BinaryOperation(let symbol, let operation):
                let op1Evaluation = describe(remainingOps, desc: currentDescription, precedence: op.precedence)
                if op1Evaluation.remainingOps.count > 0 {
                    let op2Evaluation = describe(op1Evaluation.remainingOps, desc: currentDescription, precedence: op1Evaluation.prec)
                    let parenthesisRequired = (precedence > op.precedence)
                    return (op2Evaluation.remainingOps, (parenthesisRequired ? "(" : "") + " \(op2Evaluation.desc)\(symbol) \(op1Evaluation.desc)" + (parenthesisRequired ? ")" : ""),op2Evaluation.prec)
                } else {
                    return (op1Evaluation.remainingOps, " ? \(symbol) \(op1Evaluation.desc)",op1Evaluation.prec)
                }
            case .Constant(let symbol, let operation):
                return (remainingOps, currentDescription + "\(symbol)",op.precedence)
            case .Variable(let symbol):
                return (remainingOps, currentDescription + "\(symbol)",op.precedence)
            }
        }
        return (ops, "?", Int.max)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let operation):
                return (operation, remainingOps)
            case .Variable(let symbol):
                if let op2 = variableValues[symbol] {
                    return (op2, remainingOps)
                }
                return (nil, remainingOps)
                
            }
            
        }
        return (nil, ops)
    }
    
    func clear() {
        opStack = [Op]()
        variableValues = [String : Double]()
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over")
        //println("DESC: " + self.description)
        return result
    }
    
}