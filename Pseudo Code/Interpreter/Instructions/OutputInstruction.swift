//
//  OutputInstruction.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 22/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

class OutputInstruction: Instruction {
  
  // This class represents an instruction in the form:
  // OUTPUT value
  
  override func run() {
    guard let match = CommandParser(command: line).match else {
      return
    }
    
    if case let .output(value) = match {
      Program.shared!.outputs.append(value)
    }
  }

}
