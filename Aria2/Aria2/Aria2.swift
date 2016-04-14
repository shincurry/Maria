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
    
//    public static let shared = Aria2()
    
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
    
//    var baseJSON: JSON = {
//        let base = ["jsonrpc": "2.0",
//                    "id"]
//    }()
    
    
    
    public var isConnected: Bool {
        get {
            return socket.isConnected
        }
    }
    
    public var didReceiveMessage: ((socket: WebSocket, text: String) -> Void)?
    
    public func tellActive() {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2tellactive\", \"method\":\"aria2.tellActive\",\"params\":[]}"
        request(socketString)
    }
    
    public func shutdown() {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2shutdown\", \"method\":\"aria2.shutdown\",\"params\":[]}"
        request(socketString)
    }
    
    public func downloadCompleted() {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2onDownloadComplete\", \"method\":\"aria2.onDownloadComplete\",\"params\":[]}"
        request(socketString)
    }
    
    /**
     JSON parameters key
     ----
     bt-max-peers
     bt-request-peer-speed-limit
     bt-remove-unselected-file
     force-save
     max-download-limit
     max-upload-limit
     ----
     
     - parameter jsonString: <#jsonString description#>
     */
    public func changeOption(jsonString: String) {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2changeOption\", \"method\":\"aria2.changeOption\",\"params\":[\(jsonString)]}"
        request(socketString)
    }
    
    public func changeGlobalOption(jsonString: String) {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2changeGlobalOption\", \"method\":\"aria2.changeGlobalOption\",\"params\":[\(jsonString)]}"
        print(socketString)
        request(socketString)
    }
    
    public func openSpeedLimitMode(downloadSpeed: String, uploadSpeed: String) {
        changeGlobalOption("{\"max-overall-download-limit\": \"\(downloadSpeed)K\", \"max-overall-upload-limit\": \"\(uploadSpeed)K\"}")
    }

}


extension Aria2 {
    private func request(jsonString: String) {
        let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        self.socket.writeData(data)
        print("request")
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
        print(text)
        didReceiveMessage?(socket: socket, text: text)
    }
}