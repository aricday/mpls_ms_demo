//
//  LoginViewController.swift
//  MicroservicesDemo
//
//  Created by Chris Page on 6/20/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import UIKit
import MASFoundation
import MASUI
import AVKit
import AVFoundation

class LoginViewController: UIViewController {
  
  //  var avPlayer: AVPlayer!
  
  //Class Properties
  @IBOutlet weak var btnLogin: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // background animation
    guard let path = Bundle.main.path(forResource: "LoginAnimation", ofType:"mp4") else {
      debugPrint("LoginAnimation.mp4 not found")
      return
    }
    let player = AVPlayer(url: URL(fileURLWithPath: path))
    let playerLayer = AVPlayerLayer(player: player)
    //    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = self.view.bounds
    // catch the player notification and loop the video from the start
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
      DispatchQueue.main.async {
        player.seek(to: kCMTimeZero)
        player.play()
      }
    })
    self.view.layer.addSublayer(playerLayer)
    player.play()
    
    // CA Logo
    let image = UIImage(named: "ca_logo")
    let imageView = UIImageView(image: image!)
    imageView.frame = CGRect(x: 96, y: 20, width: 182, height: 120)
    self.view.addSubview(imageView)
    
    // start Button
    let startButton = UIButton(frame: CGRect(x: 100, y: 312, width: 174, height: 42))
    startButton.setTitle("Start", for: .normal)
    startButton.setTitleColor(UIColor.white, for: .normal)
    startButton.center = self.view.center
    startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
    startButton.backgroundColor = .clear
    startButton.layer.cornerRadius = 5
    startButton.layer.borderWidth = 2
    startButton.layer.borderColor = UIColor.white.cgColor
    self.view.addSubview(startButton)
    
    // reset Button
    let resetButton = UIButton(frame: CGRect(x: 100, y: 600, width: 174, height: 42))
    resetButton.setTitle("Reset", for: .normal)
    resetButton.setTitleColor(UIColor.white, for: .normal)
    //    resetButton.center = self.view.center
    resetButton.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
    resetButton.backgroundColor = .clear
    resetButton.layer.cornerRadius = 5
    resetButton.layer.borderWidth = 2
    resetButton.layer.borderColor = UIColor.white.cgColor
    self.view.addSubview(resetButton)
    
    //
    // MAS Start
    //
    self.startMAS()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
  }
  
  func buttonAction(sender: UIButton!) {
    print("Button tapped")
  }
  
  //
  // MAS SDK Start
  //
  func startMAS() {
    
    //Set grant flow to password
    MAS.setGrantFlow(MASGrantFlow.password)
    
    //Start the MAS SDK with the default msso_config.json file configuration
    MAS.start(withDefaultConfiguration: true) { (completed: Bool, error: Error?) in
      
      if (error != nil) {
        print (error.debugDescription)
        
        // create the alert
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
      }
      
    }
    
  }
  
  //
  // MAS User Authentication Trigger
  //
  @IBAction func startButtonAction(_ sender: Any) {
    
    MAS.getFrom("/protected/resource/products", withParameters: [:], andHeaders: nil, completion: { (response, error) in
      
      if (error != nil) {
        var message:String
        let errorCode:Int = (error! as NSError).code
        switch errorCode {
        case 1002000:
          message = "Possible invalid client... Export a new msso_config.json:\n\(error!.localizedDescription)"
        case 1002107:
          message = "Possible invalid device... Clear simluator settings:\n\(error!.localizedDescription)"
        default:
          message = (error?.localizedDescription)!
        }
        
        print(error.debugDescription)
        // create the alert
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
      } else {
        
        //Show the APICall ViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "mainTabBarController")
        self.present(controller, animated: true, completion: nil)
        
      }
      
      
    })
    
  }
  
  
  //
  // MAS Reset
  //
  func resetButtonAction(_ sender: Any) {
    print("Reset pressed")

    if (MASDevice.current()?.isRegistered)! {
      // prompt for confirmation
      let alert = UIAlertController(title: "Reset Device", message: "Certificate and tokens will be purged on device:\n" +
        "name:\(MASDevice.current()!.name)\n" +
        "identifier:\(MASDevice.current()!.identifier)", preferredStyle: UIAlertControllerStyle.alert)
      
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        if (MASDevice.current()?.isRegistered)! {
          print("Deregistering device: \(MASDevice.current()!)")
          MASDevice.current()?.deregister(completion: { (completed: Bool, error: Error?) in
            if (error != nil) {
              print(error as Any)
              MASDevice.current()?.resetLocally()
            }
          })
        }
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        print("Canceled")
      }))
      // show the alert
      self.present(alert, animated: true, completion: nil)
    }
  }
  
}
