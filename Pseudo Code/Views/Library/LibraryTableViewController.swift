//
//  LibraryTableViewController.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 28/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

class LibraryTableViewController: UITableViewController {
  
  var currentCode: [String]!
  var loadCode: (([String]) -> ())!
  
  // This is the key for the library in the UserDefaults memory dictionary
  fileprivate let libraryKey = "CodeLibrary"
  fileprivate var collections: [String : [String]] = [:]
  fileprivate var keys: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getCollections()
  }
  
  fileprivate func getCollections() {
    collections = (UserDefaults.standard.dictionary(forKey: libraryKey) as? [String : [String]]) ?? [:]
    keys = Array(collections.keys).sorted()
    tableView.reloadData()
  }
  
  fileprivate func setCollections(_ collections: [String : [String]]) {
    UserDefaults.standard.set(collections, forKey: libraryKey)
    self.collections = collections
    self.keys = Array(collections.keys).sorted()
  }
  
  fileprivate func currentCodeIsValid() -> Bool {
    return (currentCode.count > 1) || (currentCode.count > 0 && !currentCode[0].isEmpty)
  }
  
  // This will show a popup dialog that will ask the user to type in a title
  // to save their code snippet under.
  fileprivate func showNewNameAlert(_ callback: @escaping ((String) -> ())) {
    let alert = UIAlertController(title: "Save code", message: "Select a unique title for your code snippet.", preferredStyle: .alert)
    alert.addTextField { textField in
      textField.placeholder = "Title..."
    }
    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
      if let text = alert.textFields?[0].text, !text.isEmpty {
        callback(text)
      }
      alert.dismiss(animated: true, completion: nil)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
      alert.dismiss(animated: true, completion: nil)
    }))
    present(alert, animated: true, completion: nil)
  }
  
  // This is connected to the Close button in the Main.storyboard and will be
  // called when it is tapped
  @IBAction fileprivate func closePressed() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : keys.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
    cell.textLabel?.text = indexPath.section == 0 ? "Save current code" : keys[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.section == 0 && currentCodeIsValid() {
      showNewNameAlert { name in
        self.collections[name] = self.currentCode
        self.setCollections(self.collections)
        self.tableView.reloadData()
      }
    } else if indexPath.section == 1 {
      if let code = collections[keys[indexPath.row]] {
        loadCode(code)
        navigationController?.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == 1
  }
  
  // This enables the default iOS functionality to swipe right to left on a table view cell
  // to reveal a delete button. When the delete button is tapped, the following code will run.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      collections.removeValue(forKey: keys[indexPath.row])
      setCollections(collections)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
}
