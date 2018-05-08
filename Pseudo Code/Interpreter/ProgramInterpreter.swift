//
//  ProgramInterpreter.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 15/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

class ProgramInterpreter {
  
  // Private variables
  fileprivate(set) var code: [String]
  fileprivate(set) var inputs: [Any]
  
  fileprivate(set) var variableNames: [String] = []
  fileprivate(set) var errors: [[Error]]
  fileprivate(set) var scopes: [Int] = []
  fileprivate var nextScopeIndex: Int?
  
  // A value that indicates whether the program is allowed to run or not
  // depending on whether the code is valid or not
  var canRun: Bool {
    var errorCount = 0
    errors.forEach({ errorCount += $0.count })
    return errorCount == 0
  }
  
  init(code: [String], inputs: [Any]) {
    self.code = code
    self.inputs = inputs
    self.errors = Array(repeating: [], count: code.count)
    analyseCode()
  }
  
  // MARK: Identify Variables
  // The following methods will parse through the string lines of code and detect/recognise certain
  // types of command and value to determine whether the line of code is valid or not.
  
  static func numberOfInputsRequired(code: [String]) -> Int {
    var count = 0
    for line in code {
      if RegexExtractor.textMatches(line, forRegex: CommandRegexPattern.input) {
        count += 1
      }
    }
    return count
  }
  
  fileprivate func parseForInputs(line: String) {
    if let varName = collectVariableName(forLine: line, regexPattern: CommandRegexPattern.input) {
      appendVariableName(varName)
    }
  }
  
  fileprivate func parseForVariableNames(line: String) {
    if let varName = collectVariableName(forLine: line, regexPattern: CommandRegexPattern.assignment) {
      appendVariableName(varName)
    } else if let varName = collectVariableName(forLine: line, regexPattern: CommandRegexPattern.forLoop) {
      appendVariableName(varName)
    }
  }
  
  fileprivate func collectVariableName(forLine line: String, regexPattern: String) -> String? {
    guard RegexExtractor.textMatches(line, forRegex: regexPattern) else {
      return nil
    }
    let results = RegexExtractor.matches(forRegex: regexPattern, in: line)
    return results[1]
  }
  
  fileprivate func appendVariableName(_ varName: String) {
    if !variableNames.contains(varName) {
      variableNames.append(varName)
    }
  }
  
  // MARK: Analyse lines
  
  fileprivate func analyseCode() {
    scopes = []
    var index = 0
    for line in code {
      parseForInputs(line: line)
      parseForVariableNames(line: line)
      
      let expr = RegexSubstituter(command: line, varNames: variableNames).substitute()
      validateLine(line: expr, index: index)
      addScopeIndex(forLine: line)
      index += 1
    }
  }
  
  fileprivate func validateLine(line: String, index: Int) {
    if let _ = CommandParser(command: line).match {
      return
    }
    let errs = errors(forLine: line)
    errors[index] = errs
  }
  
  fileprivate func addScopeIndex(forLine line: String) {
    if let nextScopeIndex = nextScopeIndex {
      scopes.append(nextScopeIndex)
      self.nextScopeIndex = nil
      return
    }
    
    let scope = scopes.last ?? 0
    guard let type = CommandParser(command: line).type else {
      return
    }
    switch type {
    case .ifStatement, .forLoop, .repeatStart, .whileStart:
      nextScopeIndex = scope + 1
      scopes.append(scope)
    case .endForLoop, .endIfStatement, .repeatUntil, .endWhile:
      scopes.append(scope - 1)
    case .elseStatement:
      nextScopeIndex = scope
      scopes.append(scope - 1)
    default:
      scopes.append(scope)
    }
  }
  
  fileprivate func errors(forLine line: String) -> [Error] {
    return CodeErrorHandler.provideError(line: line)
  }

}
