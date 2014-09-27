//
//  Server.swift
//  Granted
//
//  Created by James Womack on 9/26/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

import UIKit

@objc class Server : NSObject {
  let server: HttpServer = HttpServer()
    
  func start() -> Bool {
    if let resDir = NSBundle.mainBundle().resourcePath {
      server["/resources/(.+)"] = resDir
    }
    server["/test"] = { request in
      var headersInfo = ""
      for (name, value) in request.headers {
        headersInfo += "\(name) : \(value)<br>"
      }
      let response = "<html><body>Url: \(request.url)<br>Method: \(request.method)<br>\(headersInfo)</body></html>"
      return .OK(.RAW(response))
    }
    server["/json"] = { request in
      return .OK(.JSON(["posts" : [[ "id" : 1, "message" : "hello world"],[ "id" : 2, "message" : "sample message"]], "new_updates" : false]))
    }
    server["/redirect"] = { request in
      return .MovedPermanently("http://www.google.com")
    }
    server["/long"] = { request in
      var longResponse = ""
      for k in 0..<1000 { longResponse += "(\(k)),->" }
      return .OK(.RAW(longResponse))
    }
    server["/demo"] = { request in
      return .OK(.RAW("<html><body><center><h2>Hello Swift</h2>" +
        "<img src=\"https://devimages.apple.com.edgekey.net/swift/images/swift-hero_2x.png\"/><br>" +
        "<h4>\(UIDevice().name), \(UIDevice().systemVersion)</h4></center></body></html>"))
    }
    server["/"] = { request in
      var listPage = "<html><body>Available services:<br><ul>"
      for item in self.server.routes() {
        listPage += "<li><a href=\"\(item)\">\(item)</a></li>"
      }
      listPage += "</ul></body></html>"
      return .OK(.RAW(listPage))
    }
    var error: NSError?
    if !server.start(error: &error) {
      println("Server start error: \(error)")
    }
    return true
  }
}