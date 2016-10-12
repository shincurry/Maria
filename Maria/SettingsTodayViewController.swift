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
    
    let defaults = UserDefaults(suiteName: "group.windisco.maria")!
    
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var numberOfTasksTextField: NSTextField!
    @IBOutlet weak var rangeLabel: NSTextField!
    
    @IBOutlet weak var enableTasksSortedByProgress: NSButton!
}

extension SettingsTodayViewController {
    @IBAction func didChangeStepperValue(_ sender: NSStepper) {
        let value = sender.integerValue
        numberOfTasksTextField.stringValue = "\(value)"
        defaults.set(value, forKey: "TodayTasksNumber")
    }

    @IBAction func switchOption(_ sender: NSButton) {
        let boolValue = (sender.state == 1 ? true : false)
        defaults.set(boolValue, forKey: "TodayEnableTasksSortedByProgress")
    }
}


extension SettingsTodayViewController {
    func userDefaultsInit() {
        rangeLabel.stringValue = "(\(Int(stepper.minValue)) ~ \(Int(stepper.maxValue)))"
        stepper.integerValue = defaults.integer(forKey: "TodayTasksNumber")
        numberOfTasksTextField.stringValue = "\(stepper.integerValue)"
        enableTasksSortedByProgress.state = defaults.bool(forKey: "TodayEnableTasksSortedByProgress") ? 1 : 0
    }
}
