//
//  AppDelegate.swift
//  JoyConMapper
//
//  Created by magicien on 2019/07/14.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit
import JoyConSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var controllersMenu: NSMenuItem?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var windowController: NSWindowController?
    
    let manager: JoyConManager = JoyConManager()
    var dataManager: DataManager?
    var controllers: [GameController] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Window initialization
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        self.windowController = storyboard.instantiateController(withIdentifier: "JoyConMapperWindowController") as? NSWindowController
        
        // Menu settings
        let icon = NSImage(named: "menu_icon")
        icon?.size = NSSize(width: 24, height: 24)
        self.statusItem.button?.image = icon
        self.statusItem.menu = self.menu

        // Set controller handlers
        self.manager.connectHandler = { [weak self] controller in
            self?.connectController(controller)
        }
        self.manager.disconnectHandler = { [weak self] controller in
            self?.disconnectController(controller)
        }
        
        self.dataManager = DataManager() { [weak self] manager in
            guard let strongSelf = self else { return }
            guard let dataManager = manager else { return }

            dataManager.controllers.forEach { data in
                let gameController = GameController(data: data)
                strongSelf.controllers.append(gameController)
            }
            _ = strongSelf.manager.runAsync()
            
            NSWorkspace.shared.notificationCenter.addObserver(strongSelf, selector: #selector(strongSelf.didActivateApp), name: NSWorkspace.didActivateApplicationNotification, object: nil)
            
            NotificationCenter.default.post(name: .controllerAdded, object: nil)
        }
        
        self.updateControllersMenu()
    }
    
    // MARK: - Menu
    
    @IBAction func openAbout(_ sender: Any) {
        NSApplication.shared.orderFrontStandardAboutPanel(NSApplication.shared)
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        self.windowController?.window?.makeKeyAndOrderFront(self)
        self.windowController?.showWindow(self)
        self.windowController?.window?.delegate = self
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func updateControllersMenu() {
        self.controllersMenu?.submenu?.removeAllItems()
        
        // TODO: Use an icon instead of text
        let batteryString: [JoyCon.BatteryStatus: String] = [
            .empty: "Empty",
            .critical: "critical",
            .low: "low",
            .medium: "medium",
            .full: "full"
        ]
        // TODO: check 'isCharging'

        self.controllers.forEach { controller in
            guard controller.controller?.isConnected ?? false else { return }
            let item = NSMenuItem()

            item.title = ""
            item.image = controller.icon
            item.image?.size = NSSize(width: 32, height: 32)
            
            item.submenu = NSMenu()

            let disconnect = NSMenuItem()
            disconnect.title = "Disconnect"
            disconnect.action = #selector(AppDelegate.disconnectController(sender:))
            disconnect.representedObject = controller
            item.submenu?.addItem(disconnect)
            item.submenu?.addItem(NSMenuItem.separator())

            // TODO: Use icon instead of text to show the battery state
            let battery = NSMenuItem()
            if let state = controller.controller?.battery, let stateString = batteryString[state] {
                var chargeString = ""
                if controller.controller?.isCharging ?? false {
                    chargeString = " (charging)"
                }
                battery.title = "Battery: \(stateString)\(chargeString)"
            }
            battery.isEnabled = false
            item.submenu?.addItem(battery)
            
            self.controllersMenu?.submenu?.addItem(item)
        }
        
        if let itemCount = self.controllersMenu?.submenu?.items.count, itemCount <= 0 {
            let item = NSMenuItem()
            item.title = "(No controllers connected)"
            item.isEnabled = false
            self.controllersMenu?.submenu?.addItem(item)
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        _ = self.dataManager?.save()
    }
    
    // MARK: - Controller event handlers

    func applicationWillTerminate(_ aNotification: Notification) {
        self.controllers.forEach { controller in
            controller.controller?.setHCIState(state: .disconnect)
        }
    }
    
    func connectController(_ controller: JoyConSwift.Controller) {
        if let gameController = self.controllers.first(where: {
            $0.data.serialID == controller.serialID
        }) {
            gameController.controller = controller
            gameController.startTimer()
            NotificationCenter.default.post(name: .controllerConnected, object: gameController)
        } else {
            self.addController(controller)
        }
        self.updateControllersMenu()
    }

    @objc func disconnectController(sender: Any) {
        guard let item = sender as? NSMenuItem else { return }
        guard let gameController = item.representedObject as? GameController else { return }
        
        gameController.disconnect()
        self.updateControllersMenu()
    }
    
    func disconnectController(_ controller: JoyConSwift.Controller) {
        if let gameController = self.controllers.first(where: {
            $0.data.serialID == controller.serialID
        }) {
            gameController.controller = nil
            NotificationCenter.default.post(name: .controllerDisconnected, object: gameController)
        }
        self.updateControllersMenu()
    }

    func addController(_ controller: JoyConSwift.Controller) {
        guard let dataManager = self.dataManager else { return }
        let controllerData = dataManager.getControllerData(controller: controller)
        let gameController = GameController(data: controllerData)
        gameController.controller = controller
        gameController.startTimer()
        self.controllers.append(gameController)
        
        NotificationCenter.default.post(name: .controllerAdded, object: gameController)
    }
    
    func removeController(_ controller: JoyConSwift.Controller) {
        guard let gameController = self.controllers.first(where: {
            $0.data.serialID == controller.serialID
        }) else { return }
        self.removeController(gameController: gameController)
    }
    
    func removeController(gameController controller: GameController) {
        controller.controller?.setHCIState(state: .disconnect)

        self.dataManager?.delete(controller.data)
        self.controllers.removeAll(where: { $0 === controller })
        NotificationCenter.default.post(name: .controllerRemoved, object: controller)
    }

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        _ = self.dataManager?.save()
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        return self.dataManager?.undoManager
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let isSucceeded = self.dataManager?.save() ?? false
        
        if !isSucceeded {
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        
        return .terminateNow
    }
    
    // MARK: - Context switch handling
    
    @objc func didActivateApp(notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let bundleID = app.bundleIdentifier else { return }
        
        self.controllers.forEach { controller in
            controller.switchApp(bundleID: bundleID)
        }
    }
}
