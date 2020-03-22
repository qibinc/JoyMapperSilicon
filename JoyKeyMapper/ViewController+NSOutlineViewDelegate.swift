//
//  ViewController+NSOutlineViewDelegate.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/07/23.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit
import JoyConSwift

let buttonNames: [JoyCon.Button: String] = [
    .Up: "Up",
    .Right: "Right",
    .Down: "Down",
    .Left: "Left",
    .A: "A",
    .B: "B",
    .X: "X",
    .Y: "Y",
    .L: "L",
    .ZL: "ZL",
    .R: "R",
    .ZR: "ZR",
    .Minus: "Minus",
    .Plus: "Plus",
    .Capture: "Capture",
    .Home: "Home",
    .LStick: "LStick Push",
    .RStick: "RStick Push",
    .LeftSL: "Left SL",
    .LeftSR: "Left SR",
    .RightSL: "Right SL",
    .RightSR: "Right SR"
]
let directionNames: [JoyCon.StickDirection: String]  = [
    .Up: "Up",
    .Right: "Right",
    .Down: "Down",
    .Left: "Left"
]
let leftStickName = "Left Stick"
let rightStickName = "Right Stick"

let controllerButtons: [JoyCon.ControllerType: [JoyCon.Button]] = [
    .JoyConL: [.Up, .Right, .Down, .Left, .LeftSL, .LeftSR, .L, .ZL, .Minus, .Capture, .LStick],
    .JoyConR: [.A, .B, .X, .Y, .RightSL, .RightSR, .R, .ZR, .Plus, .Home, .RStick],
    .ProController: [.A, .B, .X, .Y, .L, .ZL, .R, .ZR, .Up, .Right, .Down, .Left, .Minus, .Plus, .Capture, .Home, .LStick, .RStick]
]
let stickerDirections: [JoyCon.StickDirection] = [
    .Up, .Right, .Down, .Left
]

let buttonNameColumnID = "buttonName"
let buttonKeyColumnID = "buttonKey"

class StickSpeedField: NSTextField {
    var config: KeyConfig
    var stick: JoyCon.Button
    
    init(frame frameRect: NSRect, config: KeyConfig, stick: JoyCon.Button) {
        self.config = config
        self.stick = stick
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        if self.stick == .LStick {
            self.config.leftStick?.speed = self.floatValue
        } else if self.stick == .RStick {
            self.config.rightStick?.speed = self.floatValue
        }
    }
}

