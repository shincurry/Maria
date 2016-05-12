//
//  Aria2.swift
//  Aria2
//
//  Created by ShinCurry on 16/4/9.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation
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
    
    // MARK: - Public API
    // MARK: Connection
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
    
    public func shutdown() {
        request(method: .shutdown, params: "")
    }
    
    public func addTorrent(data: NSData) {
        let base64Encoded = data.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        request(method: .addTorrent, params: "\"\(base64Encoded)\"")
    }
    
    
    // MARK: Global status
    public func tellActive() {
        request(method: .tellActive, params: "[]")
    }
    public func tellWaiting() {
        request(method: .tellWaiting, params: "0, 100")
    }
    public func tellStopped() {
        request(method: .tellStopped, params: "0, 100")
    }
    
    public func getGlobalStatus() {
        request(method: .getGlobalStat, params: "[]")
    }
    public var onActives: ((results: JSON) -> Void)?
    public var onActivesTask: ((results: [Aria2Task]) -> Void)?
    
    public var onWaitings: ((results: JSON) -> Void)?
    public var onWaitingsTask: ((results: [Aria2Task]) -> Void)?
    
    public var onStoppeds: ((results: JSON) -> Void)?
    public var onStoppedsTask: ((results: [Aria2Task]) -> Void)?
    
    public var onGlobalStatus: ((result: Aria2GlobalStatus) -> Void)?

    public func pause(gid: String) {
        request(method: .pause, params: "\"\(gid)\"")
    }
    public var onPause: ((flag: Bool) -> Void)?
    
    public func pauseAll() {
        request(method: .pauseAll, params: "[]")
    }
    public var onPauseAll: ((flag: Bool) -> Void)?
    
    public func start(gid: String) {
        request(method: .unpause, params: "\"\(gid)\"")
    }
    public var onStart: ((flag: Bool) -> Void)?
    
    public func startAll() {
        request(method: .unpauseAll, params: "[]")
    }
    public var onStartAll: ((flag: Bool) -> Void)?
    
    
    // MARK: Download status
    private var getDownloadStatus: ((results: JSON) -> Void)?
    public var downloadCompleted: ((name: String, folderPath: String) -> Void)?
    public var downloadPaused: ((name: String) -> Void)?
    public var downloadStarted: ((name: String) -> Void)?
    public var downloadStopped: ((name: String) -> Void)?
    public var downloadError: ((name: String) -> Void)?
    
    
    
    // MARK: Speed limit
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
    
    
    // MARK: Add download task
    public var downloadTaskAdded: ((result: JSON) -> Void)?
    public var btDownloadTaskAdded: ((result: JSON) -> Void)?
}
    
extension Aria2 {
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


// MARK: - Web socket delegate
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
                    onGlobalStatus?(result: getGlobalStatusByJSON(results))
                // --------------------
                case .tellActive:
                    onActives?(results: results["result"])
                    onActivesTask?(results: getTasksByJSON(results))
                case .tellWaiting:
                    onWaitings?(results: results["result"])
                    onWaitingsTask?(results: getTasksByJSON(results))
                case .tellStopped:
                    onStoppeds?(results: results["result"])
                    onStoppedsTask?(results: getTasksByJSON(results))
                // --------------------
                case .pause:
                    onPause?(flag: true)
                    print(results)
                case .pauseAll:
                    onPauseAll?(flag: true)
                case .unpause:
                    onStart?(flag: true)
                case .unpauseAll:
                    onStartAll?(flag: true)
                // --------------------
                case .shutdown:
                    break
                case .tellStatus:
                    break
                case .addUri:
                    downloadTaskAdded?(result: results["result"])
                case .addTorrent:
                    btDownloadTaskAdded?(result: results["result"])
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
    
    func getTasksByJSON(json: JSON) -> [Aria2Task] {
        return json["result"].array!.map() { data in
            var task = Aria2Task()
            task.gid = data["gid"].stringValue
            task.status = data["status"].stringValue
                        
            var downloadName = ""
            if let btName = data["bittorrent"]["info"]["name"].string {
                downloadName = btName
                task.isBtTask = true
            } else {
                downloadName = data["files"][0]["path"].stringValue.componentsSeparatedByString("/").last!
                task.isBtTask = false
                task.fileName = downloadName
            }
            task.title = downloadName
            
            task.completedLength = data["completedLength"].intValue
            task.totalLength = data["totalLength"].intValue
            
            task.speed = Aria2Speed(download: Int(data["downloadSpeed"].stringValue)!, upload: Int(data["uploadSpeed"].stringValue)!)
            task.fileSize = data["totalLength"].intValue
            return task
        }
    }
    func getGlobalStatusByJSON(json: JSON) -> Aria2GlobalStatus {
        let data = json["result"]
        var status = Aria2GlobalStatus()
        status.speed = Aria2Speed(download: Int(data["downloadSpeed"].stringValue)!, upload: Int(data["uploadSpeed"].stringValue)!)
        status.numberOfActiveTask = data["numActive"].intValue
        status.numberOfWaitingTask = data["numWaiting"].intValue
        status.numberOfStoppedTask = data["numStopped"].intValue
        status.numberOfTotalStoppedTask = data["numStoppedTotal"].intValue
        
        return status
    }
}