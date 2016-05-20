//
//  SettingsTodayViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/5/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsTodayViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var numberOfTasksTextField: NSTextField!
    @IBOutlet weak var rangeLabel: NSTextField!
    
    @IBOutlet weak var enableTasksSortedByProgress: NSButton!
}

extension SettingsTodayViewController {
    @IBAction func didChangeStepperValue(sender: NSStepper) {
        let value = sender.integerValue
        numberOfTasksTextField.stringValue = "\(value)"
        defaults.setInteger(value, forKey: "TodayTasksNumber")
    }

    @IBAction func switchOption(sender: NSButton) {
        let boolValue = (sender.state == 1 ? true : false)
        defaults.setBool(boolValue, forKey: "TodayEnableTasksSortedByProgress")
    }
}


extension SettingsTodayViewController {
    func userDefaultsInit() {
        rangeLabel.stringValue = "(\(Int(stepper.minValue)) ~ \(Int(stepper.maxValue)))"
        stepper.integerValue = defaults.integerForKey("TodayTasksNumber")
        numberOfTasksTextField.stringValue = "\(stepper.integerValue)"
        enableTasksSortedByProgress.state = defaults.boolForKey("TodayEnableTasksSortedByProgress") ? 1 : 0
    }
}
