//
//  ControllerViewItem.swift
//  JoyConMapper
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
        
        let disconnectMenu = NSMenuItem(title: "Disconnect", action: Selector(("disconnect")), keyEquivalent: "")

        if self.controller?.controller != nil {
            disconnectMenu.target = self
        }
        menu.addItem(disconnectMenu)

        let removeMenu = NSMenuItem(title: "Remove", action: Selector(("remove")), keyEquivalent: "")
        removeMenu.target = self
        menu.addItem(removeMenu)

        let pos = event.cgEvent?.unflippedLocation ?? CGPoint(x: 0, y: 0)
        menu.popUp(positioning: nil, at: pos, in: nil)
    }
    
    @objc func disconnect() {
        self.controller?.disconnect()
    }
    
    @objc func remove() {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        guard let controller = self.controller else { return }
        
        delegate.removeController(gameController: controller)
    }
}
