//
//  CommandParser.swift
//  PseudoCodeInterpreterServer
//
//  Created by Jake Sieradzki on 17/10/2017.
//

import Foundation

enum CommandType {
  case input, output
  case assignment
  case forLoop, endForLoop
  case ifStatement, elseStatement, endIfStatement
  case repeatStart, repeatUntil
  case whileStart, endWhile
}

enum CommandMatch {
  case input(String)
  case output(Any)
  case assignment(String, Any)
  case forLoop(String, Int, Int)
  case endForLoop
  case ifStatement(Bool)
  case elseStatement
  case endIfStatement
  case repeatStart
  case repeatUntil(String)
  case whileStart(String)
  case endWhile
}

class CommandParser {
  
  fileprivate let command: String
  fileprivate let variables: [String : Any]
  
  init(command: String, variables: [String : Any]? = nil) {
    self.command = command
    self.variables = variables ?? Program.shared?.variables ?? [:]
  }
  
  // This will return the CommandType enum type of the inputted string line of code
  var type: CommandType? {
    if textMatches(regex: CommandRegexPattern.input) { return .input }
    if textMatches(regex: CommandRegexPattern.output) { return .output }
    if textMatches(regex: CommandRegexPattern.assignment) { return .assignment }
    if textMatches(regex: CommandRegexPattern.forLoop) { return .forLoop }
    if textMatches(regex: CommandRegexPattern.endForLoop) { return .endForLoop }
    if textMatches(regex: CommandRegexPattern.ifStatement) { return .ifStatement }
    if textMatches(regex: CommandRegexPattern.elseStatement) { return .elseStatement }
    if textMatches(regex: CommandRegexPattern.endIfStatement) { return .endIfStatement }
    if textMatches(regex: CommandRegexPattern.repeatStatement) { return .repeatStart }
    if textMatches(regex: CommandRegexPattern.repeatUntilStatement) { return .repeatUntil }
    if textMatches(regex: CommandRegexPattern.whileStart) { return .whileStart }
    if textMatches(regex: CommandRegexPattern.endWhile) { return .endWhile }
    return nil
  }
  
  // This will return the CommandMatch enum type of the inputted string line of code
  // which includes associated values for data inside the command.
  var match: CommandMatch? {
    guard let type = type else {
      return nil
    }
    switch type {
    case .input:          return inputMatch()
    case .output:         return outputMatch()
    case .assignment:     return assignmentMatch()
    case .forLoop:        return forLoopMatch()
    case .endForLoop:     return .endForLoop
    case .ifStatement:    return ifStatementMatch()
    case .elseStatement:  return .elseStatement
    case .endIfStatement: return .endIfStatement
    case .repeatStart:    return .repeatStart
    case .repeatUntil:    return repeatUntilMatch()
    case .whileStart:     return whileMatch()
    case .endWhile:       return .endWhile
    }
  }
  
  // Below are standard helper functions which use regex to either recognise
  // or substitute strings using the inputted line of code.
  
  fileprivate func textMatches(regex: String) -> Bool {
    return RegexExtractor.textMatches(command, forRegex: regex)
  }
  
  fileprivate func substituteVariables(intoExpr expr: String) -> String {
    let substituted = RegexSubstituter(command: expr, variables: variables).substitute()
    return substituted
  }
  
  // Uses either the ShuntingYardParser, StringExpressionParser or BooleanExpressionParser
  // class to create a value for a substring which should represent a value of type either
  // Int, String or Boolean
  static func createValue(fromExpression expr: String) -> Any? {
    if RegexExtractor.textMatches(expr, forRegex: CommandRegexPattern.integerExpression) {
      let value = ShuntingYardParser(expr: expr).calculate()
      return value
    } else if RegexExtractor.textMatches(expr, forRegex: CommandRegexPattern.booleanValue) {
      if expr == "TRUE" || expr == "true"     { return true }
      if expr == "FALSE" || expr == "false"   { return false }
    } else if RegexExtractor.textMatches(expr, forRegex: CommandRegexPattern.stringExpression) {
      return StringExpressionParser(input: expr).evaluatedValue
    } else if let parser = BooleanExpressionParser(expr: expr) {
      return parser.calculate()
    }
    return nil
  }
  
  // MARK: Types
  // Below are all the custom string manipulation methods to extract values from each type of command
  
  fileprivate func inputMatch() -> CommandMatch {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.input, in: command)
    let varName = results[1]
    return .input(varName)
  }
  
  fileprivate func outputMatch() -> CommandMatch? {
    let expr = substituteVariables(intoExpr: command)
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.output, in: expr)
    let valueExpr = results[1]
    
    if let value = CommandParser.createValue(fromExpression: valueExpr) {
      return .output(value)
    }
    
    return nil
  }
  
  fileprivate func assignmentMatch() -> CommandMatch? {
    let expr = substituteVariables(intoExpr: command)
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.assignment, in: expr)
    let targetVarName = results[1]
    let valueExpr = results[2]
    
    if let value = CommandParser.createValue(fromExpression: valueExpr) {
      return .assignment(targetVarName, value)
    }
    
    return nil
  }
  
  fileprivate func forLoopMatch() -> CommandMatch? {
    let expr = substituteVariables(intoExpr: command)
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.forLoop, in: expr)
    let indexVarName = results[1]
    let startIndexExpr = results[2]
    let endIndexExpr = results[3]
    
    let startIndexValid = RegexExtractor.textMatches(startIndexExpr, forRegex: CommandRegexPattern.integerExpression)
    let endIndexValid = RegexExtractor.textMatches(endIndexExpr, forRegex: CommandRegexPattern.integerExpression)
    
    guard startIndexValid && endIndexValid else {
      return nil
    }
    
    let startIndex = ShuntingYardParser(expr: startIndexExpr).calculate()
    let endIndex = ShuntingYardParser(expr: endIndexExpr).calculate()
    return .forLoop(indexVarName, startIndex, endIndex)
  }
  
  fileprivate func ifStatementMatch() -> CommandMatch? {
    let expr = substituteVariables(intoExpr: command)
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.ifStatement, in: expr)
    let boolExpr = results[1]
    guard let boolVal = CommandParser.createValue(fromExpression: boolExpr) as? Bool else {
      return nil
    }
    return .ifStatement(boolVal)
  }
  
  fileprivate func repeatUntilMatch() -> CommandMatch? {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.repeatUntilStatement, in: command)
    let boolExpr = results[1]
    return .repeatUntil(boolExpr)
  }
  
  fileprivate func whileMatch() -> CommandMatch? {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.whileStart, in: command)
    let boolExpr = results[1]
    return .whileStart(boolExpr)
  }
  
}

