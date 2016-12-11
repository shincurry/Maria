//
//  NewTaskViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2
import SwiftyJSON

class NewTaskViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        aria.rpc!.onAddUris = { flag in
        }
        aria.rpc!.onAddTorrent = { flag in
        }
    }
    
    let youget = MariaUserDefault.auto[.yougetPath]
    // Some centain path like "/Library/Frameworks/Python.framework/Versions/3.5/bin/you-get"
    
    let aria = Aria.shared

    @IBOutlet var linksTextView: NSTextView!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var useYouget: NSButton!
    
    func runCommand(_ cmd : String, args : [String]) -> String {
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        task.environment = ["LC_CTYPE":"en_US.UTF-8"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        let outHandle = outpipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var all_output = "";
        var progressObserver : NSObjectProtocol!
        progressObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) { notification -> Void in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = String(data: data, encoding: String.Encoding.utf8) as String? {
                        all_output += str
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                } else {
                   NotificationCenter.default.removeObserver(progressObserver)
            }
        }
        
        var terminationObserver : NSObjectProtocol!
        terminationObserver = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil) { notification -> Void in
            NotificationCenter.default.removeObserver(terminationObserver)
        }
        
        task.launch()
        task.waitUntilExit()
        return all_output
    }
    
    @IBAction func start(_ sender: NSButton) {
        if let uris = linksTextView.string?.components(separatedBy: "\n") {
            if useYouget.isEnabled {
                if youget != nil {
                    uris.filter({ return !$0.isEmpty }).forEach({ (url) in
                        let jsonstring = runCommand(youget!, args: ["--json", url])
                        var json = JSON.parse(jsonstring)
                        if json["streams"].exists() {
                            let src = json["streams"]["__default__"]["src"].arrayObject
                            aria.rpc!.add(uris: src as! [String])
                        }
                    })
                }
            } else {
                aria.rpc!.add(uris: uris.filter({ return !$0.isEmpty }))
                //  aria.core?.addUri(uris.filter({ return !$0.isEmpty }), withOptions: nil)
            }
            self.dismiss(self)
        }
    }

    @IBAction func openBtFile(_ sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("openBtFile.title", comment: "")
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["torrent"]
        openPanel.runModal()
        if let url = openPanel.url {
            if let data = try? Data(contentsOf: url) {
                aria.rpc!.add(torrent: data)
                self.dismiss(self)
            }
        }
    }
}

extension NewTaskViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        if let text = linksTextView.string {
            startButton.isEnabled = !text.isEmpty
        }
    }
}
