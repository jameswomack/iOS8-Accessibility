//
//  HttpServer.swift
//
//  Created by Damian Kolakowski on 05/06/14.
//  Copyright (c) 2014 Damian Kołakowski. All rights reserved.
//

import Foundation

class HttpServer
{
    typealias Handler = HttpRequest -> HttpResponse
    
    var handlers: [(expression: NSRegularExpression, handler: Handler)] = []
    var acceptSocket: CInt = -1
    
    let matchingOptions = NSMatchingOptions(0)
    let expressionOptions = NSRegularExpressionOptions(0)
    
    subscript (path: String) -> Handler? {
        get {
            for (expression, handler) in handlers {
                let numberOfMatches: Int = expression.numberOfMatchesInString(path, options: matchingOptions, range: NSMakeRange(0, path.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)))
                if ( numberOfMatches > 0 ) {
                    return handler
                }
            }
            return nil
        }
        set ( newValue ) {
            if let regex: NSRegularExpression = NSRegularExpression.regularExpressionWithPattern(path, options: expressionOptions, error: nil) {
                if let newHandler = newValue {
                    handlers.append(expression: regex, handler: newHandler)
                }
            }
        }
    }
    
    subscript (path: String) -> String {
        get {
            return path
        }
        set ( directoryPath ) {
            if let regex = NSRegularExpression.regularExpressionWithPattern(path, options: expressionOptions, error: nil) {
                handlers.append(expression: regex, handler: { request in
                    let result = regex.firstMatchInString(request.url, options: self.matchingOptions, range: NSMakeRange(0, request.url.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)))
                    let nsPath: NSString = request.url
                    let filesPath = directoryPath.stringByExpandingTildeInPath
                        .stringByAppendingPathComponent(nsPath.substringWithRange(result!.rangeAtIndex(1)))
                    if let fileBody = String.stringWithContentsOfFile(filesPath, encoding: NSASCIIStringEncoding, error: nil) {
                        return HttpResponse.OK(.RAW(fileBody))
                    }
                    return HttpResponse.NotFound
                })
            }
        }
    }
    
    func routes() -> Array<String> {
        var results = [String]()
        for (expression,_) in handlers { results.append(expression.pattern) }
        return results
    }
    
    func start(listenPort: in_port_t = 3030, error:NSErrorPointer = nil) -> Bool {
        releaseAcceptSocket()
        if let socket = Socket.tcpForListen(port: listenPort, error: error) {
            acceptSocket = socket
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                while let socket = Socket.acceptClientSocket(self.acceptSocket) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        let parser = HttpParser()
                        while let request = parser.nextHttpRequest(socket) {
                            let keepAlive = parser.supportsKeepAlive(request.headers)
                            if let handler: Handler = self[request.url] {
                                HttpServer.writeResponse(socket, response: handler(request), keepAlive: keepAlive)
                            } else {
                                HttpServer.writeResponse(socket, response: HttpResponse.NotFound, keepAlive: keepAlive)
                            }
                            if !keepAlive { break }
                        }
                        Socket.release(socket)
                    });
                }
                self.releaseAcceptSocket()
            });
            return true
        }
        return false
    }
    
    class func writeResponse(socket: CInt, response: HttpResponse, keepAlive: Bool) {
        Socket.writeStringUTF8(socket, string: "HTTP/1.1 \(response.statusCode()) \(response.reasonPhrase())\r\n")
        let messageBody = response.body()
        if let body = messageBody {
            if let nsdata = body.dataUsingEncoding(NSUTF8StringEncoding) {
                Socket.writeStringUTF8(socket, string: "Content-Length: \(nsdata.length)\r\n")
            }
        } else {
            Socket.writeStringUTF8(socket, string: "Content-Length: 0\r\n")
        }
        if keepAlive {
            Socket.writeStringUTF8(socket, string: "Connection: keep-alive\r\n")
        }
        //Socket.writeStringUTF8(socket, string: "Content-Type: text/html; charset=UTF-8\r\n")
        for (name, value) in response.headers() {
            Socket.writeStringUTF8(socket, string: "\(name): \(value)\r\n")
        }
        Socket.writeStringUTF8(socket, string: "\r\n")
        if let body = messageBody {
            Socket.writeStringUTF8(socket, string: body)
        }
    }
    
    func stop() {
        releaseAcceptSocket()
    }
    
    func releaseAcceptSocket() {
        if ( acceptSocket != -1 ) {
            Socket.release(acceptSocket)
            acceptSocket = -1
        }
    }
}

