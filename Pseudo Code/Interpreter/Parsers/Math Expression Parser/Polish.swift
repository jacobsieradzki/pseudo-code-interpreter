//
//  Polish.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 06/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

class Polish {
  
  fileprivate var stack = Stack<Int>()
  fileprivate var queue: Queue<String>
  
  init(q: Queue<String>) {
    self.queue = q
  }
  
  var stringValue: String {
    var str = ""
    queue.forEach { str += $0 + " " }
    return str
  }
  
  func calculate() -> Int {
    for item in queue {
      if let n = Int(item) {
        stack.push(item: n)
      } else {
        if let right = stack.pop(), let left = stack.pop() {
          switch item {
          case "+": stack.push(item: left + right)
          case "-": stack.push(item: left - right)
          case "*": stack.push(item: left * right)
          case "/":
            if right == 0 {
              complainNaNError()
              stack.push(item: 0)
            } else {
              stack.push(item: left / right)
            }
          case "%":
            if right == 0 {
              complainNaNError()
              stack.push(item: 0)
            } else {
              stack.push(item: left % right)
            }
          default: break
          }
        }
      }
    }
    
    return stack.pop() ?? 0
  }
  
  fileprivate func complainNaNError() {
    Program.shared?.outputs.append("NaN error! Returning 0 to prevent crash.")
  }

}
