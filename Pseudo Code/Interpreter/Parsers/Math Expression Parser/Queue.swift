//
//  Queue.swift
//  PseudoCodeConsoleApp
//
//  Created by Jake Sieradzki on 06/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import Foundation

// A custom implementation for a Queue

class Queue<T>: NSObject, Sequence {
  typealias Element = T
  typealias Iterator = QueueIterator
  
  fileprivate var first: Node?
  fileprivate var last: Node?
  fileprivate(set) var N = 0
  
  fileprivate class Node {
    var item: T
    var next: Node?
    init(item: T) {
      self.item = item
    }
  }
  
  override var description: String {
    var output = "Queue<\(T.self)>\n"
    forEach({ output += String(describing: $0) + " " })
    return output
  }
  
  var isEmpty: Bool {
    return N == 0
  }
  
  func enqueue(item: T) {
    let oldLast = last
    last = Node(item: item)
    
    if isEmpty {
      first = last
    } else {
      oldLast?.next = last
    }
    
    N += 1
  }
  
  func dequeue() -> T? {
    guard let first = first else {
      return nil
    }
    let item = first.item
    self.first = first.next
    N -= 1
    
    if isEmpty {
      last = nil
    }
    return item
  }
  
  func makeIterator() -> Queue<T>.Iterator {
    return QueueIterator(firstNode: first, N: N)
  }
  
  struct QueueIterator: IteratorProtocol {
    typealias Element = T
    private var firstNode: Node?
    private var i: Int
    
    fileprivate init(firstNode: Node?, N: Int) {
      self.firstNode = firstNode
      self.i = N
    }
    
    mutating func next() -> T? {
      guard i > 0 else {
        return nil
      }
      let oldFirst = firstNode
      firstNode = firstNode?.next
      i -= 1
      return oldFirst?.item
    }
    
  }
  
}
