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
    
    let aria = Aria.shared

    @IBOutlet var linksTextView: NSTextView!
    @IBOutlet weak var startButton: NSButton!
    
    
    @IBAction func start(_ sender: NSButton) {
        if let uris = linksTextView.string?.components(separatedBy: "\n") {
            aria.rpc!.add(uris: uris.filter({ return !$0.isEmpty }))
//            aria.core?.addUri(uris.filter({ return !$0.isEmpty }), withOptions: nil)
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
