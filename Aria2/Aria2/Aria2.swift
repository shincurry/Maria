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

public enum ConnectionStatus {
    case connecting
    case connected
    case unauthorized
    case disconnected
}

public class Aria2 {
    
    public static let shared: Aria2 = {
        let defaults = UserDefaults(suiteName: "group.windisco.maria")!
        let baseHost = "http" + (defaults.bool(forKey: "SSLEnabled") ? "s" : "") + "://"
        let host = defaults.object(forKey: "RPCServerHost") as! String
        let port = defaults.object(forKey: "RPCServerPort") as! String
        let path = defaults.object(forKey: "RPCServerPath") as! String
        return Aria2(url: baseHost + host + ":" + port + path)
    }()
    
    var secret = ""
    let defaults = UserDefaults(suiteName: "group.windisco.maria")!
    
    var socket: WebSocket!
    
    public init(url: String) {
        socket = WebSocket(url: URL(string: url)!)
        socket.delegate = self
        secret = defaults.object(forKey: "RPCServerSecret") as! String
    }
    
    // MARK: - Public API
    // MARK: Connection
    
    /**
     connect aria2
     */
    public func connect() {
        status = .connecting
        socket.connect()
        
    }
    public var onConnect: (() -> Void)?
    
    /**
     disconnect aria2
     */
    public func disconnect() {
        socket.disconnect()
    }
    public var onDisconnect: (() -> Void)?
    
    public var status: ConnectionStatus = .disconnected {
        didSet {
            onStatusChanged?()
        }
    }
    public var onStatusChanged: ((Void) -> Void)?
    
    /**
     shutdown aria2
     */
    public func shutdown() {
        request(method: .shutdown, params: "")
    }
    
    /**
     Add uris to download task
     
     - parameter uris:	download task links
     */
    public func add(uris: [String]) {
        uris.forEach() { uri in
            request(method: .addUri, params: "[\"\(uri)\"]")
        }
    }
    public var onAddUris: ((flag: Bool) -> Void)?
    
    public func getUris(_ gid: String) {
        request(method: .getUris, params: "\"\(gid)\"")
    }
    public var onGetUris: ((results: [String]) -> Void)?
    /**
     Add torrent to download task
     
     - parameter data:	torrent data
     */
    public func add(torrent: Data) {
        let base64Encoded = torrent.base64EncodedString(.encoding64CharacterLineLength)
        request(method: .addTorrent, params: "\"\(base64Encoded)\"")
    }
    public var onAddTorrent: ((flag: Bool) -> Void)?
    
    // MARK: Global status
    /**
     Get all of active download tasks
     */
    public func tellActive() {
        request(method: .tellActive, params: "[]")
    }
//    public var onActives: ((results: JSON) -> Void)?
    public var onActives: ((results: [Aria2Task]) -> Void)?
    
    /**
     Get all of waiting download tasks
     */
    public func tellWaiting() {
        request(method: .tellWaiting, params: "0, 100")
    }
//    public var onWaitings: ((results: JSON) -> Void)?
    public var onWaitings: ((results: [Aria2Task]) -> Void)?
    
    /**
     Get all of stopped download tasks
     */
    public func tellStopped() {
        request(method: .tellStopped, params: "0, 100")
    }
//    public var onStoppeds: ((results: JSON) -> Void)?
    public var onStoppeds: ((results: [Aria2Task]) -> Void)?
    
    /**
     Get global status
     */
    public func getGlobalStatus() {
        request(method: .getGlobalStat, params: "[]")
    }
    public var onGlobalStatus: ((result: Aria2GlobalStatus) -> Void)?
    

    /**
     Change status of an active task to stoppped (Remove an active task)
     
     - parameter gid:	task id
     */
    public func removeActive(_ gid: String) {
        request(method: .remove, params: "\"\(gid)\"")
    }
    public var onRemoveActive: ((flag: Bool) -> Void)?
    /**
     Remove an error/stopped task
     
     - parameter gid:	task id
     */
    public func removeOther(_ gid: String) {
        request(method: .removeDownloadResult, params: "\"\(gid)\"")
    }
    public var onRemoveOther: ((flag: Bool) -> Void)?
    
    /**
     Clear All error/stopped tasks
     */
    public func clearCompletedErrorRemoved() {
        request(method: .purgeDownloadResult, params: "[]")
    }
    public var onClearCompletedErrorRemoved: ((flag: Bool) -> Void)?
    
