//
//  Sender.swift
//  Granted
//
//  Created by James Womack on 9/26/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

import Foundation

var boundary : String = "granted_boundary_for_post_data"

@objc class Sender : NSObject {
  // Something's not working here
  class func send(toUrl URL: NSURL, withFileUrl fileURL : NSURL) {
    let session : NSURLSession = createSession(URL, fileURL: fileURL)
    
    let request : NSMutableURLRequest = URLRequest(toUrl: URL, withFileUrl: fileURL)
    
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      println(response.MIMEType)
      println(NSString(data: data, encoding: NSUTF8StringEncoding))
    })
    task.resume()
  }
  
  class func URLRequest(toUrl URL: NSURL, withFileUrl fileURL : NSURL) -> NSMutableURLRequest {
    var request : NSMutableURLRequest = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "POST"
    request.HTTPBody   = data(fileURL)
    return request
  }
  
  class func dataFromString(string : String) -> NSData {
    return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
  }
  
  class func appendToDataFromString(data: NSMutableData, string : String) {
    data.appendData(dataFromString(string))
  }
  
  class func data(fileURL : NSURL) -> NSData {
    let components : NSArray = fileURL.pathComponents
    let filename : NSString = components.lastObject as NSString
    let rawData : NSData = NSData(contentsOfURL: fileURL)
    
    var data : NSMutableData = NSMutableData()
    
    let paddedBoundary = "--" + boundary + "\r\n"
    
    appendToDataFromString(data, string: paddedBoundary)
    appendToDataFromString(data, string: "Content-Disposition: form-data;")
    appendToDataFromString(data, string: "name=\"upload_file\";")
    appendToDataFromString(data, string: "filename=\""+filename+"\"\r\n")
    appendToDataFromString(data, string: "Content-Type: video/mp4\r\n\r\n")
    data.appendData(rawData)
    appendToDataFromString(data, string: "\r\n")
    appendToDataFromString(data, string: paddedBoundary)
    
    return data
  }
  
  class func createSession(URL: NSURL, fileURL : NSURL) -> NSURLSession {
    var config : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.HTTPAdditionalHeaders = ["Content-Type": "multipart/form-data; boundary=" + boundary]
    
    let session : NSURLSession = NSURLSession(configuration: config)
    
    return session
  }
}