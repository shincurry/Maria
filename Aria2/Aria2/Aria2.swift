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
    
    public static let shared: Aria2 = {
        let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
        let baseHost = "http" + (defaults.boolForKey("SSLEnabled") ? "s" : "") + "://"
        let host = defaults.objectForKey("RPCServerHost") as! String
        let port = defaults.objectForKey("RPCServerPort") as! String
        let path = defaults.objectForKey("RPCServerPath") as! String
        return Aria2(url: baseHost + host + ":" + port + path)
    }()
    
    var secret: String!
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    var socket: WebSocket!
    
    public init(url: String) {
        socket = WebSocket(url: NSURL(string: url)!)
        socket.delegate = self
        secret = defaults.objectForKey("RPCServerSecret") as! String
    }
    
    public func connect() {
        socket.connect()
    }
    public var onConnect: (() -> Void)?
    
    public func disconnect() {
        socket.disconnect()
    }
    public var onDisconnect: (() -> Void)?
    
    
    public var isConnected: Bool {
        get {
            return socket.isConnected
        }
    }
    
    public var didReceiveMessage: ((socket: WebSocket, text: String) -> Void)?
    
   
    public var getActives: ((results: JSON) -> Void)?
    public var getGlobalStatus: ((result: JSON) -> Void)?

    
    public func shutdown() {
        request(method: .shutdown, params: "")
    }
    
    
    private var getDownloadStatus: ((results: JSON) -> Void)?
    public var downloadCompleted: ((name: String, folderPath: String) -> Void)?
    public var downloadPaused: ((name: String) -> Void)?
    public var downloadStarted: ((name: String) -> Void)?
    public var downloadStopped: ((name: String) -> Void)?
    public var downloadError: ((name: String) -> Void)?
    
    
    
    
    public func globalSpeedLimit(downloadSpeed downloadSpeed: Int, uploadSpeed: Int) {
        
        request(method: .changeGlobalOption, id: "aria2.changeGlobalOption.globalSpeedLimit", params: "{\"max-overall-download-limit\": \"\(speedToString(downloadSpeed))\", \"max-overall-upload-limit\": \"\(speedToString(uploadSpeed))\"}")
        
    }
    public func lowSpeedLimit(downloadSpeed downloadSpeed: Int, uploadSpeed: Int) {
        func speedToString(value: Int) -> String {
            var valueString = "\(value)"
            if value != 0 {
                valueString += "K"
            }
            return valueString
        }
        
        request(method: .changeGlobalOption, id: "aria2.changeGlobalOption.lowSpeedLimit", params: "{\"max-overall-download-limit\": \"\(speedToString(downloadSpeed))\", \"max-overall-upload-limit\": \"\(speedToString(uploadSpeed))\"}")
    }
    private func speedToString(value: Int) -> String {
        var valueString = "\(value)"
        if value != 0 {
            valueString += "K"
        }
        return valueString
    }
    
    public var globalSpeedLimitOK: ((result: JSON) -> Void)?
    public var lowSpeedLimitOK: ((result: JSON) -> Void)?
    
    
    
    public func request(method method: Aria2Method, params: String) {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"\(method.rawValue)\", \"method\":\"aria2.\(method.rawValue)\",\"params\":[\"token:\(secret)\", \(params)]}"
        
        let data: NSData = socketString.dataUsingEncoding(NSUTF8StringEncoding)!
        self.socket.writeData(data)
    }
    public func request(method method: Aria2Method, id: String, params: String) {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"\(id)\", \"method\":\"aria2.\(method.rawValue)\",\"params\":[\"token:\(secret)\", \(params)]}"
        let data: NSData = socketString.dataUsingEncoding(NSUTF8StringEncoding)!
        self.socket.writeData(data)
    }
}



extension Aria2: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocket) {
        print("WebSocket connected")
        onConnect?()
    }
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("WebSocket disconnected: \(error)")
        onDisconnect?()
    }
    public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print(data)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let results = JSON(data: text.dataUsingEncoding(NSUTF8StringEncoding)!)
        if let idString = results["id"].string {
            
            if let method = Aria2Method(rawValue: idString) {
                switch method {
                case .getGlobalStat:
                    getGlobalStatus?(result: results)
                case .tellActive:
                    getActives?(results: results["result"])
                case .shutdown:
                    break
                case .tellStatus:
                    break
                default:
                    break
                }
            }
            
            switch idString {
            case "aria2.tellStatus.downloadStatus":
                getDownloadStatus!(results: results)
            case "aria2.changeGlobalOption.globalSpeedLimit":
                globalSpeedLimitOK?(result: results)
            case "aria2.changeGlobalOption.lowSpeedLimit":
                lowSpeedLimitOK?(result: results)
            default:
                break
            }

        }
        
        if let methodString = results["method"].string {
            let rawValue = methodString.componentsSeparatedByString(".")[1]
            let method = Aria2Method(rawValue: rawValue)!

            getDownloadStatus = { result in
                var downloadName = ""
                if let btName = result["result"]["bittorrent"]["info"]["name"].string {
                    downloadName = btName
                } else {
                    downloadName = result["result"]["files"][0]["path"].stringValue.componentsSeparatedByString("/").last!
                }
                
                switch method {
                case .onDownloadStart:
                    self.downloadStarted?(name: downloadName)
                case .onDownloadPause:
                    self.downloadPaused?(name: downloadName)
                case .onDownloadStop:
                    self.downloadStopped?(name: downloadName)
                case .onBtDownloadComplete:
                    fallthrough
                case .onDownloadComplete:
                    let path = result["result"]["dir"].stringValue
                    self.downloadCompleted?(name: downloadName, folderPath: path)
                case .onDownloadError:
                    self.downloadError?(name: downloadName)
                default:
                    break
                }
                
            }
            results["params"].array!.forEach() { result in
                self.request(method: .tellStatus, id: "aria2.tellStatus.downloadStatus", params: "\"\(result["gid"].stringValue)\"")
            }

            
        }
    }
}