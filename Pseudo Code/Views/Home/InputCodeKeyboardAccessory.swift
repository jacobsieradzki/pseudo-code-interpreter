//
//  InputCodeKeyboardAccessory.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 09/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class InputCodeKeyboardAccessory: UIView {
  
  fileprivate let words = ["<-", "INPUT", "OUTPUT", "IF", "THEN", "ELSE", "END IF", "FOR", "TO", "NEXT", "WHILE", "END WHILE", "REPEAT", "UNTIL", "TRUE", "FALSE"]
  
  // Connections to user interface elements in the Main.storyboard file
  @IBOutlet fileprivate var collectionView: UICollectionView!
  
  // This function is a property of the keyboard accessory class and is assigned
  // to a closure in the InputCodeKeyboardAccessory class to respond to changes in
  // the keyboard accessory
  var didSelectWord: ((String) -> ())?
  
  // This method is called when the view has finished loading from the Main.storyboard file
  override func awakeFromNib() {
    super.awakeFromNib()
    collectionView.delegate = self
    collectionView.dataSource = self
    let nib = UINib(nibName: "InputCodeCollectionViewCell", bundle: Bundle.main)
    collectionView.register(nib, forCellWithReuseIdentifier: "WordCell")
  }
  
}

extension InputCodeKeyboardAccessory: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // A collection view works similar to a UITableView in that the data methods are similar but the appearance
  // is free as opposed to constrained to vertical, screen-width rows.
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return words.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as! InputCodeCollectionViewCell
    cell.configure(words[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didSelectWord?(words[indexPath.row])
  }
  
  // This will determine the size of a cell in the collection view cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 150.0, height: 40.0)
  }
  
  // This will determine the horizontal spacing in between items in a section
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5.0
  }
  
  // This will determine the insets in all directions for a section in the collection view
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(5, 5, 5, 5)
  }
  
}
