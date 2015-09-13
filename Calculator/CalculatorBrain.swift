//
//  CalculatorBrain.swift
//  
//
//  Created by nevercry on 7/31/15.
//
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case NullaryOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        case BinaryOperation(String, Int, (Double, Double) -> Double, ((Double, Double) -> String?)?)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .NullaryOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(_, let precedence, _, _):
                    return precedence
                default:
                    return Int.max
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String: Double]()
    
    private var error: String?
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", 2, *, nil))
        learnOp(Op.BinaryOperation("÷", 2, { $1 / $0 } , { divisor, _ in return divisor == 0.0 ? "Divison by zero" : nil }))
        learnOp(Op.BinaryOperation("+", 1, +, nil))
        learnOp(Op.BinaryOperation("−", 1, { $1 - $0 }, nil))
        learnOp(Op.UnaryOperation("√", sqrt, { $0 < 0 ? "SQRT of Neg. Number" : nil}))
        learnOp(Op.UnaryOperation("sin", sin, nil))
        learnOp(Op.UnaryOperation("cos", cos, nil))
        learnOp(Op.UnaryOperation("±", { -$0 }, nil))
        learnOp(Op.NullaryOperation("π", { M_PI }))
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {// guaranteed to be p PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        get {
            var (result, ops) = ("", opStack)
            while ops.count > 0 {
                var current:String?
                (current, ops, _) = description(ops)
                result = result == "" ? current! : "\(current!),\(result)"
            }
            
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op], precedence: Int?) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (String(format: "%g", operand) , remainingOps, op.precedence)
            case .NullaryOperation(let symbol, _):
                return (symbol, remainingOps, op.precedence)
            case .UnaryOperation(let symbol, _, _):
                let operandEvaluation = description(remainingOps)
                if var operand = operandEvaluation.result {
                    if op.precedence > operandEvaluation.precedence {
                        operand = "(\(operand))"
                    }
                    
                    return ("\(symbol)\(operand)", operandEvaluation.remainingOps, op.precedence)
                }
            case .BinaryOperation(let symbol, _, _, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result {
                    if op.precedence > op1Evaluation.precedence {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps, op.precedence)
                    }
                }
            case .Variable(let symbol):
                return (symbol, remainingOps, op.precedence)
            }
        }
        
        return ("?", ops, Int.max)
    }
    
    
    private func evaluate(ops: [Op]) -> (result: Double? , remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation, let errorTest):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    if let errorMessage = errorTest?(operand) {
                        error = errorMessage
                        return (nil, operandEvaluation.remainingOps)
                    }
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation, let errorTest):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        if let errorMessage = errorTest?(operand1, operand2) {
                            error = errorMessage
                            return (nil, op2Evaluation.remainingOps)
                        }
                        return (operation(operand1,operand2),op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                if let variableV = variableValues[symbol] {
                    return (variableV, remainingOps)
                }
                
                error = "Variable Not Set"
                return (nil, remainingOps)
            }
            
            if error == nil {
                error = "Not Enough Operands"
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand:Double) -> Double? {
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
}
