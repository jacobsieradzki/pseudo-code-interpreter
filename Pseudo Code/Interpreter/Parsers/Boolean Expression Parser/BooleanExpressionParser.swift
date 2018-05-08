//
//  BooleanExpressionParser.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 24/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

fileprivate struct BooleanExprRegexPatterns {
  
  static var integer: String {
    return expression(value: CommandRegexPattern.integerExpression, operators: ["=","<",">","<=",">=","<>"])
  }
  
  static var string: String {
    return expression(value: CommandRegexPattern.stringExpression, operators: ["=","<>"])
  }
  
  static var boolean: String {
    return expression(value: CommandRegexPattern.booleanValue, operators: ["=","<>"])
  }
  
  private static func expression(value: String, operators: [String]) -> String {
    let ops = operators.joined(separator: "|")
    return "(\(value)) ?(\(ops)) ?(\(value))"
  }
  
}

class BooleanExpressionParser {
  
  fileprivate enum ParserType {
    case integer, string, boolean
  }
  
  fileprivate var type: ParserType
  fileprivate var lhs: Any
  fileprivate var rhs: Any
  fileprivate var op: String
  
  fileprivate init?(regexResults results: [String], type: ParserType) {
    guard let lhs = CommandParser.createValue(fromExpression: results[1]), let rhs = CommandParser.createValue(fromExpression: results[3]) else {
      return nil
    }
    self.type = type
    self.lhs = lhs
    self.rhs = rhs
    self.op = results[2]
  }
  
  convenience init?(expr: String) {
    if RegexExtractor.textMatches(expr, forRegex: BooleanExprRegexPatterns.integer) {
      self.init(regexResults: RegexExtractor.matches(forRegex: BooleanExprRegexPatterns.integer, in: expr), type: .integer)
      return
    }
    if RegexExtractor.textMatches(expr, forRegex: BooleanExprRegexPatterns.string) {
      self.init(regexResults: RegexExtractor.matches(forRegex: BooleanExprRegexPatterns.string, in: expr), type: .string)
      return
    }
    if RegexExtractor.textMatches(expr, forRegex: BooleanExprRegexPatterns.boolean) {
      self.init(regexResults: RegexExtractor.matches(forRegex: BooleanExprRegexPatterns.boolean, in: expr), type: .boolean)
      return
    }
    return nil
  }
  
  func calculate() -> Bool? {
    switch type {
    case .integer:  return calculateIntegerValue()
    case .string:   return calculateStringValue()
    case .boolean:  return calculateBooleanValue()
    }
  }
  
  fileprivate func calculateIntegerValue() -> Bool? {
    guard let lhs = lhs as? Int, let rhs = rhs as? Int else {
      return nil
    }
    switch op {
    case "=":  return lhs == rhs
    case "<":   return lhs < rhs
    case ">":   return lhs > rhs
    case "<=":  return lhs <= rhs
    case ">=":  return lhs >= rhs
    case "<>":  return lhs != rhs
    default: return nil
    }
  }
  
  fileprivate func calculateStringValue() -> Bool? {
    guard let lhs = lhs as? String, let rhs = rhs as? String else {
      return nil
    }
    switch op {
    case "==":  return lhs == rhs
    case "<>":  return lhs != rhs
    default: return nil
    }
  }
  
  fileprivate func calculateBooleanValue() -> Bool? {
    guard let lhs = lhs as? Bool, let rhs = rhs as? Bool else {
      return nil
    }
    switch op {
    case "==":  return lhs == rhs
    case "<>":  return lhs != rhs
    default: return nil
    }
  }

}
