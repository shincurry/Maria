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
        userDefaultsInit()
    }
    
    let defaults = UserDefaults(suiteName: "group.windisco.maria")!
    
    @IBOutlet weak var autoConnectAria2Enabled: NSButtonCell!
    
    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var port: NSTextField!
    
    @IBOutlet weak var basePath: NSTextField!
    @IBOutlet weak var path: NSTextField!
    
    
    @IBOutlet weak var sslEnabled: NSButton!
    
    @IBOutlet weak var secret: NSSecureTextField!
    
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    
    
    @IBAction func restartApp(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("restartApp.alert.messageText", comment: "")
        alert.informativeText = NSLocalizedString("restartApp.alert.informativeText", comment: "")
        alert.addButton(withTitle: NSLocalizedString("button.sure", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
        alert.beginSheetModal(for: self.view.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                let path = Bundle.main.executablePath!
                let id = "\(ProcessInfo.processInfo.processIdentifier)"
                Process.launchedProcess(launchPath: path, arguments: [path, id])
                NSApp.terminate(self)
            }
        })
    }
}


extension SettingsRPCServerViewController {
    
    @IBAction func finishEditing(_ sender: NSTextField) {
        var key = ""
        switch sender {
        case host:
            key = "RPCServerHost"
        case port:
            if let intValue = Int(sender.stringValue) {
                defaults.set(intValue, forKey: key)
                defaults.synchronize()
            } else {
                sender.stringValue = "\(defaults.integer(forKey: key))"
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
        defaults.set(sender.stringValue, forKey: key)
        defaults.synchronize()
    }
    
    
    
    @IBAction func enableSSL(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults.set(boolValue, forKey: "EnabledSSL")
        defaults.synchronize()
    }
    @IBAction func enableAutoConnectAria2(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults.set(boolValue, forKey: "EnableAutoConnectAria2")
        defaults.synchronize()
    }
    
    
}

extension SettingsRPCServerViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        basePath.stringValue = "http(s)://\(host.stringValue):\(port.stringValue)"
    }
}

extension SettingsRPCServerViewController {
    func userDefaultsInit() {
        if let value = defaults.object(forKey: "RPCServerHost") as? String {
            host.stringValue = value
        }
        if let value = defaults.object(forKey: "RPCServerPort") as? String {
            port.stringValue = value
        }
        if let value = defaults.object(forKey: "RPCServerPath") as? String {
            path.stringValue = value
        }
        if let value = defaults.object(forKey: "RPCServerSecret") as? String {
            secret.stringValue = value
        }
        if let value = defaults.object(forKey: "RPCServerUsername") as? String {
            username.stringValue = value
        }
        if let value = defaults.object(forKey: "RPCServerPassword") as? String {
            password.stringValue = value
        }
        sslEnabled.state = defaults.bool(forKey: "EnabledSSL") ? 1 : 0
        
        basePath.stringValue = "https://" + host.stringValue + ":" + port.stringValue
        
        autoConnectAria2Enabled.state = defaults.bool(forKey: "EnableAutoConnectAria2") ? 1 : 0
    }
}
