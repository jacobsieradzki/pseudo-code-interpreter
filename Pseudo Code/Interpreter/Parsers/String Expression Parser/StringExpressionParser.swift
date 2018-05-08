//
//  StringExpressionParser.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 08/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class StringExpressionParser {
  
  var input: String
  
  init(input: String) {
    self.input = input
  }
  
  var evaluatedValue: String? {
    if let evaluated = evaluate(input) {
      return "'\(evaluated)'"
    }
    return nil
  }
  
  fileprivate func evaluate(_ input: String) -> String? {
    let split = input.split(separator: "'")
    if split.count % 2 == 0 {
      // String addition should have an even number of ' characters for starting and ending strings.
      return nil
    }
    
    var shouldAdd = true
    var output = ""
    
    for str in split {
      let shortened = str.replacingOccurrences(of: " ", with: "")
      switch shortened {
      case "+":
        shouldAdd = true
      default:
        if shouldAdd {
          output += str
          shouldAdd = false
        } else {
          return nil
        }
      }
    }
    return output
  }

}
