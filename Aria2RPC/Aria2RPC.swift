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

open class Aria2RPC {
        
    var socket: WebSocket
    
    var secret = ""
    
    public init?(url: String, secret: String?) {
        guard let path = URL(string: url) else {
            return nil
        }
        socket = WebSocket(url: path)
        if let sec = secret {
            self.secret = sec
        }
        socket.delegate = self
    }
    
    // MARK: - Public API
    // MARK: Connection
    
    /**
     connect aria2
     */
    open func connect() {
        status = .connecting
        socket.connect()
        
    }
    open var onConnect: (() -> Void)?
    
    /**
     disconnect aria2
     */
    open func disconnect() {
        socket.disconnect()
    }
    open var onDisconnect: (() -> Void)?
    
    open var status: ConnectionStatus = .disconnected {
        didSet {
            onStatusChanged?()
        }
    }
    open var onStatusChanged: ((Void) -> Void)?
    
    /**
     shutdown aria2
     */
    open func shutdown(force: Bool) {
        request(method: force ? .forceShutdown : .shutdown, params: [secret])
    }
    
    /**
     Add single uri to download task
     
     - parameter uri:	download task link
     - parameter options:   task options
     */
    
    open func add(uri: String, withOptions options: [String: String]? = nil) {
        add(uris: [uri], withOptions: options)
    }
    
    /**
     Add multiple uris to download task
     
     - parameter uris:	download task links
     - parameter options:   tasks options
     */
    open func add(uris: [String], withOptions options: [String: String]? = nil) {
        if let opts = options {
            request(method: .addUri, params: [uris, opts])
        } else {
            request(method: .addUri, params: [uris])
        }
    }
    open var onAddUris: ((_ flag: Bool) -> Void)?
    
    /**
     Get urls of task
     
     - parameter gid:	task gid
     */
    open func getUris(_ gid: String) {
        request(method: .getUris, params: [gid])
    }
    open var onGetUris: ((_ results: [String]) -> Void)?
    
    /**
     Add torrent to download task
     
     - parameter data:	torrent data
     */
    open func add(torrent: Data, withOptions options: [String: String]? = nil) {
        let base64Encoded = torrent.base64EncodedString(options: .lineLength64Characters)
        
        if let opts = options {
            request(method: .addTorrent, params: [base64Encoded, opts])
        } else {
            request(method: .addTorrent, params: [base64Encoded])
        }
    }
    open var onAddTorrent: ((_ flag: Bool) -> Void)?
    
    // MARK: Global status
    /**
     Get all of active download tasks
     */
    open func tellActive() {
        request(method: .tellActive, params: [])
    }
    open var onActives: ((_ results: [Aria2Task]?) -> Void)?
    
    /**
     Get all of waiting download tasks
     */
    open func tellWaiting() {
        request(method: .tellWaiting, params: [0, 100])
    }
//    public var onWaitings: ((results results: JSON) -> Void)?
    open var onWaitings: ((_ results: [Aria2Task]?) -> Void)?
    
    /**
     Get all of stopped download tasks
     */
    open func tellStopped() {
        request(method: .tellStopped, params: [0, 100])
    }
    open var onStoppeds: ((_ results: [Aria2Task]?) -> Void)?
    
    /**
     Get global status
     */
    open func getGlobalStatus() {
        request(method: .getGlobalStat, params: [])
    }
    open var onGlobalStatus: ((_ result: Aria2GlobalStatus) -> Void)?
    
    /**
     Change status of an active task to stoppped (Remove an active task)
     
     - parameter gid:	task id
     */
    open func removeActive(_ gid: String) {
        request(method: .remove, params: [gid])
    }
    open var onRemoveActive: ((_ flag: Bool) -> Void)?
    
    /**
     Remove an error/stopped task
     
     - parameter gid:	task gid
     */
    open func removeOther(_ gid: String) {
        request(method: .removeDownloadResult, params: [gid])
    }
    open var onRemoveOther: ((_ flag: Bool) -> Void)?
    
