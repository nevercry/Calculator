//
//  ViewController.swift
//  Calculator
//
//  Created by nevercry on 7/28/15.
//  Copyright (c) 2015 nevercry. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private var userIsInTheMiddleOfTypingANumber = false
    private var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display.text = " "
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        history.text = history.text! + digit
        
        if userIsInTheMiddleOfTypingANumber {
            if (digit == "." && display.text!.rangeOfString(".") != nil) {
                return
            }
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")) {
                return
            }
            if (digit != ".") && ((display.text == "0") || (display.text == "-0")) {
                if (display.text == "0") {
                    display.text = digit
                } else {
                    display.text = "-" + digit
                }
            } else {
                display.text = display.text! + digit
            }
        } else {
            if (digit == ".") {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
            history.text = brain.description != "?" ? brain.description : ""
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if let operation = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                if operation == "±" {
                    let displayText = display.text!
                    if (displayText.rangeOfString("-") != nil) {
                        display.text = String(displayText.characters.dropFirst())
                    } else {
                        display.text = "-" + displayText
                    }
                    return
                }
                enter()
            }
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                // error?
                displayValue = nil
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                // error?
                displayValue = nil
            }
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain = CalculatorBrain()
        history.text = ""
        displayValue = nil
    }
    
    @IBAction func backSpace() {
        if userIsInTheMiddleOfTypingANumber {
            let displayText = display.text!
            if displayText.characters.count > 1 {
                display.text = String(displayText.characters.dropLast())
                if (displayText.characters.count == 2) && (display.text?.rangeOfString("-") != nil) {
                    display.text = "-0"
                }
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func storeVariable(sender: UIButton) {
        if let variable = (sender.currentTitle!).characters.last {
            if displayValue != nil {
                brain.variableValues["\(variable)"] = displayValue
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if (newValue != nil) {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .DecimalStyle
                numberFormatter.maximumFractionDigits = 10
                display.text = numberFormatter.stringFromNumber(newValue!)
            } else {
                if let result = brain.evaluateAndReportErrors() as? String {
                    display.text = result
                } else {
                    display.text = " "
                }
                
            }
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description != "" ? brain.description + " =" : ""
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController
        if let nc = destination as? UINavigationController {
            destination = nc.visibleViewController!
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "plot graph":
                    gvc.title = brain.description == "" ? "Graph" : brain.description.componentsSeparatedByString(", ").last
                    gvc.program = brain.program
                default:
                    break
                }
            }
        }
    }
}

