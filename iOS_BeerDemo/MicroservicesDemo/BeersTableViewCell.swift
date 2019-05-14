//
//  BeersTableViewCell.swift
//  MicroservicesDemo
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//

import UIKit

class BeersTableViewCell: UITableViewCell {
  
  @IBOutlet weak var beerName: UILabel!
  @IBOutlet weak var beerStyle: UILabel!
  @IBOutlet weak var beerPrice: UILabel!
  @IBOutlet var beerImage: UIImageView!
  @IBOutlet var beerUpdatedAt: UILabel!
  @IBOutlet var beerLikes: UILabel!
  
  private var tapCounter = 0
  var delegate: BeersTableViewController?
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    self.beerLikes.isHidden = true
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
    addGestureRecognizer(tap)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @objc func tapAction() {
    
    if tapCounter == 0 {
      DispatchQueue.global(qos: .background).async {
        usleep(250000)
        if self.tapCounter > 1 {
          self.doubleTapAction()
        } else {
          self.singleTapAction()
        }
        self.tapCounter = 0
      }
    }
    tapCounter += 1
  }
  
  func singleTapAction() {
    delegate?.tableViewCell(singleTapActionDelegatedFrom: self)
  }
  
  func doubleTapAction() {
    delegate?.tableViewCell(doubleTapActionDelegatedFrom: self)
  }
  
}
