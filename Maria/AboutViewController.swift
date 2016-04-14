//
//  AboutViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func openAnIssuesOnGithub(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/ShinCurry/Maria/issues/new")!)
    }
    @IBAction func contactMeOnTwitter(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://twitter.com/ShinCurryy")!)
    }
}