extension ViewController: NSOutlineViewDelegate, NSOutlineViewDataSource, KeyConfigSetDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard self.selectedKeyConfig != nil else { return 0 }
        guard let controller = self.selectedController else { return 0 }
        guard let buttons = controllerButtons[controller.type] else { return 0 }
        guard let config = self.selectedKeyConfig else { return 0 }
        
        if let indexOfItem = item as? Int {
            let stickIndex = indexOfItem - buttons.count

            // Stick settings
            if controller.type == .JoyConL {
                return self.numberOfChildItemOfStick(for: config.leftStick?.type)
            }

            if controller.type == .JoyConR {
                return self.numberOfChildItemOfStick(for: config.rightStick?.type)
            }

            if controller.type == .ProController {
                if stickIndex == 0 {
                    return self.numberOfChildItemOfStick(for: config.leftStick?.type)
                }
                if stickIndex == 1 {
                    return self.numberOfChildItemOfStick(for: config.rightStick?.type)
                }
            }

            return 0
        }
        
        if controller.type == .JoyConL || controller.type == .JoyConR {
            return buttons.count + 1
        }
        if controller.type == .ProController {
            return buttons.count + 2
        }
        return 0
    }
    
    func numberOfChildItemOfStick(for type: String?) -> Int {
        guard let typeStr = type else { return 0 }
        
        switch(typeStr) {
        case StickType.Key.rawValue:
            return 4
        case StickType.Mouse.rawValue:
            return 1
        case StickType.MouseWheel.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let controller = self.selectedController else { return false }
        guard let config = self.selectedKeyConfig else { return false }
        guard let buttons = controllerButtons[controller.type] else { return false }
        guard let itemIndex = item as? Int else { return false }

        let stickIndex = itemIndex - buttons.count

        if stickIndex < 0 {
            return false
        }
        
        if controller.type == .JoyConL {
            return self.isStickItemExpandable(for: config.leftStick?.type)
        }
        
        if controller.type == .JoyConR {
            return self.isStickItemExpandable(for: config.rightStick?.type)
        }
        
        if controller.type == .ProController {
            if stickIndex == 0 {
                return self.isStickItemExpandable(for: config.leftStick?.type)
            }
            if stickIndex == 1 {
                return self.isStickItemExpandable(for: config.rightStick?.type)
            }
        }
        
        return false
    }
    
    func isStickItemExpandable(for type: String?) -> Bool {
        guard let typeString = type else { return false }
        
        if typeString == StickType.None.rawValue {
            return false
        }
        
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let parentItem = item as? Int else { return index }
        guard let controller = self.selectedController else { return false }
        guard let buttons = controllerButtons[controller.type] else { return false }

        let stickIndex = parentItem - buttons.count
        if stickIndex < 0 { return false }

        if controller.type == .JoyConL {
            return (JoyCon.Button.LStick, index)
        }
        
        if controller.type == .JoyConR {
            return (JoyCon.Button.RStick, index)
        }
        
        if controller.type == .ProController {
            if stickIndex == 0 {
                return (JoyCon.Button.LStick, index)
            }
            
            if stickIndex == 1 {
                return (JoyCon.Button.RStick, index)
            }

            return "unknown index"
        }
        
        return "unknown controller"
    }
    
    func stickDirectionView(stick: JoyCon.Button, column: NSTableColumn, row: Int) -> NSView? {
        guard let keyConfig = self.selectedKeyConfig else { return nil }
        
        var stickConfig: StickConfig
        if stick == .LStick {
            guard let conf = keyConfig.leftStick else { return nil }
            stickConfig = conf
        } else if stick == .RStick {
            guard let conf = keyConfig.rightStick else { return nil }
            stickConfig = conf
        } else {
            return nil
        }
        
        if column.identifier.rawValue == buttonNameColumnID {
            guard let itemView = self.configTableView.makeView(withIdentifier: column.identifier, owner: self) as? ButtonNameCellView else {
                return nil
            }

            let view = NSTextView(frame: NSRect(origin: CGPoint.zero, size: itemView.frame.size))
            view.isEditable = false
            view.font = itemView.buttonName.font

            if stick == .LStick {
                view.string = leftStickName
            } else if stick == .RStick {
                view.string = rightStickName
            }
            
            return view
        }
        
        if column.identifier.rawValue == buttonKeyColumnID {
            guard let itemView = self.configTableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
                return nil
            }

            let selection = NSPopUpButton(frame: NSRect(origin: CGPoint.zero, size: itemView.frame.size))
            selection.addItem(withTitle: StickType.Key.rawValue) // TODO: i18n
            selection.addItem(withTitle: StickType.Mouse.rawValue)
            selection.addItem(withTitle: StickType.MouseWheel.rawValue)
            selection.addItem(withTitle: StickType.None.rawValue)
            
            if stickConfig.type == StickType.Mouse.rawValue {
                selection.selectItem(at: 1)
            } else if stickConfig.type == StickType.MouseWheel.rawValue {
                selection.selectItem(at: 2)
            } else if stickConfig.type == StickType.None.rawValue {
                selection.selectItem(at: 3)
            } else {
                // Default: .Key
                selection.selectItem(at: 0)
            }
            
            if stick == .LStick {
                selection.action = Selector(("leftStickTypeDidChange:"))
            } else if stick == .RStick {
                selection.action = Selector(("rightStickTypeDidChange:"))
            }
            selection.target = self
                
            return selection
        }
        
        return nil
    }
    
    func stickChildView(stick: JoyCon.Button, column: NSTableColumn, row: Int) -> NSView? {
        guard let config = self.selectedKeyConfig else { return nil }

        var type: String
        if stick == .LStick {
            guard let typeString = config.leftStick?.type else { return nil }
            type = typeString
        } else if stick == .RStick {
            guard let typeString = config.rightStick?.type else { return nil }
            type = typeString
        } else {
            return nil
        }
        
        if type == StickType.Key.rawValue {
            return self.stickDirectionKeyView(stick: stick, column: column, row: row)
        } else if type == StickType.Mouse.rawValue || type == StickType.MouseWheel.rawValue {
            return self.stickMouseView(stick: stick, column: column, row: row)
        }
        
        return nil
    }
    
    func stickMouseView(stick: JoyCon.Button, column: NSTableColumn, row: Int) -> NSView? {
        guard self.selectedController != nil else { return nil }
        guard let keyConfig = self.selectedKeyConfig else { return nil }

        var stickConfig: StickConfig
        if stick == .LStick {
            guard let conf = keyConfig.leftStick else { return nil }
            stickConfig = conf
        } else if stick == .RStick {
            guard let conf = keyConfig.rightStick else { return nil }
            stickConfig = conf
        } else {
            return nil
        }
        
        if column.identifier.rawValue == buttonNameColumnID {
            guard let itemView = self.configTableView.makeView(withIdentifier: column.identifier, owner: self) as? ButtonNameCellView else {
                return nil
            }

            let view = NSTextView(frame: NSRect(origin: CGPoint.zero, size: itemView.frame.size))
            view.isEditable = false
            view.font = itemView.buttonName.font
            view.string = "Speed" // TODO: i18n
            
            return view
        }
        
        if column.identifier.rawValue == buttonKeyColumnID {
            guard let itemView = self.configTableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
                return nil
            }
                        
            let field = StickSpeedField(frame: NSRect(origin: CGPoint.zero, size: itemView.frame.size), config: keyConfig, stick: stick)
            field.floatValue = stickConfig.speed
            field.isEditable = true
            field.formatter = NumberFormatter()
            field.alignment = .right
            
            return field
        }
        
        return nil
    }
    
    func stickDirectionKeyView(stick: JoyCon.Button, column: NSTableColumn, row: Int) -> NSView? {
        guard self.selectedController != nil else { return nil }
        guard let keyConfig = self.selectedKeyConfig else { return nil }

        var stickConfig: StickConfig
        if stick == .LStick {
            guard let conf = keyConfig.leftStick else { return nil }
            stickConfig = conf
        } else if stick == .RStick {
            guard let conf = keyConfig.rightStick else { return nil }
            stickConfig = conf
        } else {
            return nil
        }
        
        guard let keyMaps = stickConfig.keyMaps else { return nil }
        let direction = stickerDirections[row]
        let directionName = directionNames[direction] ?? ""
        guard let keyMap = keyMaps.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == directionName
        }) as? KeyMap else { return nil }
        
        if column.identifier.rawValue == buttonNameColumnID {
            guard let itemView = self.configTableView.makeView(withIdentifier: column.identifier, owner: self) as? ButtonNameCellView else {
                return nil
            }
            
            itemView.buttonName.state = keyMap.isEnabled ? .on : .off
            itemView.buttonName.title = directionName
            if stick == .LStick {
                itemView.buttonName.action = Selector(("leftStickDirectionCheckDidChange:"))
            } else if stick == .RStick {
                itemView.buttonName.action = Selector(("rightStickDirectionCheckDidChange:"))
            }
            itemView.buttonName.target = self
            
            return itemView
        }
        
        if column.identifier.rawValue == buttonKeyColumnID {
            guard let itemView = self.configTableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
                return nil
            }
            
            let keyName = convertKeyName(keyMap: keyMap)
            itemView.textField?.stringValue = keyName
            
            return itemView
        }
        
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let column = tableColumn else { return nil }

        if let (stickButton, stickIndex) = item as? (JoyCon.Button, Int) {
            return self.stickChildView(stick: stickButton, column: column, row: stickIndex)
        }

        guard let row = item as? Int else { return nil }
        guard let controller = self.selectedController else { return nil }
        guard let config = self.selectedKeyConfig else { return nil }
        guard let buttons = controllerButtons[controller.type] else { return nil }
        if row >= buttons.count {
            if controller.type == .JoyConL {
                return self.stickDirectionView(stick: .LStick, column: column, row: row)
            }
            if controller.type == .JoyConR {
                return self.stickDirectionView(stick: .RStick, column: column, row: row)
            }
            if controller.type == .ProController {
                if row - buttons.count == 0 {
                    return self.stickDirectionView(stick: .LStick, column: column, row: row)
                }
                return self.stickDirectionView(stick: .RStick, column: column, row: row)
            }
            return nil
        }
        let button = buttons[row]
        
        let keyMap = config.keyMaps?.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == buttonNames[button]
        }) as? KeyMap
        
        if column.identifier.rawValue == buttonNameColumnID {
            guard let itemView = outlineView.makeView(withIdentifier: column.identifier, owner: self) as? ButtonNameCellView else {
                return nil
            }
            
            itemView.buttonName.state = (keyMap?.isEnabled ?? false) ? .on : .off
            itemView.buttonName.title = buttonNames[button] ?? ""
            itemView.buttonName.action = Selector(("checkDidChange:"))
            itemView.buttonName.target = self
            
            return itemView
        }
        
        if column.identifier.rawValue == buttonKeyColumnID {
            guard let itemView = outlineView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
                return nil
            }
            
            let keyName = convertKeyName(keyMap: keyMap)
            itemView.textField?.stringValue = keyName

            return itemView
        }
        
        return nil
    }
    
    @IBAction func didClick(_ sender: AnyObject) {
        guard self.keyDownHandler == nil else { return }
        guard let type = self.selectedController?.type else { return }

        let selectedRow = self.configTableView.selectedRow
        let item = self.configTableView.item(atRow: selectedRow)
        
        if let rowIndex = item as? Int {
            guard let buttons = controllerButtons[type] else { return }
            guard rowIndex < buttons.count else { return }
            let button = buttons[rowIndex]
            self.didClick(button: button)
            return
        }
        
        if let (stick, rowIndex) = item as? (JoyCon.Button, Int) {
            let type: String
            if stick == .LStick {
                guard let typeString = self.selectedKeyConfig?.leftStick?.type else { return }
                type = typeString
            } else if stick == .RStick {
                guard let typeString = self.selectedKeyConfig?.rightStick?.type else { return }
                type = typeString
            } else {
                return
            }
            
            if type == StickType.Key.rawValue {
                let direction = stickerDirections[rowIndex]
                self.didClick(stick: stick, direction: direction)
            }
            return
        }
    }
    
    func didClick(button: JoyCon.Button) {
        guard let buttonName = buttonNames[button] else { return }
        
        var keyMap = self.selectedKeyConfig?.keyMaps?.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == buttonName
        }) as? KeyMap
        if keyMap == nil {
            keyMap = self.appDelegate?.dataManager?.createKeyMap()
            keyMap?.button = buttonName
            guard let map = keyMap else { return }
            self.selectedKeyConfig?.addToKeyMaps(map)
        }
        guard let map = keyMap else { return }
        
        guard let controller = self.storyboard?.instantiateController(withIdentifier: "KeyConfigViewController") as? KeyConfigViewController else { return }
        controller.keyMap = map
        controller.delegate = self
        
        self.presentAsSheet(controller)
    }
    
    func didClick(stick: JoyCon.Button, direction: JoyCon.StickDirection) {
        guard let directionName = directionNames[direction] else { return }

        var stickConfigData: StickConfig? = nil
        if stick == .LStick {
            stickConfigData = self.selectedKeyConfig?.leftStick
        } else if stick == .RStick {
            stickConfigData = self.selectedKeyConfig?.rightStick
        }
        guard let stickConfig = stickConfigData else { return }

        var keyMap: KeyMap? = stickConfig.keyMaps?.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == directionName
        }) as? KeyMap
        if keyMap == nil {
            keyMap = self.appDelegate?.dataManager?.createKeyMap()
            keyMap?.button = directionName
            guard let map = keyMap else { return }
            stickConfig.addToKeyMaps(map)
        }
        guard let map = keyMap else { return }
        
        guard let controller = self.storyboard?.instantiateController(withIdentifier: "KeyConfigViewController") as? KeyConfigViewController else { return }
        controller.keyMap = map
        controller.delegate = self
        
        self.presentAsSheet(controller)
    }
    
    func setKeyConfig(controller: KeyConfigViewController) {
        self.configTableView.reloadData()
    }
    
    @objc func checkDidChange(_ sender: NSButton) {
        guard let controller = self.selectedController else { return }
        guard let config = self.selectedKeyConfig else { return }
        guard let keyMaps = config.keyMaps else { return }

        let result = keyMaps.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == sender.title // TODO: Use consistent value instead of "title"
        })
        guard let keyMapData = result as? KeyMap else {
            guard let keyMap = self.appDelegate?.dataManager?.createKeyMap() else { return }
            keyMap.button = sender.title // TODO: Use consistent value instead of "title"
            keyMap.isEnabled = sender.state == .on
            config.addToKeyMaps(keyMap)
            controller.updateKeyMap()

            return
        }
        keyMapData.isEnabled = sender.state == .on
        
        controller.updateKeyMap()
    }
    
    @objc func leftStickTypeDidChange(_ sender: NSPopUpButton) {
        guard let config = self.selectedKeyConfig else { return }
        config.leftStick?.type = sender.titleOfSelectedItem ?? ""
        self.configTableView.reloadData()
        self.selectedController?.updateKeyMap()
    }
    
    @objc func rightStickTypeDidChange(_ sender: NSPopUpButton) {
        guard let config = self.selectedKeyConfig else { return }
        config.rightStick?.type = sender.titleOfSelectedItem ?? ""
        self.configTableView.reloadData()
        self.selectedController?.updateKeyMap()
    }
    
    @objc func leftStickDirectionCheckDidChange(_ sender: NSButton) {
        guard let controller = self.selectedController else { return }
        guard let config = self.selectedKeyConfig else { return }
        guard let keyMaps = config.leftStick?.keyMaps else { return }
        
        let result = keyMaps.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == sender.title // TODO: Use consistent value instead of "title"
        })
        guard let keyMapData = result as? KeyMap else { return }
        keyMapData.isEnabled = sender.state == .on
        
        controller.updateKeyMap()
    }
    
    @objc func rightStickDirectionCheckDidChange(_ sender: NSButton) {
        guard let controller = self.selectedController else { return }
        guard let config = self.selectedKeyConfig else { return }
        guard let keyMaps = config.rightStick?.keyMaps else { return }
        
        let result = keyMaps.first(where: { map in
            guard let keyMap = map as? KeyMap else { return false }
            return keyMap.button == sender.title // TODO: Use consistent value instead of "title"
        })
        guard let keyMapData = result as? KeyMap else { return }
        keyMapData.isEnabled = sender.state == .on
        
        controller.updateKeyMap()
    }
    
    @objc func leftStickSpeedDidChange(_ sender: NSTextField) {
        guard let config = self.selectedKeyConfig else { return }
        config.leftStick?.speed = sender.floatValue
    }
    
    @objc func rightStickSpeedDidChange(_ sender: NSTextField) {
        guard let config = self.selectedKeyConfig else { return }
        config.rightStick?.speed = sender.floatValue
    }
}
