//
//  ErrorDetailTableViewHandler.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 23/01/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class ErrorDetailTableViewHandler: NSObject {
  
  fileprivate let cellIdentifier = "ErrorCell"
  fileprivate let errors: [Error]
  
  init(errors: [Error]) {
    self.errors = errors
  }

}

extension ErrorDetailTableViewHandler: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return errors.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ErrorDetailTableViewCell
    cell.configure(withError: errors[indexPath.row], index: indexPath.row+1)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let link = errors[indexPath.row].link else {
      return
    }
    
    // This will open the URL in the variable 'link'
    // This will cause iOS to switch apps to the browser and automatically load this link
    if UIApplication.shared.canOpenURL(link) {
      UIApplication.shared.open(link, options: [:], completionHandler: nil)
    }
  }
  
}
