//
//  Common.swift
//  MicroservicesDemo
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//

import UIKit
import Foundation

class Common: NSObject {
  
  //Constants
  struct Constants {
    //API to provide the list of the Beers off of MSGW and LAC
    static let lacAuthKey = "ca-gateway:1"
    static let urlBeerList = "/beers"
    static let urlBeerListWithAuth = "/beers?auth=\(lacAuthKey)&sysorder=(updated_at:desc)"
    // themColor to match the lock background hex #010A1D?
    //    static let themeColor = UIColor(red:0.00, green:0.03, blue:0.05, alpha:1.0) // not dark enough
    //    static let themeColor = UIColor(red:0.00, green:0.00, blue:0.10, alpha:1.0) // close
    static let themeColor = UIColor(red:0.003, green:0.037, blue:0.112, alpha:1.0)
    static let themeSelectedColor = UIColor(red:0.16, green:0.84, blue:0.99, alpha:1.0)
    static let themeNotSelectedColor = UIColor.white
    
  }
  
  //Dialogs
  struct Dialogs {
    
    static let loadingBeerList = "Loading beer list, please wait..."
    static let addingNewBeer = "Adding new Beer..."
    static let updatingBeer = "Updating Beer..."
    static let deletingBeer = "Deleting Beer..."

  }
  
  struct Errors {
    static let e1001 = "[1001] - Error trying to approve the event"
  }
  
}
