//
//  AppDelegate.swift
//  JoyConMapperLauncher
//
//  Created by magicien on 2020/03/08.
//  Copyright © 2020 DarkHorse. All rights reserved.
//

import Cocoa

let mainAppID = "jp.0spec.JoyConMapper"
// let mainAppURL  = URL(string: "https://joyconmapper.0spec.jp")!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    /*
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: mainAppID)
        let activeApp = apps.first { $0.isActive }
        
        if (activeApp == nil) {
            // Launch the main app
            NSWorkspace.shared.open(mainAppURL)
        }

        // Quit this launcher
        NSApp.terminate(nil)
    }
    */
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Ensure the app is not already running
        guard NSRunningApplication.runningApplications(withBundleIdentifier: mainAppID).isEmpty else {
            NSApp.terminate(nil)
            return
        }

        let pathComponents = (Bundle.main.bundlePath as NSString).pathComponents
        let mainPath = NSString.path(withComponents: Array(pathComponents[0...(pathComponents.count - 5)]))
        NSWorkspace.shared.launchApplication(mainPath)
        NSApp.terminate(nil)
    }
}
