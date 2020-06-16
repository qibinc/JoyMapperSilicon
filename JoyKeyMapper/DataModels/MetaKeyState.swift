//
//  MetaKeyState.swift
//  JoyKeyMapper
//
//  Created by magicien on 2020/06/16.
//  Copyright © 2020 DarkHorse. All rights reserved.
//

import InputMethodKit

private let shiftKey = Int32(kVK_Shift)
private let optionKey = Int32(kVK_Option)
private let controlKey = Int32(kVK_Control)
private let commandKey = Int32(kVK_Command)
private let metaKeys = [kVK_Shift, kVK_Option, kVK_Control, kVK_Command]
private var pushedKeyConfigs = Set<KeyMap>()

func resetMetaKeyState() {
    let source = CGEventSource(stateID: .hidSystemState)
    pushedKeyConfigs.removeAll()

    DispatchQueue.main.async {
        // Release all meta keys
        metaKeys.forEach {
            let ev = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode($0), keyDown: false)
            ev?.post(tap: .cghidEventTap)
        }
    }
}

func getMetaKeyState() -> (shift: Bool, option: Bool, control: Bool, command: Bool) {
    var shift: Bool = false
    var option: Bool = false
    var control: Bool = false
    var command: Bool = false
    
    pushedKeyConfigs.forEach {
        let modifiers = NSEvent.ModifierFlags(rawValue: UInt($0.modifiers))
        shift = shift || modifiers.contains(.shift)
        option = option || modifiers.contains(.option)
        control = control || modifiers.contains(.control)
        command = command || modifiers.contains(.command)
    }

    return (shift, option, control, command)
}

/**
 * This command must be called in the main thread
 */
func metaKeyEvent(config: KeyMap, keyDown: Bool) {
    var shift: Bool
    var option: Bool
    var control: Bool
    var command: Bool
    
    if keyDown {
        // Check if meta keys are not pressed before pressing keys
        (shift, option, control, command) = getMetaKeyState()
        pushedKeyConfigs.insert(config)
    } else {
        pushedKeyConfigs.remove(config)
        // Check if meta keys are not pressed after releasing keys
        (shift, option, control, command) = getMetaKeyState()
    }
    
    let source = CGEventSource(stateID: .hidSystemState)
    let modifiers = NSEvent.ModifierFlags(rawValue: UInt(config.modifiers))
    if !shift && modifiers.contains(.shift) {
        let ev = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Shift), keyDown: keyDown)
        ev?.post(tap: .cghidEventTap)
    }
    
    if !option && modifiers.contains(.option) {
        let ev = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Option), keyDown: keyDown)
        ev?.post(tap: .cghidEventTap)
    }
    
    if !control && modifiers.contains(.control) {
        let ev = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Control), keyDown: keyDown)
        ev?.post(tap: .cghidEventTap)
    }

    if !command && modifiers.contains(.command) {
        let ev = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Command), keyDown: keyDown)
        ev?.post(tap: .cghidEventTap)
    }
}
