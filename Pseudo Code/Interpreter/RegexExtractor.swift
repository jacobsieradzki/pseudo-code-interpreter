//
//  RegexExtractor.swift
//  PseudoCodeInterpreterServerPackageDescription
//
//  Created by Jake Sieradzki on 11/10/2017.
//

import Foundation

struct CommandRegexPattern {
  static var integerExpression = "(?:[0123456789()+-/*%\\s])+"
  static var booleanValue = "TRUE|FALSE"
  static var stringExpression = "^(?:'.+' \\+ )*(?:'.+')$"
  static var variable = "[a-zA-Z_$][a-zA-Z_$0-9]*"
  static var input = "INPUT (\(variable))"
  static var output = "OUTPUT (.+)"
  static var assignment = "(\(variable)) <- (.+)"
  static var forLoop = "FOR (\(variable)) <- (.+) TO (.+)"
  static var endForLoop = "NEXT"
  static var ifStatement = "IF (.+) THEN"
  static var elseStatement = "ELSE"
  static var endIfStatement = "END IF"
  static var repeatStatement = "REPEAT"
  static var repeatUntilStatement = "UNTIL (.+)"
  static var whileStart = "WHILE (.+)"
  static var endWhile = "END WHILE"
}

class RegexExtractor {
  
  // Uses the iOS Framework class NSPredicate to determine whether a String (text) matches
  // a regex pattern (regex)
  static func textMatches(_ text: String, forRegex regex: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
  }
  
  // Will return all the capture values from the regex pattern (regex) in the string (text).
  // The first value will always be the entire string, and each capture value in order following that.
  static func matches(forRegex regex: String, in text: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let nsString = text as NSString
      let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
      var a = [String]()
      for i in 0..<results[0].numberOfRanges {
        a.append(nsString.substring(with: results[0].range(at: i)))
      }
      return a
    } catch let error {
      print("Invalid regex: \(error.localizedDescription)")
      return []
    }
  }
  
}
