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
class AppDelegate: NSObject, NSApplicationDelegate {
    let manager: JoyConManager = JoyConManager()
    var dataManager: DataManager?
    var controllers: [GameController] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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
        
    }

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
            NotificationCenter.default.post(name: .controllerConnected, object: gameController)
            return
        }
        self.addController(controller)
    }

    func disconnectController(_ controller: JoyConSwift.Controller) {
        if let gameController = self.controllers.first(where: {
            $0.data.serialID == controller.serialID
        }) {
            gameController.controller = nil
            NotificationCenter.default.post(name: .controllerDisconnected, object: gameController)
        }
    }

    func addController(_ controller: JoyConSwift.Controller) {
        guard let dataManager = self.dataManager else { return }
        let controllerData = dataManager.getControllerData(controller: controller)
        let gameController = GameController(data: controllerData)
        gameController.controller = controller
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
        let index = self.controllers.firstIndex(where: { $0 === controller })
        Swift.print("controlelr index: \(index)")
        self.controllers.removeAll(where: { $0 === controller })
        Swift.print("controller count: \(self.controllers.count)")
        NotificationCenter.default.post(name: .controllerRemoved, object: controller)
    }

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        _ = self.dataManager?.save()
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return self.dataManager?.undoManager
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
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
