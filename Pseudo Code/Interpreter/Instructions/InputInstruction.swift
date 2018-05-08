//
//  InputInstruction.swift
//  PseudoCodeInterpreterServer
//
//  Created by Jake Sieradzki on 17/10/2017.
//

import Foundation

class InputInstruction: Instruction {
  
  // This class represents an instruction in the form:
  // INPUT variable
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case let .input(variableName) = match {
      run(withVariableName: variableName)
    }
  }
  
  fileprivate func run(withVariableName varName: String) {
    let input = Program.shared!.requestInput()
    Program.shared!.variables[varName] = input
  }

}
