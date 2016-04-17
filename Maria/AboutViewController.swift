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
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        
        let version = infoDictionary["CFBundleShortVersionString"] as! String
        let build = infoDictionary["CFBundleVersion"] as! String
        
        versionBuildNumber.stringValue = "v\(version) (Build \(build))"
        
    }
    @IBOutlet weak var versionBuildNumber: NSTextField!
    
    @IBAction func openAnIssuesOnGithub(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/ShinCurry/Maria/issues/new")!)
    }
    @IBAction func contactMeOnTwitter(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://twitter.com/ShinCurryy")!)
    }
}
