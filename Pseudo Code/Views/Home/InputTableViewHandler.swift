//
//  InputTableViewHandler.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 30/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import UIKit

protocol InputTableViewHandlerDelegate {
  func textDidChange(atIndex index: Int)
  func didSelectErrors(atIndex index: Int)
}

class InputTableViewHandler: NSObject {
  
  // ViewController conforms to this delegate, so anytime a method is sent to this delegate, the ViewController instance will receive
  var delegate: InputTableViewHandlerDelegate?
  
  var scopeIndexes: [Int]?
  var errors: [[Error]] = [[]]
  var code: [String] = []
  fileprivate var tableView: UITableView
  
  // Identifies the currently highlighted line of code on screen in purple, if the user chooses to step by the program by line
  // A -1 indicates no line should be selected
  var selectedIndex: Int = -1 {
    didSet {
      tableView.reloadData()
    }
  }
  
  init(tableView: UITableView) {
    self.tableView = tableView
  }
  
  // Clears all the lines of code
  func clear() {
    code = []
    scopeIndexes = nil
    errors = [[]]
    tableView.reloadData()
  }
  
  // Fixes a bug where when the keyboard is dismissed and there are empty lines of code
  // and the user presses 'RUN' then there will be a compiler error for that line of code.
  // Therefore all empty lines are removed.
  func removeEmptyLines() {
    var newCode = [String]()
    for line in code {
      if !line.isEmpty {
        newCode.append(line)
      }
    }
    code = newCode
    tableView.reloadData()
  }

}

extension InputTableViewHandler: UITableViewDelegate, UITableViewDataSource {
  
  // All of the methods required by UITableView to function are below.
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return max(code.count, 1)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var line: String?
    if code.count > indexPath.row {
      line = code[indexPath.row]
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! InputLineTableViewCell
    var errorCount = 0
    if errors.count > indexPath.row {
      errorCount = errors[indexPath.row].count
    }
    cell.configure(withLine: line, errors: errorCount, indexPath: indexPath, selectedLine: selectedIndex == indexPath.row)
    cell.setScope(scopeIndexes?[indexPath.row])
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if errors.count > indexPath.row && errors[indexPath.row].count > 0 {
      // Calls a delegate method which will be received by ViewController.
      // This is when the user presses on one of the lines of code to show the errors for that line.
      delegate?.didSelectErrors(atIndex: indexPath.row)
    }
  }
  
}

extension InputTableViewHandler: InputLineTableViewCellDelegate {
  
  // This is called when the user presses return on the keyboard, indicating that he wishes to type in the next line of code.
  // If the next line of code exists, it will be selected, else it will create a new one and recursively call this method again.
  func inputLineDidReturn(atIndex index: Int) {
    errors = [[]]
    scopeIndexes = nil
    if code.count > index+1 {
      if let cell = tableView.cellForRow(at: IndexPath(row: index+1, section: 0)) as? InputLineTableViewCell {
        cell.selectField()
      }
    } else {
      code.append("")
      tableView.reloadData()
      inputLineDidReturn(atIndex: index)
    }
  }
  
  // This is called anytime the text is changed at a line of code.
  func inputLineDidChangeText(atIndex index: Int, text: String) {
    errors = [[]]
    scopeIndexes = nil
    // Calls a delegate method which will be received by ViewController
    delegate?.textDidChange(atIndex: index)
    if code.count <= index {
      code.append("")
      inputLineDidChangeText(atIndex: index, text: text)
      return
    }
    code[index] = text
  }
  
}
