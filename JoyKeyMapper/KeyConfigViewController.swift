//
//  KeyConfigViewController.swift
//  JoyConMapper
//
//  Created by magicien on 2019/07/29.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit
import InputMethodKit

protocol KeyConfigSetDelegate {
    func setKeyConfig(controller: KeyConfigViewController)
}

class KeyConfigViewController: NSViewController, NSComboBoxDelegate, KeyConfigComboBoxDelegate {
    var delegate: KeyConfigSetDelegate?
    var keyMap: KeyMap?
    var keyCode: Int16 = -1
    
    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBOutlet weak var shiftKey: NSButton!
    @IBOutlet weak var optionKey: NSButton!
    @IBOutlet weak var controlKey: NSButton!
    @IBOutlet weak var commandKey: NSButton!

    @IBOutlet weak var keyRadioButton: NSButton!
    @IBOutlet weak var mouseRadioButton: NSButton!
    
    @IBOutlet weak var keyAction: KeyConfigComboBox!
    @IBOutlet weak var mouseAction: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let keyMap = self.keyMap else { return }

        let buttonName = keyMap.button ?? ""
        self.titleLabel.stringValue = "\(buttonName) Button Key Config"

        let modifiers = NSEvent.ModifierFlags(rawValue: UInt(keyMap.modifiers))
        self.shiftKey.state = modifiers.contains(.shift) ? .on : .off
        self.optionKey.state = modifiers.contains(.option) ? .on : .off
        self.controlKey.state = modifiers.contains(.control) ? .on : .off
        self.commandKey.state = modifiers.contains(.command) ? .on : .off
        
        if keyMap.keyCode >= 0 {
            self.keyRadioButton.state = .on
            self.keyAction.stringValue = getKeyName(keyCode: UInt16(keyMap.keyCode))
        } else {
            self.mouseRadioButton.state = .on
            self.mouseAction.selectItem(withTag: Int(keyMap.mouseButton))
        }
        self.keyCode = keyMap.keyCode
        self.keyAction.configDelegate = self
        self.keyAction.delegate = self
        
        self.setKeyActions()
    }
    
    func setKeyActions() {
        //self.keyAction.removeAllItems()
        //self.keyAction.addItems(withObjectValues: keyCodeCells)
    }
    
    func updateKeyMap() {
        guard let keyMap = self.keyMap else { return }
        
        var flags = NSEvent.ModifierFlags(rawValue: 0)

        if self.shiftKey.state == .on {
            flags.formUnion(.shift)
        } else {
            flags.remove(.shift)
        }
        
        if self.optionKey.state == .on {
            flags.formUnion(.option)
        } else {
            flags.remove(.option)
        }
        
        if self.controlKey.state == .on {
            flags.formUnion(.control)
        } else {
            flags.remove(.control)
        }

        
        if self.commandKey.state == .on {
            flags.formUnion(.command)
        } else {
            flags.remove(.command)
        }
        
        keyMap.modifiers = Int32(flags.rawValue)

        if self.keyRadioButton.state == .on {
            keyMap.keyCode = self.keyCode
            keyMap.mouseButton = -1
        } else {
            keyMap.keyCode = -1
            keyMap.mouseButton = Int16(self.mouseAction.selectedTag())
        }
        
        self.delegate?.setKeyConfig(controller: self)
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let index = self.keyAction.indexOfSelectedItem
        if index >= 0 {
            let keyCode = keyCodeList[index]
            self.setKeyCode(UInt16(keyCode))
        }
    }
    
    func setKeyCode(_ keyCode: UInt16) {
        self.keyCode = Int16(keyCode)
        self.keyAction.stringValue = getKeyName(keyCode: keyCode)
    }
    
    @IBAction func didPushRadioButton(_ sender: NSButton) {}
    
    @IBAction func didPushOK(_ sender: NSButton) {
        guard let window = self.view.window else { return }
        self.updateKeyMap()
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
    
    @IBAction func didPushCancel(_ sender: NSButton) {
        guard let window = self.view.window else { return }
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }
}
