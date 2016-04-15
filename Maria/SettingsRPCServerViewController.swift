//
//  SettingsRPCServerViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsRPCServerViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        host.stringValue = defaults.objectForKey("RPCServerHost") as! String
        port.stringValue = defaults.objectForKey("RPCServerPort") as! String
        path.stringValue = defaults.objectForKey("RPCServerPath") as! String
        secret.stringValue = defaults.objectForKey("RPCServerSecret") as! String
        username.stringValue = defaults.objectForKey("RPCServerUsername") as! String
        password.stringValue = defaults.objectForKey("RPCServerPassword") as! String
        isSSLEnabled.state = defaults.boolForKey("EnabledSSL") ? 1 : 0
        
        basePath.stringValue = "https://" + host.stringValue + ":" + port.stringValue
        
        isAutoConnectAria2Enabled.state = defaults.boolForKey("EnableAutoConnectAria2") ? 1 : 0
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    @IBOutlet weak var isAutoConnectAria2Enabled: NSButton!
    
    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var port: NSTextField!
    
    @IBOutlet weak var basePath: NSTextField!
    @IBOutlet weak var path: NSTextField!
    
    @IBOutlet weak var isSSLEnabled: NSButton!
    
    @IBOutlet weak var secret: NSSecureTextField!
    
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
}



extension SettingsRPCServerViewController {
    
    @IBAction func finishEditing(sender: NSTextField) {
        var key = ""
        switch sender {
        case host:
            key = "RPCServerHost"
        case port:
            if let intValue = Int(sender.stringValue) {
                defaults.setInteger(intValue, forKey: key)
                defaults.synchronize()
            } else {
                sender.stringValue = "\(defaults.integerForKey(key))"
            }
            key = "RPCServerPort"
            return
        case path:
            key = "RPCServerPath"
        case secret:
            key = "RPCServerSecret"
        case username:
            key = "RPCServerUsername"
        case password:
            key = "RPCServerPassword"
        default:
            break
        }
        defaults.setObject(sender.stringValue, forKey: key)
        defaults.synchronize()
    }
    
    @IBAction func enableSSL(sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults.setBool(boolValue, forKey: "EnabledSSL")
        defaults.synchronize()
    }
    @IBAction func enableAutoConnectArai2(sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults.setBool(boolValue, forKey: "EnableAutoConnectAria2")
        defaults.synchronize()
    }
    
    
}

extension SettingsRPCServerViewController: NSTextFieldDelegate {
    override func controlTextDidChange(obj: NSNotification) {
        basePath.stringValue = "http(s)://\(host.stringValue):\(port.stringValue)"
    }
}
