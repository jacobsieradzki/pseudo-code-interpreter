//
//  RepeatUntilInstruction.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 28/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

// This class represents an instruction in the form:
// REPEAT
//    code
// UNTIL boolVal

class RepeatInstruction: Instruction {}

class RepeatUntilInstruction: Instruction {
  
  var instructions: [Instruction] = []
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case let .repeatUntil(boolExpr) = match {
      performRepeatUntil(usingBoolExpr: boolExpr)
    }
  }
  
  fileprivate func performRepeatUntil(usingBoolExpr boolExpr: String) {
    for instruction in instructions {
      instruction.run()
    }
    if !evaluate(boolExpr: boolExpr) {
      performRepeatUntil(usingBoolExpr: boolExpr)
    }
  }
  
  fileprivate func evaluate(boolExpr: String) -> Bool {
    let substituted = RegexSubstituter(command: boolExpr, variables: Program.shared?.variables).substitute()
    return BooleanExpressionParser(expr: substituted)?.calculate() ?? false
  }

}
