//
//  SettingsRPCServerViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2Core
import SwiftyUserDefaults

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
        var key = DefaultsKeys.rpcServerHost
        switch sender {
        case host:
            key = .rpcServerHost
        case port:
            key = .rpcServerPort
            if Int(sender.stringValue) != nil {
                defaults[key] = sender.stringValue
                defaults.synchronize()
            } else {
                sender.stringValue = "\(defaults[key])"
            }
            
            return
        case path:
            key = .rpcServerPath
        case secret:
            key = .rpcServerSecret
        case username:
            key = .rpcServerUsername
        case password:
            key = .rpcServerPassword
        default:
            break
        }
        defaults[key] = sender.stringValue
        defaults.synchronize()
    }
    
    
    
    @IBAction func enableSSL(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults[.rpcServerEnabledSSL] = boolValue
        defaults.synchronize()
    }
    @IBAction func enableAutoConnectAria2(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        defaults[.enableAutoConnectAria2] = boolValue
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
                MariaUserDefault.main[.useEmbeddedAria2] = boolValue
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
        if let value = defaults[.rpcServerHost] {
            host.stringValue = value
        }
        if let value = defaults[.rpcServerPort] {
            port.stringValue = value
        }
        if let value = defaults[.rpcServerPath] {
            path.stringValue = value
        }
        if let value = defaults[.rpcServerSecret] {
            secret.stringValue = value
        }
        if let value = defaults[.rpcServerUsername] {
            username.stringValue = value
        }
        if let value = defaults[.rpcServerPassword] {
            password.stringValue = value
        }
        sslEnabled.state = defaults[.rpcServerEnabledSSL] ? 1 : 0
        
        basePath.stringValue = "https://" + host.stringValue + ":" + port.stringValue
        
        autoConnectAria2Enabled.state = defaults[.enableAutoConnectAria2] ? 1 : 0
        useEmbeddedAria2Enabled.state = MariaUserDefault.main[.useEmbeddedAria2] ? 1 : 0
        
        useEmbeddedAria2Enabled.title = useEmbeddedAria2Enabled.title + "(version \(EmbeddedAria2Version))"
    }
}
