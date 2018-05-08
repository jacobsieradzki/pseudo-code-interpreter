//
//  ErrorsTableViewController.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 23/01/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class ErrorsTableViewController: UITableViewController {
  
  var code: String!
  var line: Int!
  var errors: [Error]!
  
  // The delegate and data source of the tableView in this view controller
  // are set to this tableViewHandler property
  fileprivate var tableViewHandler: ErrorDetailTableViewHandler!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Errors on line \(line!+1)"
    tableViewHandler = ErrorDetailTableViewHandler(errors: errors)
    addHeader()
    tableView.rowHeight = 88.0
    tableView.delegate = tableViewHandler
    tableView.dataSource = tableViewHandler
    tableView.reloadData()
  }
  
  fileprivate func addHeader() {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1024, height: 80))
    label.backgroundColor = UIColor(red: 255/255, green: 169/255, blue: 169/255, alpha: 1.0)
    label.font = UIFont(name: "Hack", size: 37.0)!
    label.textAlignment = .center
    label.text = code
    tableView.tableHeaderView = label
  }
  
  // This is connected to the Close button in the Main.storyboard file and will
  // be called when it is tapped
  @IBAction fileprivate func closePressed() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
}
