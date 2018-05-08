//
//  AssignmentInstruction.swift
//  PseudoCodeInterpreterServer
//
//  Created by Jake Sieradzki on 17/10/2017.
//

import Foundation

class AssignmentInstruction: Instruction {
  
  // This class represents an instruction in the form:
  // variable <- value
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case .assignment(let targetVariableName, let value) = match {
      run(targetVarName: targetVariableName, value: value)
    }
  }
  
  fileprivate func run(targetVarName: String, value: Any) {
    Program.shared!.variables[targetVarName] = value
  }

}
