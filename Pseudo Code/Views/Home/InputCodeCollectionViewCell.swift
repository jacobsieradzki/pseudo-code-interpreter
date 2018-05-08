//
//  InputCodeCollectionViewCell.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 09/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class InputCodeCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet fileprivate var container: UIView!
  @IBOutlet fileprivate var label: UILabel!
  
  // This method is called when the view has finished loading from the Main.storyboard file
  override func awakeFromNib() {
    super.awakeFromNib()
    layer.masksToBounds = false
    backgroundColor = .clear
    container.layer.cornerRadius = 4
    container.layer.masksToBounds = true
  }
  
  // Changes the appearance of the table view cell
  func configure(_ text: String) {
    self.label.text = text
  }
    
}