    /**
     Pause an active task
     
     - parameter gid:	task id
     */
    public func pause(_ gid: String) {
        request(method: .pause, params: "\"\(gid)\"")
    }
    public var onPause: ((flag: Bool) -> Void)?
    /**
     Pause All of active tasks
     */
    public func pauseAll() {
        request(method: .pauseAll, params: "[]")
    }
    public var onPauseAll: ((flag: Bool) -> Void)?
    
    /**
     Unpause a paused task
     
     - parameter gid:	task id
     */
    public func unpause(_ gid: String) {
        request(method: .unpause, params: "\"\(gid)\"")
    }
    public var onUnpause: ((flag: Bool) -> Void)?
    
    /**
     Unpause All of paused tasks
     */
    public func unpauseAll() {
        request(method: .unpauseAll, params: "[]")
    }
    public var onUnpauseAll: ((flag: Bool) -> Void)?
    
    public func restart(_ task: Aria2Task) {
        request(method: .removeDownloadResult, id: "aria2.remove.restart", params: "\"\(task.gid!)\"")
        onRemoveOtherToRestart = { flag in
            if flag {
                for uri in task.uris! {
                    var uriString = ""
                    for (index, uri) in Array(Set(uri)).enumerated() {
                        uriString += (index != 0 ? ",\"" : "\"") + uri + "\""
                    }
                    if let path = task.dirPath {
                        self.request(method: .addUri, id: "aria2.restart", params: "[\(uriString)], {\"dir\": \"\(path)\"}")
                    } else {
                        self.request(method: .addUri, id: "aria2.restart", params: "[\(uriString)]")
                    }
                }
            }
        }
    }
    public var onRemoveOtherToRestart: ((flag: Bool) -> Void)?
    public var onRestart: ((flag: Bool) -> Void)?
    
    
    // MARK: Download status
    private var getDownloadStatus: ((results: JSON) -> Void)?
    public var downloadCompleted: ((name: String, folderPath: String) -> Void)?
    public var downloadPaused: ((name: String) -> Void)?
    public var downloadStarted: ((name: String) -> Void)?
    public var downloadStopped: ((name: String) -> Void)?
    public var downloadError: ((name: String) -> Void)?
    
    
    
    // MARK: Speed limit
    public func globalSpeedLimit(download: Int, upload: Int) {
        request(method: .changeGlobalOption, id: "aria2.changeGlobalOption.globalSpeedLimit", params: "{\"max-overall-download-limit\": \"\(speedToString(download))\", \"max-overall-upload-limit\": \"\(speedToString(upload))\"}")
        
    }
    public func lowSpeedLimit(download: Int, upload: Int) {
        func speedToString(_ value: Int) -> String {
            var valueString = "\(value)"
            if value != 0 {
                valueString += "K"
            }
            return valueString
        }
        
        request(method: .changeGlobalOption, id: "aria2.changeGlobalOption.lowSpeedLimit", params: "{\"max-overall-download-limit\": \"\(speedToString(download))\", \"max-overall-upload-limit\": \"\(speedToString(upload))\"}")
    }
    private func speedToString(_ value: Int) -> String {
        var valueString = "\(value)"
        if value != 0 {
            valueString += "K"
        }
        return valueString
    }
    
    public var globalSpeedLimitOK: ((result: JSON) -> Void)?
    public var lowSpeedLimitOK: ((result: JSON) -> Void)?
    
}
    
extension Aria2 {
    private func request(method: Aria2Method, params: String) {
        
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"\(method.rawValue)\", \"method\":\"aria2.\(method.rawValue)\",\"params\":[\"token:\(secret)\", \(params)]}"
        let data = socketString.data(using: String.Encoding.utf8)!
        self.socket.writeData(data)
    }
    private func request(method: Aria2Method, id: String, params: String) {
        let socketString = "{\"jsonrpc\": \"2.0\", \"id\": \"\(id)\", \"method\":\"aria2.\(method.rawValue)\",\"params\":[\"token:\(secret)\", \(params)]}"
        let data = socketString.data(using: String.Encoding.utf8)!
        self.socket.writeData(data)
    }
}


// MARK: - Web socket delegate
extension Aria2: WebSocketDelegate {
    public func websocketDidConnect(_ socket: WebSocket) {
        print("WebSocket connected")
        status = .connected
        onConnect?()
        self.socket.writeData("{ \"jsonrpc\": \"2.0\", \"id\": \"123\"}".data(using: String.Encoding.utf8)!)
    }
    public func websocketDidDisconnect(_ socket: WebSocket, error: NSError?) {
        print("WebSocket disconnected: \(error)")
        status = .disconnected
        onDisconnect?()
    }
    public func websocketDidReceiveData(_ socket: WebSocket, data: Data) {
        print(data)
    }
    
