//
//  AddBeerViewController.swift
//  MicroservicesDemo
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import SVProgressHUD

class AddBeerViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet var beerBrewery: UITextField!
  @IBOutlet var beerName: UITextField!
  @IBOutlet var beerStyle: UITextField!
  @IBOutlet var beerPrice: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "Add Beer"

    self.beerPrice.delegate = self
    self.beerPrice.attributedPlaceholder = NSAttributedString(string: "Price", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerPrice.textColor = UIColor.white
    self.beerBrewery.attributedPlaceholder = NSAttributedString(string: "Brewery", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerBrewery.textColor = UIColor.white
    self.beerName.attributedPlaceholder = NSAttributedString(string: "Name", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerName.textColor = UIColor.white
    self.beerStyle.attributedPlaceholder = NSAttributedString(string: "Style", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.lightGray]))
    self.beerStyle.textColor = UIColor.white
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func onSubmit(_ sender: Any) {
    print("submit pressed")
    if self.beerName.text == "" {
      let alert = UIAlertController(title: "Error", message: "At least the 'Name' is required'", preferredStyle: UIAlertController.Style.alert)
      
      // add an action (button)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
      
      // show the alert
      self.present(alert, animated: true, completion: nil)
    } else {
      
      //Show the progress bar
      SVProgressHUD.show(withStatus: Common.Dialogs.addingNewBeer)
      
      self.submitForm()
      
//      //Show the progress bar
//      SVProgressHUD.show(withStatus: Common.Dialogs.loadingBeerList)
      
      // dissmiss controller. need to wait 1 second so the Rate Limiting isn't triggered.
      let switchViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController
      let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
      DispatchQueue.main.asyncAfter(deadline: when) {

        self.navigationController?.showDetailViewController(switchViewController, sender: nil)
        //Stop the progress bar
        SVProgressHUD.dismiss()
      }

    }
  }
  
  // Submit form
  func submitForm() {
    
    if (MASUser.current() != nil) {
      print(MASUser.current()?.accessToken as Any)
    }
    
    let params: [String:String] = [
      "name": self.beerName.text!,
      "brewery": self.beerBrewery.text!,
      "style": self.beerStyle.text!,
      "price": self.beerPrice.text!
    ]
    //    MAS.post(to: Common.Constants.urlBeerList, withParameters: ["auth":Common.Constants.lacAuthKey], andHeaders: [:], completion:  { (response, error) in
    
    MAS.post(to: Common.Constants.urlBeerListWithAuth, withParameters: params, andHeaders: [:], completion:  { (response, error) in
      
      if (error != nil) {
        var message:String
        let errorCode:Int = (error! as NSError).code
        switch errorCode {
        case -1011:
          message = "URL:'\(Common.Constants.urlBeerList)'?:\n" +
            "message: \(error!.localizedDescription)\n" +
          "error: \(response![MASResponseInfoBodyInfoKey]!)"
        default:
          message = "\(error!.localizedDescription)"
        }
        
        print(error.debugDescription)
        // create the alert
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
      } else {
        
        if let headerResponse = response?[MASResponseInfoHeaderInfoKey] as? [String: AnyObject] {
          print(headerResponse)
        }
        print(response?[MASResponseInfoBodyInfoKey]! as Any)
        
      }
      
    })
    
    
  }
  
  
  // valid decmial only for beerPrice
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let text = (textField.text ?? "") as NSString
    let newText = text.replacingCharacters(in: range, with: string)
    if let regex = try? NSRegularExpression(pattern: "^[0-9]*((\\.|,)[0-9]{0,2})?$", options: .caseInsensitive) {
      return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
    }
    return false
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
