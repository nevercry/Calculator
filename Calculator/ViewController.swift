//
//  ViewController.swift
//  Calculator
//
//  Created by nevercry on 7/28/15.
//  Copyright (c) 2015 nevercry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        history.text = history.text! + digit
        
        if userIsInTheMiddleOfTypingANumber {
            if (digit == "." && display.text!.rangeOfString(".") != nil) {
                return
            }
            display.text = display.text! + digit
        } else {
            if (digit == ".") {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    var operationStr = ""
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        operationStr = operation
        
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π": performOperation(M_PI)
        default: break
        }
        
    }
    
    func performOperation(operation:(Double,Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
            
            history.text = history.text! + operationStr + " " + "=" + "    "
        }
    }
    
   private func performOperation(operation:Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
            
            history.text = history.text! + operationStr + " " + "=" + "    "
        }
    }
    
    private func performOperation(newValue:Double){
        displayValue = newValue
        enter()
        
        history.text = history.text! + operationStr + " " + "=" + "    "
    }
    
    var  operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("operandStack = \(operandStack)")
        
        history.text = history.text! + " "
    }
    
    @IBAction func clear(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.removeAll(keepCapacity: false)
        history.text = ""
        display.text = "0"
    }
    
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

