//
//  InputsTableViewController.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 08/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class InputsTableViewController: UITableViewController {
  
  var numberOfInputs: Int!
  var inputsReturned: (([Any]) -> ())?
  
  fileprivate func fetchInputs() -> [String] {
    var inputs = [String]()
    for i in 0..<tableView.numberOfRows(inSection: 0) {
      let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ProgramInputTableViewCell
      inputs.append(cell.inputtedText)
    }
    return inputs
  }
  
  fileprivate func allInputsAreValid() -> Bool {
    let inputs = fetchInputs()
    for input in inputs {
      if input.isEmpty {
        return false
      }
    }
    return true
  }
  
  fileprivate func processInputs() -> [Any] {
    let strInputs = fetchInputs()
    var inputs = [Any]()
    for input in strInputs {
      if let integer = Int(input) {
        inputs.append(integer)
      } else {
        inputs.append("'\(input)'")
      }
    }
    return inputs
  }
  
  // This is connected to the 'CANCEL' button in the Main.storyboard and will be called when
  // the button is tapped
  @IBAction fileprivate func cancelPressed() {
    dismiss(animated: true, completion: nil)
  }
  
  // This is connected to the 'DONE' button in the Main.storyboard and will be called when
  // the button is tapped
  @IBAction fileprivate func donePressed() {
    if allInputsAreValid() {
      inputsReturned?(processInputs())
      dismiss(animated: true, completion: nil)
    } else {
      let alert = UIAlertController(title: "Error!", message: "Make sure you have entered valid inputs in all fields.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
        alert.dismiss(animated: true, completion: nil)
      }))
      present(alert, animated: true, completion: nil)
    }
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfInputs
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InputVariableCell", for: indexPath) as! ProgramInputTableViewCell
    cell.configure(indexPath)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60.0
  }
  
}
