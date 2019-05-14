//
//  BeersTableViewController.swift
//  MicroservicesDemo
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI
import SVProgressHUD


class BeersTableViewController: UITableViewController {
  
  
  @IBOutlet var refresh: UIBarButtonItem!
  @IBOutlet var BeersTableView: UITableView!
  
  var BeerList:NSMutableArray! = NSMutableArray()
  var beerToDeleteIndexPath:NSIndexPath! = nil
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl!.addTarget(self, action: #selector(BeersTableViewController.didRefreshControl), for: UIControl.Event.valueChanged)
    
    self.getBeerList()
    
  }
  
  //
  // Function to grab all the available Beers from the demo environment
  //
  func getBeerList() {
    
    //Show the progress bar
    SVProgressHUD.show(withStatus: Common.Dialogs.loadingBeerList)
    
    if (MASUser.current() != nil) {
      print(MASUser.current()?.accessToken as Any)
    }
    
    //    MAS.getFrom(Common.Constants.urlBeerList, withParameters: nil, andHeaders: nil, request: MASRequestResponseType.json, responseType: MASRequestResponseType.json, completion: { (response, error) in
    MAS.getFrom(Common.Constants.urlBeerList, withParameters: ["auth":Common.Constants.lacAuthKey, "sysorder":"(updated_at:desc)"], andHeaders: nil, completion: { (response, error) in
      
      //Stop the progress bar
      SVProgressHUD.dismiss()
      
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
        //  print(response?[MASResponseInfoBodyInfoKey]! as Any)
        if let jsonArray = response?[MASResponseInfoBodyInfoKey] as? NSArray {
          //          print(jsonArray)
            self.BeerList = (jsonArray.mutableCopy() as! NSMutableArray)
          self.BeersTableView.reloadData()
          
        } else {
          let alert = UIAlertController(title: "Error", message: "Wrong data format", preferredStyle: UIAlertController.Style.alert)
          
          // add an action (button)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
          
          // show the alert
          self.present(alert, animated: true, completion: nil)
        }
        
      }
      
    })
    
    
  }
  
  // refresh view
  @objc func didRefreshControl(sender:AnyObject)
  {
    // Updating your data here...
    print("refreshing")
    self.getBeerList()
    self.refreshControl?.endRefreshing()
    
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.BeerList.count
  }
  
  
  //
  // Table View loading and Cell Configuration
  //
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellBeers", for: indexPath) as! BeersTableViewCell
    cell.delegate = self
    
    if let beer = self.BeerList[indexPath.row] as? NSDictionary {
      cell.beerName.text = (beer.value(forKey: "name") as? String) ?? "unknown"
      cell.beerStyle.text = (beer.value(forKey: "style") as? String) ?? "unknown"
      
      if ((beer.value(forKey: "price") as? NSNumber ?? nil) != nil) {
        //Formatting the numbers to currency
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        cell.beerPrice.text = currencyFormatter.string(from: (beer["price"] as! NSNumber?)!)
      } else {
        cell.beerPrice.text = "unknown"
      }
      
      if ((beer.value(forKey: "updated_at") as? String ?? nil) != nil) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: beer.value(forKey: "updated_at") as! String ) {
          cell.beerUpdatedAt.text = MSUtility.timeAgoSinceDate(date, numericDates: true)
        } else {
          cell.beerUpdatedAt.text = "Bad date format"
        }
      } else {
        cell.beerUpdatedAt.text = "Bad date format"
      }
      
      if (beer.value(forKey: "image") != nil) {
        print(beer.value(forKey: "image") as Any)
      } else {
        // Change the image border to circle
        cell.beerImage.layer.cornerRadius = cell.beerImage.frame.size.width / 2;
        cell.beerImage.clipsToBounds = true;
        cell.beerImage.image = UIImage(named: "background")
      }
      
      if ((beer.value(forKey: "likes") as? Int ?? nil) != nil) {
        cell.beerLikes.isHidden = false
        let beerLikes = beer.value(forKey: "likes") as! Int
        cell.beerLikes.text = "\(beerLikes) likes"
      }
    }
    
    return cell
  }
  
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      print("deleting")
      if let beerToDelete = self.BeerList[indexPath.row] as? NSDictionary {
        beerToDeleteIndexPath = indexPath as NSIndexPath
        self.confirmDelete(beer: beerToDelete)
      }
    } else {
      print("\(editingStyle) is not defined yet")
    }
    //   } else if editingStyle == .insert {
    //    Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //   }
  }
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  // MARK: - Table view cell selection
  
  // Cell Selection
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("didSelectRowAt")
  }
  
  // Preparation to segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print(sender as Any)
    
    if let identifier = segue.identifier {
      switch identifier {
      case "showBeerDetails":
        print("Need to pull data from the cell to next controller")
        let rowSelected = (sender as! IndexPath).row
        let controller = segue.destination as! BeerDetailsViewController
        controller.beer = (self.BeerList.object(at: rowSelected) as! NSDictionary)
        //      case "showAddBeer":
      //        let controller = segue.destination as! AddBeerViewController
      default:
        print("No segue defined")
        break
      }
      
    }
    // Set a custom Nav Bar button
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
  }
  
  // send a PUT to simulate 'like'
  func updateBeer(beer: NSDictionary) {
    
    let beerId = String(describing: beer.value(forKey: "id") as! NSNumber)
    // Quick logic to increment "likes" for a Beer
    var likes:Int!
    if let beerLikes = (beer.value(forKey: "likes") as? Int) {
      likes = beerLikes + 1
    } else {
      likes = 1
    }
    
    if let beerMetadata = beer["@metadata"] as? NSDictionary {
      let href = beerMetadata.value(forKey: "href") as! String
      print(href)
      //      let hrefEscaped = href.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
      //      print(hrefEscaped)
      
      let checksum = beerMetadata.value(forKey: "checksum") as! String
      
      let body = [ "likes": "\(likes!)", "@metadata" : [ "href": href, "checksum": checksum ] ] as [String : Any]
      
      var jsonDataBase64:String!
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        // here "jsonData" is the dictionary encoded in JSON data
        
        var jsonDataString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        // hack to remoce the backslash of JSONSerialization
        jsonDataString = jsonDataString.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range:nil)
        //
        jsonDataBase64 = String(describing: jsonDataString).base64Encoded()
        print(jsonDataBase64 as Any)
        //
      } catch {
        print(error.localizedDescription)
      }
      
      SVProgressHUD.show(withStatus: Common.Dialogs.updatingBeer)
      
      // Need to append the auth to thr URL for now.
      MAS.patch(to: Common.Constants.urlBeerList + "/\(beerId)?auth=\(Common.Constants.lacAuthKey)", withParameters: [ "body-base64": jsonDataBase64!], andHeaders: ["X-body-base64":"true"], completion: { (response, error) in
        
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
      
      usleep(750000) //will sleep for .75 second to avoid strict Rate Limit
      SVProgressHUD.dismiss()
      
    }else {
      print ("metadata needs to exist")
    }
  }
  
  
  // confirm delete of beer
  func confirmDelete(beer: NSDictionary) {
    let beerName = beer.value(forKey: "name") as! String
    // beer.value(forKey: "@metadata") does not work
    let alert = UIAlertController(title: "Are you sure you want to remove?\n\(beerName)", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
    
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handleDeleteBeer))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteBeer))
    // show the alert
    self.present(alert, animated: true, completion: nil)
  }
  
  // handle the Delete function for beer
  func handleDeleteBeer(alertAction: UIAlertAction!) -> Void {
    if let indexPath = beerToDeleteIndexPath {
      if let beer = self.BeerList[indexPath.row] as? NSDictionary {
        tableView.beginUpdates()
        let beerId = String(describing: beer.value(forKey: "id") as! NSNumber)
        if let beerMetadata = beer["@metadata"] as? NSDictionary {
          print(beerMetadata)
          if let beerCheckSum = beerMetadata.value(forKey: "checksum") as? String {
            print(beerCheckSum)
            //      self.deleteBeer(beerId: beerId, checksum: beerCheckSum)
            self.deleteBeer(beerId: beerId, checksum: beerCheckSum)
            self.BeerList.removeObject(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
          } else {
            print ("checksum needs to exist")
          }
        }else {
          print ("metadata needs to exist")
        }
        beerToDeleteIndexPath = nil
        tableView.endUpdates()
      }
    }
  }
  
  func cancelDeleteBeer(alertAction: UIAlertAction!) {
    print("Canceled")
    beerToDeleteIndexPath = nil
  }
  
  // Delete the beer
  func deleteBeer(beerId: String, checksum: String) {
    //Show the progress bar
    SVProgressHUD.show(withStatus: Common.Dialogs.deletingBeer)
    
    if (MASUser.current() != nil) {
      print(MASUser.current()?.accessToken as Any)
    }
    
    MAS.delete(from: Common.Constants.urlBeerList + "/\(beerId)", withParameters: ["auth":Common.Constants.lacAuthKey,"checksum":checksum], andHeaders: [:], completion:  { (response, error) in
      
      //Stop the progress bar
      SVProgressHUD.dismiss()
      
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
  //
  // Button refresh tapped
  //
  @IBAction func refreshAction(_ sender: Any) {
    self.getBeerList()
  }
  
  // custom double and single taps
  
  func tableViewCell(singleTapActionDelegatedFrom cell: BeersTableViewCell) {
    let indexPath = tableView.indexPath(for: cell)
    print("singleTap \(String(describing: indexPath)) ")
    DispatchQueue.main.async() {
      // Do stuff to UI
      self.performSegue(withIdentifier: "showBeerDetails", sender: indexPath)
    }
  }
  
  // custom double and single taps
  
  func tableViewCell(doubleTapActionDelegatedFrom cell: BeersTableViewCell) {
    let indexPath = tableView.indexPath(for: cell)
    print("doubleTap \(String(describing: indexPath)) ")
    // Do stuff to UI
    if let beer = self.BeerList[(indexPath?.row)!] as? NSDictionary {
      print("trying to update beer")
      self.updateBeer(beer: beer)
      self.getBeerList()
    }
  }
  
  
}

