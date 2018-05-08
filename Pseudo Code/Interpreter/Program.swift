 //
//  Program.swift
//  PseudoCodeInterpreterServerPackageDescription
//
//  Created by Jake Sieradzki on 11/10/2017.
//

import Foundation

class Program {
  
  // This is the singleton variable that all other classes will reference during
  // the simulated runtime of the program.
  static fileprivate(set) var shared: Program? = nil
  
  // These are public properties
  var outputs: [Any] = []
  let instructions: [Instruction]
  var variables: [String : Any]
  
  // These are private properties that are needed for the execution of the program
  fileprivate var inputs: [Any]
  fileprivate var inputIndex = 0
  fileprivate(set) var completedExecution: Bool
  fileprivate(set) var runIndex = 0
  
  // This will create a new Program object and set the singleton to this new object
  // - @discardableResult means that the compiler will not show an error if the return value of this
  //   function is not used
  @discardableResult static func resetProgram(withInterpreter interpreter: ProgramInterpreter) -> Program? {
    let program = Program(interpreter: interpreter)
    Program.shared = program
    return program
  }
  
  init?(interpreter: ProgramInterpreter) {
    guard interpreter.code.count > 0 && interpreter.canRun else {
      return nil
    }
    
    var instructions = [Instruction]()
    var queueParent: Instruction?
    var queue = [Instruction]()
    var addToQueue = false
    
    for line in interpreter.code {
      if let instruction = Instruction.createInstruction(fromLine: line) {
        
        // Here, I organise each line of code into scopes according to the type of instruction they are.
        // For example, all code within a for loop will fall within one scope and should be stored under
        // the for instruction variable 'instructions'.
        switch instruction {
        case is ForInstruction:
          addToQueue = true
          queueParent = instruction
        case is EndForInstruction:
          addToQueue = false
          if let queueParent = queueParent as? ForInstruction {
            queueParent.instructions = queue
            queue = []
            instructions.append(queueParent)
          }
        case is IfInstruction:
          addToQueue = true
          queueParent = instruction
        case is ElseInstruction:
          addToQueue = true
          (queueParent as? IfInstruction)?.trueBlock = queue
          queue = []
        case is EndIfInstruction:
          addToQueue = false
          if let queueParent = queueParent as? IfInstruction {
            if queueParent.trueBlock.isEmpty {
              queueParent.trueBlock = queue
            } else {
              queueParent.falseBlock = queue
            }
            queue = []
            instructions.append(queueParent)
            instructions.append(instruction)
          }
        case is RepeatInstruction:
          addToQueue = true
          instructions.append(instruction)
        case is RepeatUntilInstruction:
          addToQueue = false
          (instruction as? RepeatUntilInstruction)?.instructions = queue
          queue = []
          instructions.append(instruction)
        case is WhileInstruction:
          addToQueue = true
          queueParent = instruction
        case is EndWhileInstruction:
          if let queueParent = queueParent as? WhileInstruction {
            queueParent.instructions = queue
            instructions.append(queueParent)
          }
          queue = []
          instructions.append(instruction)
        default:
          if addToQueue {
            queue.append(instruction)
          } else {
            instructions.append(instruction)
          }
        }
      }
    }
    self.instructions = instructions
    self.inputs = interpreter.inputs
    self.variables = [:]
    self.runIndex = 0
    self.completedExecution = false
  }
  
  func run() {
    // This will protect the user pressing run again, or pressing step over line if they
    // have already run the program.
    guard !completedExecution else {
      return
    }
    
    completedExecution = true
    runIndex = 0
    for instruction in instructions {
      instruction.run()
    }
    outputs.append("\nCompleted execution.")
    completedExecution = true
  }
  
  // This is the step by line method which will run each instruction one at a time.
  func runNext() {
    guard !completedExecution else {
      return
    }
    if runIndex < instructions.count {
      instructions[runIndex].run()
      runIndex += 1
    } else {
      outputs.append("\nCompleted execution.")
      completedExecution = false
    }
  }
  
  // This will be called when the interpreter comes across an 'INPUT' command.
  // If there are no more inputs available, it will return value: -1
  func requestInput() -> Any {
    if inputs.count > inputIndex {
      let i = inputIndex
      inputIndex += 1
      return inputs[i]
    }
    return -1
  }
  
}
