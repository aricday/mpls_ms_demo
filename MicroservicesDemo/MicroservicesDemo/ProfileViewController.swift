//
//  ProfileViewController.swift
//  MicroservicesDemo
//
//  Created by Christopher Page on 6/29/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  
  //
  // Button Logout tapped
  //
  @IBAction func logout(_ sender: Any) {
    
    if (MASUser.current() != nil) {
      let user = MASUser.current()?.userName
      
      if (MASUser.current()?.isAuthenticated)! {
        MASUser.current()?.logout(completion: { (completed: Bool, error: Error?) in
          if (error != nil) {
            //Something went wrong
            print("Error during user logout: \(error?.localizedDescription ?? "unknown")")
          } else {
            //No errors
            print("User \(user ?? "unknown") logged out - Showing the LoginViewController")
            //self.showLogin()
            let controller:UIViewController = LoginViewController()
            self.present(controller, animated: true, completion: nil)
          }
        })
      }
      
    }
    
  }
}
