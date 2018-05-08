//
//  ForInstruction.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 23/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

class ForInstruction: Instruction {
  
  // This class represents an instruction in the form:
  // FOR indexVariable <- startValue TO endValue
  //    code
  // NEXT
  
  var instructions: [Instruction] = []
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case let .forLoop(indexVarName, startIndex, endIndex) = match {
      for index in startIndex...endIndex {
        Program.shared?.variables[indexVarName] = index
        runBlock()
      }
      Program.shared?.variables[indexVarName] = nil
    }
  }
  
  fileprivate func runBlock() {
    for instruction in instructions {
      instruction.run()
    }
  }

}

class EndForInstruction: Instruction {}
