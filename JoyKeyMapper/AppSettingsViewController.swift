//
//  AppSettingsViewController.swift
//  JoyKeyMapper
//
//  Created by magicien on 2020/03/11.
//  Copyright © 2020 DarkHorse. All rights reserved.
//

import AppKit

class AppSettingsViewController: NSViewController {
    @IBOutlet weak var disconnectTime: NSPopUpButton!
    @IBOutlet weak var notifyConnection: NSButton!
    @IBOutlet weak var notifyBatteryLevel: NSButton!
    @IBOutlet weak var notifyBatteryCharge: NSButton!
    @IBOutlet weak var notifyBatteryFull: NSButton!
    @IBOutlet weak var launchOnLogin: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disconnectTime.selectItem(withTag: AppSettings.disconnectTime)
        self.notifyConnection.state = AppSettings.notifyConnection ? .on : .off
        self.notifyBatteryLevel.state = AppSettings.notifyBatteryLevel ? .on : .off
        self.notifyBatteryCharge.state = AppSettings.notifyBatteryCharge ? .on : .off
        self.notifyBatteryFull.state = AppSettings.notifyBatteryFull ? .on : .off
        self.launchOnLogin.state = AppSettings.launchOnLogin ? .on : .off
    }
    
    @IBAction func didChangeDisconnectTime(_ sender: NSPopUpButton) {
        AppSettings.disconnectTime = self.disconnectTime.selectedTag()
    }
    
    @IBAction func didChangeNotifyConnection(_ sender: NSButton) {
        AppSettings.notifyConnection = self.notifyConnection.state == .on
    }
    
    @IBAction func didChangeNotifyBatteryLevel(_ sender: NSButton) {
        AppSettings.notifyBatteryLevel = self.notifyBatteryLevel.state == .on
    }
    
    @IBAction func didChangeNotifyBatteryChange(_ sender: NSButton) {
        AppSettings.notifyBatteryCharge = self.notifyBatteryCharge.state == .on
    }
    
    @IBAction func didChangeNotifyBatteryFull(_ sender: NSButton) {
        AppSettings.notifyBatteryFull = self.notifyBatteryFull.state == .on
    }
    
    @IBAction func didChangeLaunchOnLogin(_ sender: NSButton) {
        AppSettings.launchOnLogin = self.launchOnLogin.state == .on
    }
    
    @IBAction func didPushOK(_ sender: NSButton) {
        guard let window = self.view.window else { return }
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
}
