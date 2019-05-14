//
//  BeerDetailsTableViewController.swift
//  MicroservicesDemo
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI


class BeerDetailsViewController: UIViewController {
  
  
  @IBOutlet var beerBrewery: UITextField!
  @IBOutlet var beerName: UITextField!
  @IBOutlet var beerStyle: UITextField!
  @IBOutlet var beerPrice: UITextField!
  @IBOutlet var beerPriceComment: UITextField!
  
  
  //  var beerId: String = ""
  var beer: NSDictionary!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "Details"
    
    print("\(String(describing: beer))")
    self.beerBrewery.attributedPlaceholder = NSAttributedString(string: "Brewery", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerBrewery.textColor = UIColor.white
    self.beerName.attributedPlaceholder = NSAttributedString(string: "Name", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerName.textColor = UIColor.white
    self.beerStyle.attributedPlaceholder = NSAttributedString(string: "Style", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerStyle.textColor = UIColor.white
    self.beerPrice.attributedPlaceholder = NSAttributedString(string: "Price", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerPrice.textColor = UIColor.white
    self.beerPrice.attributedPlaceholder = NSAttributedString(string: "Price Comment", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerPriceComment.textColor = UIColor.white
    // values
    self.beerBrewery.text = (beer.value(forKey: "brewery") as? String) ?? "unknown"
    self.beerName.text = (beer.value(forKey: "name") as? String) ?? "unknown"
    self.beerStyle.text = (beer.value(forKey: "style") as? String) ?? "unknown"
    self.beerPrice.text = String(describing: beer.value(forKey: "price") as? NSNumber ?? 0.00)
    self.beerPriceComment.text = (beer.value(forKey: "price_comment") as? String) ?? "unknown"
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
