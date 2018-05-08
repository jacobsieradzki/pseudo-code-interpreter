//
//  WhileInstruction.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 01/03/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

// This class represents an instruction in the form:
// WHILE boolVal
//    code
// END WHILE

class WhileInstruction: Instruction {
  
  var instructions: [Instruction] = []
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case let .whileStart(boolExpr) = match {
      performWhile(usingBoolExpr: boolExpr)
    }
  }
  
  fileprivate func performWhile(usingBoolExpr boolExpr: String) {
    if evaluate(boolExpr: boolExpr) {
      for instruction in instructions {
        instruction.run()
      }
      performWhile(usingBoolExpr: boolExpr)
    }
  }
  
  fileprivate func evaluate(boolExpr: String) -> Bool {
    let substituted = RegexSubstituter(command: boolExpr, variables: Program.shared?.variables).substitute()
    return BooleanExpressionParser(expr: substituted)?.calculate() ?? false
  }
  
}

class EndWhileInstruction: Instruction {}
