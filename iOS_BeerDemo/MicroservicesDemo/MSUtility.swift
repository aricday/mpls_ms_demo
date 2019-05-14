//
//  MSUtility.swift
//  MicroservicesDemo
//
//  Copyright © 2019 Broadcom. All rights reserved.
//

import Foundation

class MSUtility {
  
  // Calculate the verbal date representation of "time ago" instead of the time difference in ISO
  // https://gist.github.com/minorbug/468790060810e0d29545 for "x ago" time format
  class func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second]
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components(unitFlags, from: earliest, to: latest, options: [])
    
    if (components.year! >= 2) {
      return "\(components.year!) years ago"
    } else if (components.year! >= 1){
      if (numericDates){
        return "1 year ago"
      } else {
        return "Last year"
      }
    } else if (components.month! >= 2) {
      return "\(components.month!) months ago"
    } else if (components.month! >= 1){
      if (numericDates){
        return "1 month ago"
      } else {
        return "Last month"
      }
    } else if (components.weekOfYear! >= 2) {
      return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
      if (numericDates){
        return "1 week ago"
      } else {
        return "Last week"
      }
    } else if (components.day! >= 2) {
      return "\(components.day!) days ago"
    } else if (components.day! >= 1){
      if (numericDates){
        return "1 day ago"
      } else {
        return "Yesterday"
      }
    } else if (components.hour! >= 2) {
      return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
      if (numericDates){
        return "1 hour ago"
      } else {
        return "An hour ago"
      }
    } else if (components.minute! >= 2) {
      return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
      if (numericDates){
        return "1 minute ago"
      } else {
        return "A minute ago"
      }
    } else if (components.second! >= 3) {
      return "\(components.second!) seconds ago"
    } else {
      return "Just now"
    }
    
  }
  
  // Generate a UUID string for Boundary
  class func generateBoundaryString() -> String
  {
    return "------------------------\(UUID().uuidString)"
  }
  
}
