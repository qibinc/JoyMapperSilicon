//
//  AppNotifications.swift
//  JoyKeyMapper
//
//  Created by magicien on 2020/03/08.
//  Copyright © 2020 DarkHorse. All rights reserved.
//

import AppKit
import UserNotifications

class AppNotifications {
    static func createControllerIconAttachment(for controller: GameController) -> UNNotificationAttachment? {
        guard let cgImage = controller.icon?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        guard let pngData = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:]) else { return nil }

        let tmpDirName = ProcessInfo.processInfo.globallyUniqueString
        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpDirName, isDirectory: true)
        let fileURL = tmpDirURL.appendingPathComponent("icon.png")

        do {
            try FileManager.default.createDirectory(at: tmpDirURL, withIntermediateDirectories: true, attributes: nil)
            try pngData.write(to: fileURL, options: .atomicWrite)
            return try UNNotificationAttachment(identifier: tmpDirName, url: fileURL, options: [UNNotificationAttachmentOptionsTypeHintKey:kUTTypePNG])
        } catch {
            NSLog("Generate notification attachment error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    static func notifyBatteryFullCharge(_ controller: GameController) {
        guard AppSettings.notifyBatteryFull else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Battery fully charged", comment: "Battery fully charged")
        content.categoryIdentifier = "info"
        if let attachment = self.createControllerIconAttachment(for: controller) {
            content.attachments = [attachment]
        }
        let request = UNNotificationRequest(identifier: "batteryFullCharge", content: content, trigger: nil)
        self.notify(request: request)
    }
    
    static func notifyBatteryLevel(_ controller: GameController) {
        guard AppSettings.notifyBatteryLevel else { return }
        
        let content = UNMutableNotificationContent()
        let label = NSLocalizedString("Battery level", comment: "Battery level")
        let battery = controller.localizedBatteryString
        content.title = "\(label): \(battery)"
        content.categoryIdentifier = "info"
        if let attachment = self.createControllerIconAttachment(for: controller) {
            content.attachments = [attachment]
        }
        let request = UNNotificationRequest(identifier: "batteryLevel", content: content, trigger: nil)
        self.notify(request: request)
    }
    
    static func notifyStartCharge(_ controller: GameController) {
        guard AppSettings.notifyBatteryCharge else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Charge started", comment: "Charge started")
        content.categoryIdentifier = "info"
        if let attachment = self.createControllerIconAttachment(for: controller) {
            content.attachments = [attachment]
        }
        let request = UNNotificationRequest(identifier: "startCharge", content: content, trigger: nil)
        self.notify(request: request)
    }
    
    static func notifyStopCharge(_ controller: GameController) {
        guard AppSettings.notifyBatteryCharge else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Charge stopped", comment: "Charge stopped")
        content.categoryIdentifier = "info"
        if let attachment = self.createControllerIconAttachment(for: controller) {
            content.attachments = [attachment]
        }
        let request = UNNotificationRequest(identifier: "stopCharge", content: content, trigger: nil)
        self.notify(request: request)

    }
    
    static func notifyControllerConnected(_ controller: GameController) {
        guard AppSettings.notifyConnection else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Controller connected", comment: "Controller connected")
        content.categoryIdentifier = "info"
        if let attachment = self.createControllerIconAttachment(for: controller) {
            content.attachments = [attachment]
        }
        let request = UNNotificationRequest(identifier: "controllerConnected", content: content, trigger: nil)
        self.notify(request: request)
    }
    
    static func notifyControllerDisconnected(_ controller: GameController) {
        guard AppSettings.notifyConnection else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Controller disconnected", comment: "Controller disconnected")
        content.categoryIdentifier = "info"
        if let attachment = self.createControllerIconAttachment(for: controller) {
            content.attachments = [attachment]
        }
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
        self.notify(request: request)
    }
    
    static private func notify(request: UNNotificationRequest) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                center.add(request) { error in
                    NSLog("Notification error: \(error?.localizedDescription ?? "")")
                }
            } else {
                center.requestAuthorization(options: [.alert]) { granted, error in
                    if error != nil {
                        NSLog("Notification permission error: \(error?.localizedDescription ?? "")")
                    } else if granted {
                        center.add(request) { error in
                            NSLog("Notification error: \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        }
    }
}
