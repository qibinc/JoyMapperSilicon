//
//  AppSettings.swift
//  JoyKeyMapper
//
//  Created by magicien on 2020/03/12.
//  Copyright © 2020 DarkHorse. All rights reserved.
//

import Foundation
import ServiceManagement

let helperAppBundleID = "jp.0spec.JoyKeyMapperLauncher"

class AppSettings {
    static var disconnectTime: Int {
        get {
            return UserDefaults.standard.integer(forKey: "disconnectTime")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "disconnectTime")
        }
    }
    
    static var notifyConnection: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notifyConnection")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notifyConnection")
        }
    }
    
    static var notifyBatteryLevel: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notifyBatteryLevel")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notifyBatteryLevel")
        }
    }
    
    static var notifyBatteryCharge: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notifyBatteryCharge")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notifyBatteryCharge")
        }
    }
    
    static var notifyBatteryFull: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notifyBatteryFull")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notifyBatteryFull")
        }
    }
    
    static var launchOnLogin: Bool {
        get {
            guard let loginItems = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as NSArray as? [[String:AnyObject]] else { return false }
            return !loginItems.filter {
                $0["Label"] as! String == helperAppBundleID
            }.isEmpty
        }
        set {
            if (!SMLoginItemSetEnabled(helperAppBundleID as CFString, newValue)) {
                Swift.print("Launch on Login setting error")
            }
        }
    }
}
