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
    
    var brain = CalculatorBrain()
    
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
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            displayValue = 0
        }
        history.text = history.text! + " "
    }
    
    @IBAction func clear(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        history.text = ""
        display.text = "0"
    }
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.locale = NSLocale(localeIdentifier: "en_US")
                if let displayNumber = numberFormatter.numberFromString(displayText) {
                    return displayNumber.doubleValue
                }
            }
            return nil
        }
        set {
            if (newValue != nil) {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .DecimalStyle
                numberFormatter.maximumFractionDigits = 10
                display.text = numberFormatter.stringFromNumber(newValue!)
            } else {
                display.text = "0"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

