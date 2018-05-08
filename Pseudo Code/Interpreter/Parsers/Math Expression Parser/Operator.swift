//
//  Operator.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 03/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

/* A class which represents an Operator, possible types being:
 
 (
 )
 +
 -
 *
 /
 %
 
*/


class Operator: NSObject {
  
  fileprivate(set) var op: String
  
  init(op: String) {
    self.op = op
  }
  
  override var description: String {
    if ["(", ")", "+", "-", "*", "/", "%"].contains(op) {
      return op
    }
    return "Unknown_Operator"
  }
  
  func precendence() -> Int {
    if op == "(" {
      return 1
    } else if op == "+" || op == "-" {
      return 2
    } else if op == "*" || op == "/" || op == "%" {
      return 3
    }
    return -1
  }

}
