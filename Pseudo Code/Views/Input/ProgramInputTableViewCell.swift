//
//  ProgramInputTableViewCell.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 08/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class ProgramInputTableViewCell: UITableViewCell {
  
  // These UI elements are connected to UI elements in the Main.storybaord file
  @IBOutlet fileprivate var numberLabel: UILabel!
  @IBOutlet fileprivate var fieldContainer: UIView!
  @IBOutlet fileprivate var field: UITextField!
  
  var inputtedText: String {
    return field.text ?? ""
  }
  
  // This method is called when the view has finished loading from the Main.storyboard file
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
    for view in [numberLabel, fieldContainer] {
      view?.layer.cornerRadius = 10
      view?.layer.masksToBounds = true
    }
  }
  
  func configure(_ indexPath: IndexPath) {
    numberLabel.text = "\(indexPath.row + 1)"
  }
  
}
