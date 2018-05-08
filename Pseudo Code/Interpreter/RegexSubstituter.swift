//
//  RegexSubstituter.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 16/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

class RegexSubstituter {
  
  fileprivate let command: String
  fileprivate let varNames: [String]?
  fileprivate let variables: [String : Any]?
  
  init(command: String, varNames: [String]? = nil, variables: [String : Any]? = nil) {
    self.command = command
    self.varNames = varNames
    self.variables = variables
  }
  
  // This will substitute variables into string line of code commands.
  // For example, the second line of code here:
  //    MyVariable <- "Hello, world!"
  //    OUTPUT MyVariable
  // will be transformed into:
  //    OUTPUT "Hello, world!"
  
  func substitute() -> String {
    guard let type = CommandParser(command: command).type else {
      return substituteExpression(command)
    }
    
    // If there were a variable in memory called OUTPUT, then that would be substituted automatically.
    // Therefore for certain commands, we only substitute certain substrings of the line of code in order not
    // to completely change the line of code.
    switch type {
    case .output:         return substituteOutputExpression()
    case .assignment:     return substituteAssignmentExpression()
    case .forLoop:        return substituteForLoopExpression()
    case .ifStatement:    return substituteIfStatement()
    default:              return command
    }
  }
  
}

// MARK: - Substitutions

// Before are custom string manipulations using regex on each specific command type to substitute
// variables into commands.

extension RegexSubstituter {
  
  fileprivate func substituteExpression(_ expr: String) -> String {
    var rhs = expr
    if let varNames = varNames {
      rhs = substituteVarNames(varNames, withValue: "0", intoExpression: rhs)
    } else if let variables = variables {
      rhs = substituteValues(variables, intoExpression: rhs)
    }
    return rhs
  }
  
  fileprivate func substituteOutputExpression() -> String {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.output, in: command)
    let rhs = substituteExpression(results[1])
    return command.replacingOccurrences(of: results[1], with: rhs)
  }
  
  fileprivate func substituteAssignmentExpression() -> String {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.assignment, in: command)
    let rhs = substituteExpression(results[2])
    return command.replacingOccurrences(of: results[2], with: rhs)
  }
  
  fileprivate func substituteForLoopExpression() -> String {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.forLoop, in: command)
    var newExpr = command
    newExpr = newExpr.replacingOccurrences(of: results[2], with: substituteExpression(results[2]))
    newExpr = newExpr.replacingOccurrences(of: results[3], with: substituteExpression(results[3]))
    return newExpr
  }
  
  fileprivate func substituteIfStatement() -> String {
    let results = RegexExtractor.matches(forRegex: CommandRegexPattern.ifStatement, in: command)
    let boolExpr = substituteExpression(results[1])
    return command.replacingOccurrences(of: results[1], with: boolExpr)
  }
  
}
  
// MARK: - Helpers

extension RegexSubstituter {
  
  fileprivate func substituteValues(_ values: [String : Any], intoExpression line: String) -> String {
    var expr = line
    values.forEach({ expr = RegexSubstituter.replaceOccurrences(of: $0.key, with: string(describing: $0.value), in: expr) })
    return expr
  }
  
  fileprivate func substituteVarNames(_ varNames: [String], withValue value: String, intoExpression line: String) -> String {
    var expr = line
    varNames.forEach({ expr = RegexSubstituter.replaceOccurrences(of: $0, with: string(describing: value), in: expr) })
    return expr
  }
  
  fileprivate func string(describing value: Any) -> String {
    var str = String(describing: value)
    if ["true", "false"].contains(str) {
      str = str.uppercased()
    }
    return str
  }
  
  fileprivate static func replaceOccurrences(of key: String, with replacement: String, in text: String) -> String {
    do {
      let pattern = "\\b\(key)\\b"
      let regex = try NSRegularExpression(pattern: pattern)
      return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: replacement)
    } catch let error {
      print("Invalid regex: \(error.localizedDescription)")
      return text
    }
  }

}