    public func websocketDidReceiveMessage(_ socket: WebSocket, text: String) {
        let results = JSON(data: text.data(using: String.Encoding.utf8)!)
        if results["error"]["message"] == "Unauthorized" {
            self.status = .unauthorized
            return
        } else {
            self.status = .connected
        }

        if let idString = results["id"].string {
            if let method = Aria2Method(rawValue: idString) {
                switch method {
                case .getGlobalStat:
                    onGlobalStatus?(result: getGlobalStatusByJSON(results))
                // --------------------
                case .tellActive:
                    onActives?(results: getTasksByJSON(results))
                case .tellWaiting:
                    onWaitings?(results: getTasksByJSON(results))
                case .tellStopped:
                    onStoppeds?(results: getTasksByJSON(results))
                // --------------------
                case .remove:
                    onRemoveActive?(flag: (results["error"] != nil) ? false : true)
                    removeOther(results["result"].stringValue)
                case .removeDownloadResult:
                    onRemoveOther?(flag: (results["error"] != nil) ? false : true)
                case .purgeDownloadResult:
                    onClearCompletedErrorRemoved?(flag: (results["error"] != nil) ? false : true)
                case .pause:
                    onPause?(flag: (results["error"] != nil) ? false : true)
                case .pauseAll:
                    onPauseAll?(flag: (results["error"] != nil) ? false : true)
                case .unpause:
                    onUnpause?(flag: (results["error"] != nil) ? false : true)
                case .unpauseAll:
                    onUnpauseAll?(flag: (results["error"] != nil) ? false : true)
                // --------------------
                case .shutdown:
                    break
                case .tellStatus:
                    break
                case .addUri:
                    onAddUris?(flag: (results["error"] != nil) ? false : true)
                case .addTorrent:
                    onAddTorrent?(flag: (results["error"] != nil) ? false : true)
                case .getUris:
                    onGetUris?(results: results["result"].array!.map({ result in return result["uri"].stringValue }))
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
            case "aria2.remove.restart":
                onRemoveOtherToRestart?(flag: (results["error"] != nil) ? false : true)
            case "aria2.restart":
                onRestart?(flag: (results["error"] != nil) ? false : true)
            default:
                break
            }

        }
        
        if let methodString = results["method"].string {
            let rawValue = methodString.components(separatedBy: ".")[1]
            let method = Aria2Method(rawValue: rawValue)!

            getDownloadStatus = { result in
                var downloadName = ""
                if let btName = result["result"]["bittorrent"]["info"]["name"].string {
                    downloadName = btName
                } else {
                    downloadName = result["result"]["files"][0]["path"].stringValue.components(separatedBy: "/").last!
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
    
    // MARK: Convert JSON to Swift Struct
    
    func getTasksByJSON(_ json: JSON) -> [Aria2Task] {
        return json["result"].array!.map() { data in
            var task = Aria2Task()
            task.gid = data["gid"].stringValue
            task.status = data["status"].stringValue
                        
            var downloadName = ""
            if let btName = data["bittorrent"]["info"]["name"].string {
                downloadName = btName
                task.isBtTask = true
            } else {
                downloadName = data["files"][0]["path"].stringValue.components(separatedBy: "/").last!
                task.isBtTask = false
                task.fileName = downloadName
            }
            task.title = downloadName
            
            task.completedLength = data["completedLength"].intValue
            task.totalLength = data["totalLength"].intValue
            
            task.speed = Aria2Speed(download: Int(data["downloadSpeed"].stringValue)!, upload: Int(data["uploadSpeed"].stringValue)!)
            task.fileSize = data["totalLength"].intValue
            
            task.uris = data["files"].array!.map({ file in
                return file["uris"].array!.map({ uri in
                    return uri["uri"].stringValue
                })
            })
            
            if task.isBtTask! {
                let pathArray = data["files"][0]["path"].stringValue.components(separatedBy: "/")
                task.torrentDirectoryPath = data["dir"].stringValue + "/" + pathArray[pathArray.count-2]
            } else {
                task.filePath = data["files"][0]["path"].stringValue
            }
            return task
        }
    }
    func getGlobalStatusByJSON(_ json: JSON) -> Aria2GlobalStatus {
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
