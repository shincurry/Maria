//
//  SettingsAria2ViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/23.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsAria2ConfigViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = MariaUserDefault.auto
    var config: AriaConfig!
    
    @IBOutlet weak var enableAria2AutoLaunch: NSButton!
    @IBOutlet weak var aria2ConfPath: NSTextField!
    
    @IBOutlet weak var aria2ConfPathButton: NSPopUpButton!
    @IBOutlet weak var aria2ConfTableView: NSTableView!
    @IBOutlet var confArrayController: NSArrayController!
    
    
    @IBAction func selectFilePath(_ sender: NSMenuItem) {
        aria2ConfPathButton.selectItem(at: 0)
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("selectConfPath.title", comment: "")
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.showsHiddenFiles = true
        openPanel.beginSheetModal(for: self.view.window!, completionHandler: { key in
            if key == 1, let url = openPanel.url?.relativePath {
                self.defaults[.aria2ConfPath] = url
                self.aria2ConfPathButton.item(at: 0)!.title = url
                self.config.reload()
                self.aria2ConfTableView.reloadData()
            }
        })
    }
    
    @IBAction func switchOptions(_ sender: NSButton) {
        let boolValue = sender.state == 1 ? true : false
        switch sender {
        case enableAria2AutoLaunch:
            defaults[.enableAria2AutoLaunch] = boolValue
        default:
            break
        }
    }
    @IBAction func confControl(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            addConf()
        case 1:
            removeConf()
        default:
            break
        }
    }
    func addConf() {
        aria2ConfTableView.deselectAll(nil)
        aria2ConfTableView.becomeFirstResponder()
        config.data.append(("newKey", ""))
        aria2ConfTableView.reloadData()
        aria2ConfTableView.scrollRowToVisible(config.data.count-1)
        aria2ConfTableView.selectRowIndexes(IndexSet(integer: config.data.count-1), byExtendingSelection: false)
    }
    func removeConf() {
        aria2ConfTableView.selectedRowIndexes.reversed().forEach { index in
            config.data.remove(at: index)
        }
        aria2ConfTableView.reloadData()
        config.save()
    }
    
    @IBAction func resetConfig(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("resetConfig.alert.messageText", comment: "")
        alert.informativeText = NSLocalizedString("resetConfig.alert.informativeText", comment: "")
        alert.addButton(withTitle: NSLocalizedString("button.sure", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
        alert.beginSheetModal(for: self.view.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                self.config.reset()
                self.aria2ConfTableView.reloadData()
            }
        })
    
    }
    @IBAction func restartAria2(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("restartAria2.alert.messageText", comment: "")
        alert.informativeText = NSLocalizedString("restartAria2.alert.informativeText", comment: "")
        alert.addButton(withTitle: NSLocalizedString("button.sure", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
        alert.beginSheetModal(for: self.view.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                let shutdown = Process()
                let shutdownSH = Bundle.main.path(forResource: "shutdownAria2c", ofType: "sh")
                shutdown.launchPath = shutdownSH
                shutdown.launch()
                shutdown.waitUntilExit()
                
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let run = Process()
                    let confPath = self.defaults[.aria2ConfPath]!
                    let runSH = Bundle.main
                        .path(forResource: "runAria2c", ofType: "sh")
                    run.launchPath = runSH
                    run.arguments = [confPath]
                    run.launch()
                    run.waitUntilExit()
                    
                    let appDelegate = NSApplication.shared().delegate as! AppDelegate
                    appDelegate.aria2open()
                }
            }
        })
    }
}


extension SettingsAria2ConfigViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return config.data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let item = config.data[row]
        switch tableColumn!.title {
        case "Key":
            return item.key
        case "Value":
            return item.value
        default:
            return ""
        }
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        switch tableColumn!.title {
        case "Key":
            config.data[row].key = object as! String
        case "Value":
            config.data[row].value = object as! String
        default:
            break
        }
        config.save()
    }
}


extension SettingsAria2ConfigViewController {
    func userDefaultsInit() {
        enableAria2AutoLaunch.state = defaults[.enableAria2AutoLaunch] ? 1 : 0
        if let value = defaults[.aria2ConfPath] {
            aria2ConfPathButton.item(at: 0)!.title = value

            if MariaUserDefault.main[.useEmbeddedAria2] {
                config = AriaConfig.builtIn
            } else {
                config = AriaConfig(filePath: value)
                config.load()
            }
        } else {
            config = AriaConfig(filePath: "")
        }
    }
}
