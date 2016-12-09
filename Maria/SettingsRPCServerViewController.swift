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
    
    let defaults = MariaUserDefault.auto
    
    @IBOutlet weak var useEmbeddedAria2Enabled: NSButton!
    @IBOutlet weak var autoConnectAria2Enabled: NSButton!
    
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
            key = "RPCServerPort"
            if Int(sender.stringValue) != nil {
                defaults.set(sender.stringValue, forKey: key)
                defaults.synchronize()
            } else {
                sender.stringValue = "\(defaults.integer(forKey: key))"
            }
            
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
        defaults.set(boolValue, forKey: "RPCServerEnabledSSL")
        defaults.synchronize()
    }
    @IBAction func enableAutoConnectAria2(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults.set(boolValue, forKey: "EnableAutoConnectAria2")
        defaults.synchronize()
    }
    @IBAction func useEmbeddedAria2(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("restartApp.alert.messageText", comment: "")
        alert.informativeText = NSLocalizedString("restartApp.alert.informativeText", comment: "")
        alert.addButton(withTitle: NSLocalizedString("button.sure", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
        alert.beginSheetModal(for: self.view.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                let boolValue = sender.state == 0 ? false : true
                MariaUserDefault.main.set(boolValue, forKey: "UseEmbeddedAria2")
                MariaUserDefault.main.synchronize()
                let path = Bundle.main.executablePath!
                let id = "\(ProcessInfo.processInfo.processIdentifier)"
                Process.launchedProcess(launchPath: path, arguments: [path, id])
                NSApp.terminate(self)
            } else if response == NSAlertSecondButtonReturn {
                sender.state = (sender.state + 1) & 1
            }
        })
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
        sslEnabled.state = defaults.bool(forKey: "RPCServerEnabledSSL") ? 1 : 0
        
        basePath.stringValue = "https://" + host.stringValue + ":" + port.stringValue
        
        autoConnectAria2Enabled.state = defaults.bool(forKey: "EnableAutoConnectAria2") ? 1 : 0
        useEmbeddedAria2Enabled.state = MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") ? 1 : 0
        
        useEmbeddedAria2Enabled.title = useEmbeddedAria2Enabled.title + "(version \(EmbeddedAria2Version))"
    }
}