    /**
     Clear All error/stopped tasks
     */
    open func clearCompletedErrorRemoved() {
        request(method: .purgeDownloadResult, params: [])
    }
    open var onClearCompletedErrorRemoved: ((_ flag: Bool) -> Void)?
    
    /**
     Pause an active task
     
     - parameter gid:	task id
     */
    open func pause(_ gid: String) {
        request(method: .pause, params: [gid])
    }
    open var onPause: ((_ flag: Bool) -> Void)?
    
    /**
     Pause All of active tasks
     */
    open func pauseAll() {
        request(method: .pauseAll, params: [])
    }
    open var onPauseAll: ((_ flag: Bool) -> Void)?
    
    /**
     Unpause a paused task
     
     - parameter gid:	task id
     */
    open func unpause(_ gid: String) {
        request(method: .unpause, params: [gid])
    }
    open var onUnpause: ((_ flag: Bool) -> Void)?
    
    /**
     Unpause All of paused tasks
     */
    open func unpauseAll() {
        request(method: .unpauseAll, params: [])
    }
    open var onUnpauseAll: ((_ flag: Bool) -> Void)?
    
    open func restart(_ task: Aria2Task) {
        request(method: .removeDownloadResult, id: "aria2.remove.restart", params: [task.gid!])
        onRemoveOtherToRestart = { flag in
            if flag, let uris = task.uris {
                uris.forEach { uri in
                    if let path = task.dirPath {
                        self.request(method: .addUri, id: "aria2.restart", params: [uri, ["dir": path]])
                    } else {
                        self.request(method: .addUri, id: "aria2.restart", params: uri)
                    }
                }
            } else {
                self.onRestart?(false)
            }
        }
    }
    open var onRemoveOtherToRestart: ((_ flag: Bool) -> Void)?
    open var onRestart: ((_ flag: Bool) -> Void)?
    
    
    // MARK: Download status
    fileprivate var getDownloadStatus: ((_ results: JSON) -> Void)?
    open var downloadCompleted: ((_ name: String, _ folderPath: String) -> Void)?
    open var downloadPaused: ((_ name: String) -> Void)?
    open var downloadStarted: ((_ name: String) -> Void)?
    open var downloadStopped: ((_ name: String) -> Void)?
    open var downloadError: ((_ name: String) -> Void)?
    
    
    
    // MARK: Speed limit
    /**
     Set global speed limit
     
     - parameter download:	download speed
     - parameter upload:    upload speed
     */
    open func globalSpeedLimit(download: Int, upload: Int) {
        onChangeGlobalOption = { self.onGlobalSpeedLimitOK?($0) }
        let limit = ["max-overall-download-limit": speedToString(download),
                     "max-overall-upload-limit": speedToString(upload)]
        change(globalOption: limit)
    }
    open var onGlobalSpeedLimitOK: ((_ flag: Bool) -> Void)?
    
    /**
     Set low speed mode limit
     
     - parameter download:	download speed
     - parameter upload:    upload speed
     */
    open func lowSpeedLimit(download: Int, upload: Int) {
        onChangeGlobalOption = { self.onLowSpeedLimitOK?($0) }
        let limit = ["max-overall-download-limit": speedToString(download),
                     "max-overall-upload-limit": speedToString(upload)]
        change(globalOption: limit)
    }
    open var onLowSpeedLimitOK: ((_ flag: Bool) -> Void)?
    
    
    open func change(globalOption options: [String: String]) {
        request(method: .changeGlobalOption, params: [options])
    }
    open var onChangeGlobalOption: ((_ flag: Bool) -> Void)?
    
    fileprivate func speedToString(_ value: Int) -> String {
        var valueString = "\(value)"
        if value != 0 {
            valueString += "K"
        }
        return valueString
    }

}
    
extension Aria2RPC {

