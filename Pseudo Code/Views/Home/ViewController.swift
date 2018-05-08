//
//  ViewController.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 29/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  // Identifiers that link to transitions between screens in the Main.storyboard file
  fileprivate let errorDetailSegueIdentifier = "ErrorDetailSegue"
  fileprivate let inputDetailSegueIdentifier = "InputDetailSegue"
  fileprivate let librarySegueIdentifier = "LibrarySegue"
  
  // Used to transfer data to error detail screen when selected
  fileprivate var selectedIndex: Int?
  fileprivate var selectedErrors: [Error]?
  
  // Connections to user interface elements in the Main.storyboard file
  @IBOutlet fileprivate var inputContainer: UIView!
  @IBOutlet fileprivate var inputTableView: UITableView!
  @IBOutlet fileprivate var outputTextView: UITextView!
  @IBOutlet fileprivate var checkButton: UIButton!
  @IBOutlet fileprivate var runButton: UIButton!
  @IBOutlet fileprivate var nextButton: UIButton!
  @IBOutlet fileprivate var clearButton: UIButton!
  @IBOutlet fileprivate var libraryButton: UIButton!
  @IBOutlet fileprivate var helpButton: UIButton!
  @IBOutlet fileprivate var keyboardConstraint: NSLayoutConstraint!
  
  // The delegate and data source for the table view
  fileprivate var inputTableViewHandler: InputTableViewHandler!
  
  // The program interpreter object which runs the functionality of the inputted pseudo code
  fileprivate var programInterpreter: ProgramInterpreter?

  // This method is called on UIViewController when the view is first loaded into memory
  override func viewDidLoad() {
    super.viewDidLoad()
    inputTableViewHandler = InputTableViewHandler(tableView: inputTableView)
    inputTableViewHandler.delegate = self
    inputTableView.delegate = inputTableViewHandler
    inputTableView.dataSource = inputTableViewHandler
    styling()
    setupKeyboard()
    setProgramAbleToRun(false)
  }
  
  fileprivate func styling() {
    inputContainer.layer.cornerRadius = 10
    inputContainer.layer.masksToBounds = true
    for btn in [checkButton, runButton, nextButton, clearButton, libraryButton, helpButton] {
      btn!.layer.cornerRadius = 9
      btn!.layer.masksToBounds = true
    }
    helpButton.layer.cornerRadius = helpButton.frame.size.height/2
  }
  
  // This method is called on UIViewController when it is about to transition to another screen
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // This segue identifier is the same as the segue identifiers which are defined at the start of this file
    guard let segueIdentifier = segue.identifier else {
      return
    }
    let vc = (segue.destination as? UINavigationController)?.viewControllers.first
    switch segueIdentifier {
    case errorDetailSegueIdentifier:
      guard let vc = vc as? ErrorsTableViewController, let index = selectedIndex else { return }
      vc.code = inputTableViewHandler.code[index]
      vc.line = index
      vc.errors = selectedErrors
      selectedIndex = nil
      selectedErrors = nil
    case inputDetailSegueIdentifier:
      guard let vc = vc as? InputsTableViewController else { return }
      vc.numberOfInputs = ProgramInterpreter.numberOfInputsRequired(code: inputTableViewHandler.code)
      vc.inputsReturned = inputsSuccessfullyReturned(inputs:)
    case librarySegueIdentifier:
      guard let vc = vc as? LibraryTableViewController else { return }
      vc.currentCode = inputTableViewHandler.code
      vc.loadCode = loadCode
    default: break
    }
  }
  
  fileprivate func setupKeyboard() {
    // These closures will be called everytime the keyboard is shown/hidden so that the other views on the screen can be adjusted
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { notification in
      guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
      let mainScreenSize = UIScreen.main.bounds
      // Sets the spacing between the views on the screen and the bottom of the screen
      self.keyboardConstraint.constant = (mainScreenSize.height - keyboardSize.origin.y+30)
      UIView.animate(withDuration: 0.25) {
        self.view.layoutIfNeeded()
      }
    }
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { notification in
      self.keyboardConstraint.constant = 135
      UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
  }
  
  // MARK: Actions
  
  fileprivate func setProgramAbleToRun(_ able: Bool) {
    runButton.isEnabled = able
    nextButton.isEnabled = able
  }
  
  // Links to the 'CHECK' button in the Main.storyboard file, called when the button is tapped
  @IBAction fileprivate func checkPressed() {
    inputTableViewHandler.removeEmptyLines()
    let numberOfInputs = ProgramInterpreter.numberOfInputsRequired(code: inputTableViewHandler.code)
    if numberOfInputs > 0 {
      performSegue(withIdentifier: inputDetailSegueIdentifier, sender: self)
    } else {
      inputsSuccessfullyReturned(inputs: [])
    }
  }
  
  fileprivate func inputsSuccessfullyReturned(inputs: [Any]) {
    let code = inputTableViewHandler.code
    runProgram(code: code, inputs: inputs)
  }
  
  fileprivate func runProgram(code: [String], inputs: [Any]) {
    let programInterpreter = ProgramInterpreter(code: code, inputs: inputs)
    setProgramAbleToRun(programInterpreter.canRun)
    self.programInterpreter = programInterpreter
    if programInterpreter.canRun {
      inputTableViewHandler.scopeIndexes = programInterpreter.scopes
      inputTableView.reloadData()
      logMessage("Program is ready to run.")
      Program.resetProgram(withInterpreter: programInterpreter)
      inputTableViewHandler.selectedIndex = 0
    } else {
      inputTableViewHandler.errors = programInterpreter.errors
      inputTableView.reloadData()
      logErrorMessage()
    }
  }
  
  // Links to the 'RUN' button in the Main.storyboard file, called when the button is tapped
  @IBAction fileprivate func runPressed() {
    if let interpreter = programInterpreter {
      inputTableViewHandler.selectedIndex = -1
      Program.resetProgram(withInterpreter: interpreter)
      Program.shared?.run()
      logOutput(Program.shared!.outputs)
      inputTableViewHandler.selectedIndex = -1
    }
  }
  
  // Links to the 'NEXT' button in the Main.storyboard file, called when the button is tapped
  @IBAction fileprivate func nextPressed() {
    Program.shared?.runNext()
    logOutput(Program.shared!.outputs)
    inputTableViewHandler.selectedIndex += 1
    if Program.shared?.completedExecution == true {
      inputTableViewHandler.selectedIndex = -1
    }
  }
  
  // Links to the 'CLEAR' button in the Main.storyboard file, called when the button is tapped
  @IBAction fileprivate func clearPressed() {
    inputTableViewHandler.selectedIndex = -1
    inputTableViewHandler.clear()
  }
  
  // Links to the 'LIBRARY' button in the Main.storyboard file, called when the button is tapped
  @IBAction fileprivate func libraryPressed() {
    performSegue(withIdentifier: librarySegueIdentifier, sender: self)
  }
  
  // Links to the '?' button in the Main.storyboard file, called when the button is tapped
  @IBAction fileprivate func helpPressed() {
    let link = URL(string: "http://www.ocr.org.uk/Images/202654-pseudocode-guide.pdf")!
    UIApplication.shared.open(link, options: [:], completionHandler: nil)
  }
  
  // MARK: - Save/load code
  
  fileprivate func loadCode(code: [String]) {
    inputTableViewHandler.clear()
    inputTableViewHandler.code = code
    inputTableView.reloadData()
  }
  
  // MARK: - Log To Console
  
  // Will print a message to the on-screen console
  fileprivate func logMessage(_ message: String) {
    outputTextView.text = message
    outputTextView.flashScrollIndicators()
  }
  
  // Will print specifically an error message to the on-screen console, in the same format each time
  fileprivate func logErrorMessage(_ errorMessage: String? = nil) {
    let extra = errorMessage == nil ? "" : "\n\n\(errorMessage!)"
    logMessage("Error: Cannot run program!" + extra)
  }
  
  // Will log all of the outputs which are returned from running the program.
  fileprivate func logOutput(_ outputs: [Any]) {
    var output = ""
    for line in outputs {
      output += String(describing: line)
      output += "\n"
    }
    logMessage("Output:\n\(output)")
  }

}

extension ViewController: InputTableViewHandlerDelegate {
  
  // Is called everytime the text changes at a certain line of code at index 'index'
  func textDidChange(atIndex index: Int) {
    setProgramAbleToRun(false)
    programInterpreter = nil
    logMessage("")
  }
  
  // Is called when the error number button is pressed on a line of code
  func didSelectErrors(atIndex index: Int) {
    guard let errors = programInterpreter?.errors[index] else {
      return
    }
    selectedIndex = index
    selectedErrors = errors
    performSegue(withIdentifier: "ErrorDetailSegue", sender: self)
  }
  
}
