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
    
    let defaults = MariaUserDefault.auto
    
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var numberOfTasksTextField: NSTextField!
    @IBOutlet weak var rangeLabel: NSTextField!
    
    @IBOutlet weak var enableTasksSortedByProgress: NSButton!
}

extension SettingsTodayViewController {
    @IBAction func didChangeStepperValue(_ sender: NSStepper) {
        let value = sender.integerValue
        numberOfTasksTextField.stringValue = "\(value)"
        defaults[.todayTasksNumber] = value
    }

    @IBAction func switchOption(_ sender: NSButton) {
        let boolValue = (sender.state == .on ? true : false)
        defaults[.todayEnableTasksSortedByProgress] = boolValue
    }
}


extension SettingsTodayViewController {
    func userDefaultsInit() {
        rangeLabel.stringValue = "(\(Int(stepper.minValue)) ~ \(Int(stepper.maxValue)))"
        stepper.integerValue = defaults[.todayTasksNumber]
        numberOfTasksTextField.stringValue = "\(stepper.integerValue)"
        enableTasksSortedByProgress.state = defaults[.todayEnableTasksSortedByProgress] ? .on : .off
    }
}
