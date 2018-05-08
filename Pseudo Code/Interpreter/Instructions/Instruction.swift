//
//  Instruction.swift
//  PseudoCodeInterpreterServerPackageDescription
//
//  Created by Jake Sieradzki on 11/10/2017.
//

import Foundation

class Instruction {
  
  var line: String
  
  init(line: String) {
    self.line = line
  }
  
  static func createInstruction(fromLine line: String) -> Instruction? {
    guard let match = CommandParser(command: line).type else {
      return nil
    }
    
    // This switch command determines the link between the CommandType enum
    // and the type of Instruction subclass that is required.
    switch match {
    case .input:            return InputInstruction(line: line)
    case .output:           return OutputInstruction(line: line)
    case .assignment:       return AssignmentInstruction(line: line)
    case .forLoop:          return ForInstruction(line: line)
    case .endForLoop:       return EndForInstruction(line: line)
    case .ifStatement:      return IfInstruction(line: line)
    case .elseStatement:    return ElseInstruction(line: line)
    case .endIfStatement:   return EndIfInstruction(line: line)
    case .repeatStart:      return RepeatInstruction(line: line)
    case .repeatUntil:      return RepeatUntilInstruction(line: line)
    case .whileStart:       return WhileInstruction(line: line)
    case .endWhile:         return EndWhileInstruction(line: line)
    }
  }
  
  func run() {}
  
}
