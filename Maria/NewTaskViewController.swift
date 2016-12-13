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
import YouGet

class NewTaskViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        maria.rpc!.onAddUris = { flag in
            if flag {
                self.dismiss(self)
            } else {
                self.view.window?.shakeWindow()
            }
        }
        maria.rpc!.onAddTorrent = { flag in
            if flag {
                self.dismiss(self)
            } else {
                self.view.window?.shakeWindow()
            }
        }

        startButtonTitle = startButton.title
        size = progressIndicator.frame.size
        progressIndicator.frame.size = NSSize.zero
    }
    
    override func viewWillAppear() {
        if defaults[.enableYouGet] {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(youget), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear() {
        if defaults[.enableYouGet] {
            timer?.invalidate()
            timer = nil
        }
    }
    var startButtonTitle = ""
    let defaults = MariaUserDefault.auto
    let maria = Maria.shared
    
    var result: YGResult?
    var downloadUrl = ""
    var downloadOptions: [String: String] = [:]
    var size: NSSize!
    var shouldYouGet = 0
    var doYouGet = 0
    var timer: Timer?
    @IBOutlet weak var linkTextField: NSTextField!
    @IBOutlet weak var linkTextFieldCell: LoadingTextFieldCell!
    @IBOutlet weak var containerSwitchButton: NSPopUpButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var messageTextField: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    
    
    
    @IBAction func switchContainer(_ sender: NSPopUpButton) {
        if let result = result {
            downloadUrl = result.streams[sender.state].sources.first!
            downloadOptions = ["out": "\(result.title).\(result.streams[sender.state].container)"]
        }
    }
    
    @IBAction func start(_ sender: NSButton) {
        maria.rpc!.add(uris: [downloadUrl], withOptions: downloadOptions)
//        maria.core?.addUri(uris.filter({ return !$0.isEmpty }), withOptions: nil)
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
                maria.rpc!.add(torrent: data)
                self.dismiss(self)
            }
        }
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        self.startButton.title = startButtonTitle
        self.containerSwitchButton.removeAllItems()
        self.containerSwitchButton.isEnabled = false

        let url = linkTextField.stringValue
        if url.isEmpty {
            self.startButton.isEnabled = false
            shouldYouGet = 0
            doYouGet = 0
            hideProgressIndicator()
            return
        }else {
            self.startButton.isEnabled = true
        }
        let pattern = "^(https?://)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?"
        if let matcher = try? RegexHelper(pattern), matcher.match(input: url) {
            self.startButton.isEnabled = true
        } else {
            self.startButton.isEnabled = false
            shouldYouGet = 0
            doYouGet = 0
            hideProgressIndicator()
            return
        }
        
        downloadUrl = url
        shouldYouGet += 1
    }
    
    func youget() {
        if shouldYouGet != 0 && shouldYouGet == doYouGet {
            let url = linkTextField.stringValue
            downloadUrl = url
            messageTextField.stringValue = ""
            DispatchQueue.global().async {
                self.startButton.isEnabled = false
                self.showProgressIndicator()

                if let result = self.maria.youget?.fetchData(fromLink: url) {
                    self.result = result
                    self.messageTextField.stringValue = result.description
                    self.containerSwitchButton.isEnabled = true
                    self.containerSwitchButton.removeAllItems()
                    self.containerSwitchButton.addItems(withTitles: result.streams.map({ $0.name }))
                    if let stream = result.streams.first {
                        self.downloadUrl = stream.sources.first!
                        self.startButton.title = "YouGet!"
                        self.downloadOptions = ["out": "\(result.title).\(result.streams.first!.container)"]
                    }
                }
                self.hideProgressIndicator()
                self.startButton.isEnabled = true
            }
            shouldYouGet = 0
            doYouGet = 0
        } else {
            doYouGet = shouldYouGet
        }
    }
}

extension NewTaskViewController {
    //NSProgressIndicator.isHidden doesn't work.
    func showProgressIndicator() {
        self.progressIndicator.frame.size = self.size
        self.progressIndicator.needsLayout = true
        self.progressIndicator.startAnimation(self)
    }
    
    func hideProgressIndicator() {
        self.progressIndicator.stopAnimation(self)
        self.progressIndicator.frame.size = NSSize.zero
        self.progressIndicator.needsLayout = true
    }
}

extension NSWindow {
    func shakeWindow(){
        let numberOfShakes = 3
        let durationOfShake = 0.35
        let vigourOfShake: CGFloat = 0.05
        
        let frame = self.frame
        let shakeAnimation  = CAKeyframeAnimation()
        
        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))
        for _ in 0..<numberOfShakes {
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) - frame.size.width * vigourOfShake, y: NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) + frame.size.width * vigourOfShake - frame.size.width * vigourOfShake, y: NSMinY(frame)))
        }
        shakePath.closeSubpath()
        shakeAnimation.path = shakePath;
        shakeAnimation.duration = durationOfShake;
        
        self.animations = ["frameOrigin": shakeAnimation]
        self.animator().setFrameOrigin(self.frame.origin)
    }
}
