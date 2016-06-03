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
        
        aria2.onAddUris = { flag in
        }
        aria2.onAddTorrent = { flag in
        }
    }
    
    let aria2 = Aria2.shared

    @IBOutlet var linksTextView: NSTextView!
    @IBOutlet weak var startButton: NSButton!
    
    
    @IBAction func start(sender: NSButton) {
        if let uris = linksTextView.string?.componentsSeparatedByString("\n") {
            aria2.addUri(uris.filter({ return !$0.isEmpty }))
            self.dismissController(self)
        }
        
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
                aria2.addTorrent(data)
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
