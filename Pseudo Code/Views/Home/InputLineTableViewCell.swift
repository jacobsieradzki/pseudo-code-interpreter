//
//  InputLineTableViewCell.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 30/11/2017.
//  Copyright © 2017 sieradzki. All rights reserved.
//

import UIKit

protocol InputLineTableViewCellDelegate {
  func inputLineDidReturn(atIndex index: Int)
  func inputLineDidChangeText(atIndex index: Int, text: String)
}

class InputLineTableViewCell: UITableViewCell {
  
  // The ViewController class conforms to InputLineTableViewDelegate and will respond to all
  // methods called from this delegate
  var delegate: InputLineTableViewCellDelegate?
  
  // Connections to user interface elements in the Main.storyboard file
  @IBOutlet fileprivate var leftScopeConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var lineNumberLabel: UILabel!
  @IBOutlet fileprivate var textField: UITextField!
  @IBOutlet fileprivate var errorContainer: UIView!
  @IBOutlet fileprivate var errorLabel: UILabel!
  fileprivate var indexPath: IndexPath!
  
  // This method is called when the view has finished loading from the Main.storyboard file
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
    textField.delegate = self
    textField.addTarget(self, action: #selector(textFieldDidChangeText(_:)), for: .editingChanged)
    errorContainer.layer.cornerRadius = errorContainer.frame.size.height/2
    
    let accessory = UINib(nibName: "InputCodeKeyboardAccessory", bundle: nil).instantiate(withOwner: self, options: nil).first as! InputCodeKeyboardAccessory
    accessory.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50.0)
    accessory.didSelectWord = { word in
      self.textField.text = self.textField.text! + word
      self.textFieldDidChangeText(self.textField)
    }
    textField.inputAccessoryView = accessory
  }
  
  // The following methods adjust the appearance of the table view cell for the data provided.
  
  func configure(withLine line: String?, errors: Int = 0, indexPath: IndexPath, selectedLine: Bool = false) {
    self.indexPath = indexPath
    backgroundColor = backgroundColor(forErrors: errors, selectedLine: selectedLine)
    lineNumberLabel.text = "\(indexPath.row + 1)"
    textField.text = line
    errorLabel.text = "\(errors)"
    errorContainer.isHidden = errors < 1
  }
  
  func setScope(_ scope: Int?) {
    if let scope = scope {
      let multiplier: CGFloat = 20.0
      leftScopeConstraint.constant = multiplier * CGFloat(scope)
    } else {
      leftScopeConstraint.constant = 0.0
    }
  }
  
  func selectField() {
    textField.becomeFirstResponder()
  }
  
  fileprivate func backgroundColor(forErrors errors: Int, selectedLine: Bool) -> UIColor {
    if errors > 0 {
      return UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
    } else if selectedLine {
      return UIColor(red: 0, green: 0, blue: 255, alpha: 0.2)
    } else {
      return .clear
    }
  }
  
}

extension InputLineTableViewCell: UITextFieldDelegate {
  
  // This delegate method of UITextFieldDelegate is called when the value of the text of the
  // UITextField is changed
  @objc func textFieldDidChangeText(_ textField: UITextField) {
    let text = textField.text ?? ""
    // This delegate here is connected to the ViewController class 
    delegate?.inputLineDidChangeText(atIndex: indexPath.row, text: text)
  }
  
  // This delegate method of UITextFieldDelegate will be called everytime the user presses
  // the return button on the keyboard.
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard textField.text != nil else {
      return true
    }
    textField.resignFirstResponder()
    if !textField.text!.isEmpty {
      // This delegate here is connected to the ViewController class
      delegate?.inputLineDidReturn(atIndex: indexPath.row)
    }
    return true
  }
  
}
