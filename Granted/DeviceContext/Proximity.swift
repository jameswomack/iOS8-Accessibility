//
//  Proximity.swift
//  Granted
//
//  Created by James Womack on 9/27/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

import UIKit

@objc class Proximity : NSObject {
  typealias BooleanHandler = ((Bool) -> Void)
  
  let device : UIDevice = UIDevice.currentDevice()
  
  init(proximityChangeHandler handler : BooleanHandler){
    super.init()
    
    device.proximityMonitoringEnabled = true
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceProximityStateDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      println(self.device.proximityState)
      handler(self.device.proximityState)
    }
  }
}