//
//  ShuntingYardParser.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 06/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

// This class represents the working of the Shunting Yard algorithm

class ShuntingYardParser {
  
  fileprivate let input = Queue<String>()
  fileprivate let tokens = Queue<String>()
  fileprivate let operators = Stack<Operator>()
  fileprivate let output = Queue<String>()
  fileprivate let validOperators = ["+", "-", "*", "/", "%", "(", ")"]
  
  var infix: String {
    var expr = ""
    input.forEach({ expr += $0 + " " })
    return expr
  }
  
  var postfix: String {
    return Polish(q: output).stringValue
  }
  
  init(expr: String) {
    var expr = expr
    if validOperators.contains(String(expr[expr.startIndex])) {
      expr = "0" + expr
    }
    parse(expr: expr)
    convertToPostfix()
  }
  
  func calculate() -> Int {
    return Polish(q: output).calculate()
  }
  
  // MARK: Setup
  
  fileprivate func parse(expr: String) {
    var previousToken = ""
    for character in expr {
      let token = String(character)
      
      if validOperators.contains(token) {
        if !previousToken.isEmpty {
          tokens.enqueue(item: previousToken)
        }
        tokens.enqueue(item: token)
        previousToken = ""
      } else if Int(token) != nil {
        previousToken += token
      }
    }
    
    if !previousToken.isEmpty {
      tokens.enqueue(item: previousToken)
    }
    
    for token in tokens {
      input.enqueue(item: token)
    }
  }
  
  fileprivate func convertToPostfix() {
    while !tokens.isEmpty {
      let token = tokens.dequeue()!
      
      if Int(token) != nil {
        output.enqueue(item: token)
      } else if validOperators.contains(token) {
        let op = Operator(op: token)
        var topOperator = operators.peek()
        
        if token == ")" {
          while topOperator != nil && topOperator!.op != "(" {
            output.enqueue(item: topOperator!.op)
            operators.pop()
            topOperator = operators.peek()
          }
          operators.pop()
        } else if token == "(" {
          operators.push(item: op)
        } else {
          while topOperator != nil && topOperator!.precendence() > op.precendence() {
            output.enqueue(item: topOperator!.op)
            operators.pop()
            topOperator = operators.peek()
          }
          operators.push(item: op)
        }
      }
    }
    
    while (!operators.isEmpty) {
      if let op = operators.pop() {
        output.enqueue(item: op.op)
      }
    }
  }

}
