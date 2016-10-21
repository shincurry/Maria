//
//  TaskCellView.swift
//  Maria
//
//  Created by ShinCurry on 16/5/10.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2


class TaskCellView: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        actionButton.target = self
        
        aria.rpc!.onUnpause = { flag in
            if flag {
                self.status = "active"
            }
        }
        aria.rpc!.onPause = { flag in
            if flag {
                self.status = "paused"
            }
        }
    }
    
    var fileName: String? {
        didSet {
            if let ext = fileName!.components(separatedBy: ".").last?.lowercased() {
                let taskIconImage = NSWorkspace.shared().icon(forFileType: ext)
                taskIconImage.size = taskTypeImageView.frame.size
                taskTypeImageView.image = taskIconImage
            }
        }
    }
    let aria = Aria.shared
    
    var data: Aria2Task?
    
    var gid: String = ""
    var isBtDownload: Bool = false
    var status: String = "active" {
        didSet {
            switch status {
            case "waiting":
                fallthrough
            case "active":
                actionButton.action = #selector(actionPause)
                actionButton.image = NSImage(named: "PauseButton")
                taskStatusLabel.stringValue = "Downloading"
            case "paused":
                actionButton.action = #selector(actionUnpause)
                actionButton.image = NSImage(named: "RestartButton")
                taskStatusLabel.stringValue = "Paused"
            case "complete":
                actionButton.image = NSImage(named: "CompleteButton")
                taskStatusLabel.stringValue = "Complete"
            case "stopped":
                actionButton.action = #selector(actionRestart)
                actionButton.image = NSImage(named: "RestartButton")
                taskStatusLabel.stringValue = "Stopped"
            case "removed":
                actionButton.action = #selector(actionRestart)
                actionButton.image = NSImage(named: "RestartButton")
                taskStatusLabel.stringValue = "Removed"
            case "error":
                actionButton.action = #selector(actionRestart)
                actionButton.image = NSImage(named: "RestartButton")
                taskStatusLabel.stringValue = "Error"
            default:
                break
            }
            
        }
    }
    
    @IBOutlet weak var taskTypeImageView: NSImageView!
    @IBOutlet weak var taskTitleLabel: NSTextField!
    @IBOutlet weak var taskProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var taskFileSizeLabel: NSTextField!
    @IBOutlet weak var taskSpeedLabel: NSTextField!
    @IBOutlet weak var taskRemainingTimeLabel: NSTextField!
    @IBOutlet weak var taskProgressLabel: NSTextField!
    
    @IBOutlet weak var taskStatusLabel: NSTextField!
    
    @IBOutlet weak var findPathButton: NSLayoutConstraint!
    @IBOutlet weak var actionButton: NSButton!
    
    func actionUnpause() {
        aria.rpc!.unpause(gid)
    }
    func actionPause() {
        aria.rpc!.pause(gid)
    }
    func actionStop() {
        
    }
    func actionRestart() {
        if !isBtDownload {
            aria.rpc!.restart(data!)
        }
    }
    
    func update(_ task: Aria2Task) {
        data = task
        gid = task.gid!
        status = task.status!
        isBtDownload = task.isBtTask!
        if isBtDownload {
            taskTypeImageView.image = NSImage(named: "TorrentIcon")
        } else {
            fileName = task.fileName!
        }
        taskTitleLabel.stringValue = task.title!
        taskSpeedLabel.stringValue = "⬇︎ " + task.speed!.downloadString + " ⬆︎ " + task.speed!.uploadString
        taskProgressIndicator.doubleValue = task.progress
        taskProgressLabel.stringValue = task.progressString
        taskFileSizeLabel.stringValue = task.fileSizeString
        taskRemainingTimeLabel.stringValue = task.remainingString
    }
    
    @IBAction func findPath(_ sender: NSButton) {
        let path = isBtDownload ? data!.torrentDirectoryPath! : data!.filePath!
        NSWorkspace.shared().selectFile(path, inFileViewerRootedAtPath: "")
    }
}

