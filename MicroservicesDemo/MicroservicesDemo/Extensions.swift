//
//  Extensions.swift
//  MicroservicesDemo
//
//  Created by Christopher Page on 7/9/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

import Foundation

// enable base64 as part of the String type
extension String {
  //: ### Base64 encoding a string
  func base64Encoded() -> String? {
    if let data = self.data(using: .utf8) {
      return data.base64EncodedString()
    }
    return nil
  }
  
  //: ### Base64 decoding a string
  func base64Decoded() -> String? {
    if let data = Data(base64Encoded: self) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
}
