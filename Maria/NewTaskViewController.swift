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
        
        aria2.downloadTaskAdded = { result in
            print("downloadTaskAdded")
        }
        
        aria2.btDownloadTaskAdded = { result in
            print("btDownloadTaskAdded")
        }
    }
    
    let aria2 = Aria2.shared

    @IBOutlet var linksTextView: NSTextView!
    @IBOutlet weak var startButton: NSButton!
    
    
    @IBAction func start(sender: NSButton) {
        if let uris = linksTextView.string?.componentsSeparatedByString("\n") {
            uris.filter({ return !$0.isEmpty }).forEach() { uri in
                self.aria2.request(method: .addUri, params: "[\"\(uri)\"]")
            }
            self.dismissController(self)
        }
        
    }
    
    @IBAction func cancel(sender: NSButton) {
    }
    
    @IBAction func openBtFile(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a .torrent file"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["torrent"]
        openPanel.runModal()
        if let url = openPanel.URL {
            if let data = NSData(contentsOfURL: url) {
                let base64Encoded = data.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                aria2.request(method: .addTorrent, params: "\"\(base64Encoded)\"")
                self.dismissController(self)
            }
        }
    }
}

extension NewTaskViewController: NSTextViewDelegate {
    func textDidChange(notification: NSNotification) {
        if let text = linksTextView.string {
            startButton.enabled = !text.isEmpty
        }
    }
}
