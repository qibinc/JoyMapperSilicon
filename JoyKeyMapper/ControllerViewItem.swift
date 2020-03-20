//
//  ControllerViewItem.swift
//  JoyKeyMapper
//
//  Created by Yuki Ohno on 2019/07/15.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit

class ControllerViewItem: NSCollectionViewItem {
    @IBOutlet weak var controllerView: ControllerView!
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    var controller: GameController?
    
    override var isSelected: Bool {
        didSet {
            self.controllerView.isSelected = self.isSelected
            self.controllerView.needsDisplay = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.controllerView.isSelected = self.isSelected
        self.controllerView.needsDisplay = true
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if event.modifierFlags.contains(.control) {
            self.showMenu(event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        self.showMenu(event)
    }
    
    func showMenu(_ event: NSEvent) {
        let menu = NSMenu(title: "ControllerMenu")
        
        // Enable key mappings menu
        let enableTitle = NSLocalizedString("Enable key mappings", comment: "Enable key mappings")
        let enableMenu = NSMenuItem(title: enableTitle, action: Selector(("enableKeyMappings")), keyEquivalent: "")
        enableMenu.target = self
        enableMenu.state = (self.controller?.isEnabled ?? false) ? .on : .off
        menu.addItem(enableMenu)

        // Disconnect menu
        let disconnectTitle = NSLocalizedString("Disconnect", comment: "Disconnect")
        let disconnectMenu = NSMenuItem(title: disconnectTitle, action: Selector(("disconnect")), keyEquivalent: "")
        if self.controller?.controller != nil {
            disconnectMenu.target = self
        }
        menu.addItem(disconnectMenu)

        // Remove menu
        let removeTitle = NSLocalizedString("Remove", comment: "Remove")
        let removeMenu = NSMenuItem(title: removeTitle, action: Selector(("remove")), keyEquivalent: "")
        removeMenu.target = self
        menu.addItem(removeMenu)

        let pos = event.cgEvent?.unflippedLocation ?? CGPoint(x: 0, y: 0)
        menu.popUp(positioning: nil, at: pos, in: nil)
    }
    
    @objc func enableKeyMappings() {
        guard let controller = self.controller else { return }
        controller.isEnabled = !controller.isEnabled
    }
    
    @objc func disconnect() {
        self.controller?.disconnect()
    }
    
    @objc func remove() {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        guard let controller = self.controller else { return }
        
        let alert = NSAlert()
        alert.icon = controller.icon
        alert.messageText = NSLocalizedString("Do you really want to remove the controller?", comment: "Do you really want to remove the controller?")
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // Cancel
            return
        }
        
        delegate.removeController(gameController: controller)
    }
}
