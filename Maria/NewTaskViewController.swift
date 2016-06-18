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
    
    
    @IBAction func start(_ sender: NSButton) {
        if let uris = linksTextView.string?.components(separatedBy: "\n") {
            aria2.add(uris: uris.filter({ return !$0.isEmpty }))
            self.dismiss(self)
        }
    }

    @IBAction func openBtFile(_ sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a .torrent file"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["torrent"]
        openPanel.runModal()
        if let url = openPanel.url {
            if let data = try? Data(contentsOf: url) {
                aria2.add(torrent: data)
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
