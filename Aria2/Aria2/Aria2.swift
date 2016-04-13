//
//  Aria2.swift
//  Aria2
//
//  Created by ShinCurry on 16/4/9.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Starscream
import SwiftyJSON

public class Aria2 {
    
    public static let shared = Aria2()
    
    var socket: WebSocket!
    var timer: NSTimer!
    
    public init() {
        socket = WebSocket(url: NSURL(string: "ws://localhost:6800/jsonrpc")!)
        socket.delegate = self
    }
    
    public func connect() {
        socket.connect()
    }
    public func disconnect() {
        socket.disconnect()
    }
    
    
    
    
    
    
    public var didReceiveMessage: ((socket: WebSocket, text: String) -> Void)?
    
    public func tellActive() {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2tellactive\", \"method\":\"aria2.tellActive\",\"params\":[]}"
        request(socketString)
    }
}


extension Aria2 {
    private func request(jsonString: String) {
        let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        self.socket.writeData(data)
    }
    
}


extension Aria2: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocket) {
        
    }
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("\(error)")
        timer = nil
//        socket.connect()
    }
    public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("websocketDidReceiveData")
        print(data)
    }
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("websocketDidReceiveMessage")
        didReceiveMessage?(socket: socket, text: text)
    }
}