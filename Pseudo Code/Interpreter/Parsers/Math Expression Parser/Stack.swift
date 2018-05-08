//
//  Stack.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 03/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

// A custom implementation for a Stack

import Foundation

class Stack<T>: NSObject, Sequence {
  typealias Element = T
  typealias Iterator = StackIterator
  
  fileprivate var last: Node?
  fileprivate var N = 0
  
  fileprivate class Node {
    var item: T
    var next: Node?
    init(item: T, next: Node?) {
      self.item = item
      self.next = next
    }
  }
  
  override var description: String {
    var output = "Stack<\(T.self)>\n"
    forEach({ output += String(describing: $0) + " " })
    return output
  }
  
  var isEmpty: Bool {
    return N < 1
  }
  
  var size: Int {
    return N
  }
  
  func peek() -> T? {
    if let last = last {
      return last.item
    }
    return nil
  }
  
  func push(item: T) {
    let oldLast = last
    last = Node(item: item, next: oldLast)
    N += 1
  }
  
  @discardableResult
  func pop() -> T? {
    let oldLast = last
    last = oldLast?.next
    N -= 1
    return oldLast?.item
  }
  
  func makeIterator() -> Stack<T>.Iterator {
    return StackIterator(last: last, N: N)
  }
  
  struct StackIterator: IteratorProtocol {
    typealias Element = T
    private var nextNode: Node?
    private var i: Int
    
    fileprivate init(last: Node?, N: Int) {
      self.nextNode = last
      self.i = N
    }
    
    mutating func next() -> T? {
      guard i > 0 else {
        return nil
      }
      let oldNext = nextNode
      nextNode = oldNext?.next
      i -= 1
      return oldNext?.item
    }
    
  }

}
