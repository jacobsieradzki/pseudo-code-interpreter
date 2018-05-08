//
//  CodeErrorHandler.swift
//  Pseudo Code
//
//  Created by Jake Sieradzki on 28/02/2018.
//  Copyright © 2018 sieradzki. All rights reserved.
//

import UIKit

struct Error {
  var code: Int
  var message: String
  var link: URL?
  
  init(code: Int, message: String, link: String?) {
    self.code = code
    self.message = message
    if let link = link {
      self.link = URL(string: link)
    }
  }
}

// This class will parse a line of string and recognise syntax errors.
class CodeErrorHandler: NSObject {
  
  // This is the public static method which will return all syntax errors that this line of code contains.
  static func provideError(line: String) -> [Error] {
    let codes = errorCodes(line: line)
    let errors = codes.map({ return error(forCode: $0) })
    return errors
  }
  
  // Each error code is matched to an Error object, which contains a message and an optional link
  fileprivate static func errorCodes(line: String) -> [Int] {
    let parser = CommandParser(command: line)
    var codes: [Int] = []
    
    // Incorrect keyword syntax error test
    if parser.type == nil {
      let uppercase = line.uppercased()
      let newType = CommandParser(command: uppercase).type
      if newType != nil {
        codes.append(1)
      }
    }
    
    // Unterminated string literal syntax error test
    var numberOfApostrophes = 0
    line.forEach({ numberOfApostrophes += $0 == "'" ? 1 : 0 })
    if numberOfApostrophes % 2 > 0 {
      codes.append(2)
    }
    
    // Space for more tests can be added here...
    
    // If there are no recognised and specific errors, then the only error will be 'Syntax error'
    // with no explanation.
    if codes.count == 0 {
      codes.append(0)
    }
    
    return codes
  }
  
  // Here, a switch statement will pair Int codes to Error objects.
  fileprivate static func error(forCode code: Int) -> Error {
    switch code {
    case 1:   return Error(code: code, message: "One of your keywords may not be the correct case.", link: "http://www.ocr.org.uk/Images/202654-pseudocode-guide.pdf")
    case 2:   return Error(code: code, message: "Unterminated string literal.", link: nil)
    default:  break
    }
    return Error(code: 0, message: "Syntax error", link: nil)
  }

}
