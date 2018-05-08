//
//  IfInstruction.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 24/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

// This class represents an instruction in the form:
// IF booleanValue THEN
//    code
// END IF

class IfInstruction: Instruction {
  
  var trueBlock: [Instruction] = []
  var falseBlock: [Instruction] = []
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case let .ifStatement(boolVal) = match {
      let instructions = boolVal ? trueBlock : falseBlock
      for instruction in instructions {
        instruction.run()
      }
    }
  }

}

class ElseInstruction: Instruction {}
class EndIfInstruction: Instruction {}