    open func request(method: Aria2Method, params: [Any]) {
        request(method: method, id: method.rawValue, params: params)
    }

    open func request(method: Aria2Method, id: String, params: [Any]) {
        let socket: [String: Any] = ["jsonrpc": "2.0",
                      "id": id,
                      "method": "aria2.\(method.rawValue)",
                      "params": ["token:\(secret)"] + params]
        guard let socketString = JSON(socket).rawString() else {
            return
        }
        let data = socketString.data(using: .utf8)!
        self.socket.write(data: data)
    }
    
}


// MARK: - Web socket delegate
extension Aria2RPC: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocket) {
        print("WebSocket connected")
        status = .connected
        onConnect?()
    }
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("WebSocket disconnected: \(error)")
        status = .disconnected
        onDisconnect?()
    }
    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print(data)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let results = JSON(data: text.data(using: .utf8)!)
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
                    onGlobalStatus?(getGlobalStatusByJSON(results))
                // --------------------
                case .tellActive:
                    onActives?(getTasksByJSON(results))
                case .tellWaiting:
                    onWaitings?(getTasksByJSON(results))
                case .tellStopped:
                    onStoppeds?(getTasksByJSON(results))
                // --------------------
                case .remove:
                    onRemoveActive?((results["error"] != JSON.null) ? false : true)
                    removeOther(results["result"].stringValue)
                case .removeDownloadResult:
                    onRemoveOther?((results["error"] != JSON.null) ? false : true)
                case .purgeDownloadResult:
                    onClearCompletedErrorRemoved?((results["error"] != JSON.null) ? false : true)
                case .pause:
                    onPause?((results["error"] != JSON.null) ? false : true)
                case .pauseAll:
                    onPauseAll?((results["error"] != JSON.null) ? false : true)
                case .unpause:
                    onUnpause?((results["error"] != JSON.null) ? false : true)
                case .unpauseAll:
                    onUnpauseAll?((results["error"] != JSON.null) ? false : true)
                // --------------------
                case .shutdown:
                    break
                case .tellStatus:
                    break
                case .addUri:
                    onAddUris?((results["error"] != JSON.null) ? false : true)
                case .addTorrent:
                    onAddTorrent?((results["error"] != JSON.null) ? false : true)
                case .getUris:
                    onGetUris?(results["result"].array!.map({ result in return result["uri"].stringValue }))
                case .changeGlobalOption:
                    onChangeGlobalOption?(results["error"] == JSON.null)
                default:
                    break
                }
            }
            
            switch idString {
            case "aria2.tellStatus.downloadStatus":
                getDownloadStatus!(results)
            case "aria2.changeGlobalOption.globalSpeedLimit":
                onGlobalSpeedLimitOK?(results["result"].stringValue == "OK")
            case "aria2.changeGlobalOption.lowSpeedLimit":
                onLowSpeedLimitOK?(results["result"].stringValue == "OK")
            case "aria2.remove.restart":
                onRemoveOtherToRestart?(results["error"] == JSON.null)
            case "aria2.restart":
                onRestart?((results["error"] != JSON.null) ? false : true)
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
                    self.downloadStarted?(downloadName)
                case .onDownloadPause:
                    self.downloadPaused?(downloadName)
                case .onDownloadStop:
                    self.downloadStopped?(downloadName)
                case .onBtDownloadComplete:
                    fallthrough
                case .onDownloadComplete:
                    let path = result["result"]["dir"].stringValue
                    self.downloadCompleted?(downloadName, path)
                case .onDownloadError:
                    self.downloadError?(downloadName)
                default:
                    break
                }
                
            }
            results["params"].array!.forEach() { result in
                self.request(method: .tellStatus, id: "aria2.tellStatus.downloadStatus", params: [result["gid"].stringValue])
            }
        }
    }
    
    // MARK: Convert JSON to Swift Struct
    
    func getTasksByJSON(_ json: JSON) -> [Aria2Task]? {
        return json["result"].array?.map() { data in
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
