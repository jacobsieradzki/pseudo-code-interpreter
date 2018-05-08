//
//  ErrorDetailTableViewCell.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 23/01/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class ErrorDetailTableViewCell: UITableViewCell {
  
  // These are UI elements connected to UI elements in the Main.storyboard file
  @IBOutlet fileprivate var indexLabel: UILabel!
  @IBOutlet fileprivate var errorLabel: UILabel!
  
  // Will configure the UI elements to reflect the data
  func configure(withError error: Error, index: Int) {
    self.indexLabel.text = "\(index)"
    let extra = error.link == nil ? "" : "Tap this message to see more information."
    self.errorLabel.text = "\(error.message) \(extra)"
    selectionStyle = error.link == nil ? .none : .default
    accessoryType = error.link == nil ? .none : .disclosureIndicator
  }
  
}
